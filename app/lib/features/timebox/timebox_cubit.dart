import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/db/daos/timebox_dao.dart';
import '../../core/db/database.dart';
import '../../core/ids/deterministic_id.dart';
import '../../core/recurrence/timebox_materialization_runner.dart';
import '../../core/time/local_date.dart';
import '../../core/time/tz_resolver.dart';
import 'timebox_state.dart';

/// Drives the Timebox weekly grid + its daily-timeline integration
/// (design/screens/home.md; PRD FR-3.1-3.15): schedule CRUD (recurring/
/// ad-hoc), materialization, and the pending-execution lifecycle
/// (start/complete/skip/missed/reschedule). Home owns one instance alongside
/// `ActivityHomeCubit` and merges both for display.
class TimeboxCubit extends Cubit<TimeboxState> {
  TimeboxCubit({
    required AppDatabase db,
    required String userId,
    required tz.Location location,
    LocalDate? initialWeekStart,
  })  : _db = db,
        _userId = userId,
        _location = location,
        super(TimeboxState(
          weekStart: _mondayOf(initialWeekStart ??
              LocalDate.fromInstant(DateTime.now().toUtc(), location)),
        )) {
    _watchWeek(state.weekStart);
    // Keeps missed-block detection ("plannedEndAt < now") live while Home
    // stays open, same rationale as `TugasListCubit`'s clock tick.
    _clock = Timer.periodic(const Duration(seconds: 30), (_) => refreshClock());
  }

  final AppDatabase _db;
  final String _userId;
  final tz.Location _location;
  Timer? _clock;
  StreamSubscription<List<TimeboxOccurrence>>? _sub;

  /// Per-execution local date the "masih berlaku" dismissal was last chosen
  /// on (FR-3.7: "prompt boleh muncul lagi paling cepat pada hari lokal
  /// berikutnya"). Not persisted — an app restart re-showing a still-pending
  /// missed prompt is an acceptable, conservative fallback since "masih
  /// berlaku" performs no mutation to remember in the first place.
  final Map<String, LocalDate> _dismissedOn = {};

  String get timezone => _location.name;

  String formatTime(DateTime instant) {
    final local = tz.TZDateTime.from(instant, _location);
    return "${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}";
  }

  /// Resolves a local wall-clock time on [date] to an Instant, applying the
  /// same DST policy as materialization (schema 2, 23.1) — used by the
  /// reschedule picker so widget code never touches `tz.Location` directly.
  DateTime resolveLocalInstant(LocalDate date, int hour, int minute) =>
      TzResolver.localToUtc(_location, date.year, date.month, date.day, hour, minute);

  LocalDate _today() => LocalDate.fromInstant(DateTime.now().toUtc(), _location);

  static LocalDate _mondayOf(LocalDate d) => d.addDays(-(d.weekday - 1));

  void refreshClock() {
    if (!isClosed) emit(state.copyWith(now: DateTime.now().toUtc()));
  }

  void retry() {
    emit(state.copyWith(loading: true, error: null));
    _watchWeek(state.weekStart);
  }

  void _watchWeek(LocalDate monday) {
    _sub?.cancel();
    final end = monday.addDays(6);
    _sub = _db.timeboxDao
        .watchOccurrencesForRange(_userId, monday.toYmd(), end.toYmd())
        .listen((rows) {
      emit(state.copyWith(occurrences: rows, loading: false, now: DateTime.now().toUtc()));
    }, onError: (_) => emit(state.copyWith(loading: false, error: 'load')));
  }

  /// Occurrences across an arbitrary inclusive range, for callers (e.g. the
  /// weekly grid) that need a window wider than the cubit's own week.
  Stream<List<TimeboxOccurrence>> watchRange(String startDate, String endDate) =>
      _db.timeboxDao.watchOccurrencesForRange(_userId, startDate, endDate);

  void goToWeek(LocalDate monday) {
    final target = _mondayOf(monday);
    if (target == state.weekStart) return;
    emit(state.copyWith(weekStart: target, loading: true));
    _watchWeek(target);
  }

  void previousWeek() => goToWeek(state.weekStart.addDays(-7));
  void nextWeek() => goToWeek(state.weekStart.addDays(7));
  void thisWeek() => goToWeek(_today());

  // --- Schedule creation (FR-3.1, 3.2, 3.11) ---

  List<int> _sanitizeOffsets(List<int> offsets) =>
      (offsets.where((o) => o >= 0).toSet().toList()..sort());

  /// FR-3.2: single-day ad-hoc block.
  Future<String> createAdHocBlock({
    required String judul,
    required String activityCategoryId,
    required LocalDate date,
    required String startTime,
    required String endTime,
    String? tugasId,
    String? habitId,
    List<int> reminderOffsetsMinutes = const [],
  }) async {
    final id = await _insertSchedule(
      judul: judul,
      activityCategoryId: activityCategoryId,
      startTime: startTime,
      endTime: endTime,
      hari: null,
      tanggalSpesifik: date.toYmd(),
      isRecurring: false,
      tugasId: tugasId,
      habitId: habitId,
      reminderOffsetsMinutes: reminderOffsetsMinutes,
    );
    await _materialize();
    return id;
  }

  /// FR-3.1: weekly recurring template. TimeboxSchedule carries a single
  /// `hari` per row (schema 10 — unlike ActivityRecurrence's day *set*), so
  /// selecting several weekdays inserts one schedule row per day; they share
  /// nothing afterward (editing/deactivating one doesn't touch the others),
  /// which is also what makes FR-3.11 "duplicate to another day" trivial:
  /// [duplicateToDay] just inserts one more such row.
  Future<List<String>> createRecurringBlock({
    required String judul,
    required String activityCategoryId,
    required Set<int> days,
    required String startTime,
    required String endTime,
    String? tugasId,
    String? habitId,
    List<int> reminderOffsetsMinutes = const [],
  }) async {
    final ids = <String>[];
    for (final day in days) {
      ids.add(await _insertSchedule(
        judul: judul,
        activityCategoryId: activityCategoryId,
        startTime: startTime,
        endTime: endTime,
        hari: day,
        tanggalSpesifik: null,
        isRecurring: true,
        tugasId: tugasId,
        habitId: habitId,
        reminderOffsetsMinutes: reminderOffsetsMinutes,
      ));
    }
    await _materialize();
    return ids;
  }

  /// FR-3.11: copies [schedule]'s content to another occasion — another
  /// weekday for a recurring template, or another explicit date for an
  /// ad-hoc block.
  Future<String> duplicateToDay(
    TimeboxScheduleRow schedule, {
    int? newHari,
    LocalDate? newDate,
  }) async {
    assert((newHari == null) != (newDate == null),
        'duplicateToDay wants exactly one of newHari (recurring) or newDate (ad-hoc)');
    final id = await _insertSchedule(
      judul: schedule.judul,
      activityCategoryId: schedule.activityCategoryId,
      startTime: schedule.startTime,
      endTime: schedule.endTime,
      hari: newHari,
      tanggalSpesifik: newDate?.toYmd(),
      isRecurring: newHari != null,
      tugasId: schedule.tugasId,
      habitId: schedule.habitId,
      reminderOffsetsMinutes: schedule.reminderOffsetsMinutes,
    );
    await _materialize();
    return id;
  }

  Future<String> _insertSchedule({
    required String judul,
    required String activityCategoryId,
    required String startTime,
    required String endTime,
    required int? hari,
    required String? tanggalSpesifik,
    required bool isRecurring,
    String? tugasId,
    String? habitId,
    List<int> reminderOffsetsMinutes = const [],
  }) async {
    final ts = DateTime.now().toUtc();
    final id = DeterministicId.v4();
    await _db.timeboxDao.insertSchedule(TimeboxScheduleCompanion.insert(
      id: id,
      createdAt: ts,
      updatedAt: ts,
      userId: _userId,
      tugasId: Value(tugasId),
      habitId: Value(habitId),
      judul: judul,
      activityCategoryId: activityCategoryId,
      startTime: startTime,
      endTime: endTime,
      hari: Value(hari),
      tanggalSpesifik: Value(tanggalSpesifik),
      isRecurring: isRecurring,
      reminderOffsetsMinutes: Value(_sanitizeOffsets(reminderOffsetsMinutes)),
    ));
    return id;
  }

  Future<void> _materialize() =>
      TimeboxMaterializationRunner(_db).run(userId: _userId, location: _location);

  /// FR-3.8: mutable fields only; already materialized executions keep their
  /// own snapshot (schema 10.1) and are untouched here.
  Future<void> editSchedule({
    required String id,
    String? judul,
    String? activityCategoryId,
    String? startTime,
    String? endTime,
    List<int>? reminderOffsetsMinutes,
  }) async {
    await _db.timeboxDao.updateSchedule(
      id,
      TimeboxScheduleCompanion(
        judul: judul == null ? const Value.absent() : Value(judul),
        activityCategoryId:
            activityCategoryId == null ? const Value.absent() : Value(activityCategoryId),
        startTime: startTime == null ? const Value.absent() : Value(startTime),
        endTime: endTime == null ? const Value.absent() : Value(endTime),
        reminderOffsetsMinutes: reminderOffsetsMinutes == null
            ? const Value.absent()
            : Value(_sanitizeOffsets(reminderOffsetsMinutes)),
      ),
    );
    await _materialize();
  }

  /// FR-3.12 "Nonaktifkan seluruh template": stops future materialization,
  /// leaves past/pending executions untouched.
  Future<void> setScheduleActive(String scheduleId, bool active) =>
      _db.timeboxDao.setActive(scheduleId, active);

  Future<void> deleteSchedule(String scheduleId) =>
      _db.timeboxDao.softDeleteSchedule(scheduleId);

  // --- Execution lifecycle ---

  Future<void> start(String executionId) => _db.timeboxDao.start(executionId);

  Future<void> complete(String executionId, {String? catatan}) =>
      _db.timeboxDao.complete(executionId, catatan: catatan);

  /// FR-3.12 "Lewati kejadian ini": never touches the template.
  Future<void> skip(String executionId, {String? catatan}) =>
      _db.timeboxDao.skip(executionId, catatan: catatan);

  /// FR-3.7 "tandai sebagai missed".
  Future<void> markMissed(String executionId, {String? catatan}) =>
      _db.timeboxDao.markMissed(executionId, catatan: catatan);

  /// FR-3.7 reschedule: [targetStart] is the destination Instant; its local
  /// occurrence date is derived here so the DAO stays timezone-free.
  Future<String> reschedule({
    required String sourceExecutionId,
    required DateTime targetStart,
    String? catatan,
  }) {
    final targetDate = LocalDate.fromInstant(targetStart, _location);
    return _db.timeboxDao.reschedule(
      sourceExecutionId: sourceExecutionId,
      targetStart: targetStart,
      targetOccurrenceDate: targetDate.toYmd(),
      catatan: catatan,
    );
  }

  /// FR-3.7 "masih berlaku (belum sempat update)": no mutation; only
  /// remembers not to re-prompt until the next local day.
  void dismissMissedPromptForToday(String executionId) {
    _dismissedOn[executionId] = _today();
    emit(state.copyWith(now: DateTime.now().toUtc()));
  }

  bool isMissedPromptDismissed(String executionId) =>
      _dismissedOn[executionId] == _today();

  @override
  Future<void> close() {
    _clock?.cancel();
    _sub?.cancel();
    return super.close();
  }
}
