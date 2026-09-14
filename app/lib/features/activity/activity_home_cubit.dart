import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/db/database.dart';
import '../../core/db/tables/enums.dart';
import '../../core/ids/deterministic_id.dart';
import '../../core/projections/completion_rate.dart';
import '../../core/projections/overlap.dart';
import '../../core/recurrence/materialization_runner.dart';
import '../../core/time/local_date.dart';
import '../../core/time/tz_resolver.dart';
import 'activity_home_state.dart';

/// Drives Home Today (design/screens/home.md; M1-PLAN `features/activity`):
/// the active-date occurrence list, completion rate (schema 14.1), overlap
/// warnings (schema 14.1), and Activity/ActivityRecurrence mutation.
class ActivityHomeCubit extends Cubit<ActivityHomeState> {
  ActivityHomeCubit({
    required AppDatabase db,
    required String userId,
    required tz.Location location,
    LocalDate? initialDate,
    DateTime Function()? now,
  })  : _db = db,
        _userId = userId,
        _location = location,
        _now = now ?? (() => DateTime.now().toUtc()),
        super(ActivityHomeState(
          date: initialDate ??
              LocalDate.fromInstant(DateTime.now().toUtc(), location),
        )) {
    _watchCategories();
    _clock = Timer.periodic(const Duration(seconds: 30), (_) => _emit());
    _watchDate(state.date);
  }

  final AppDatabase _db;
  final String _userId;
  final tz.Location _location;
  final DateTime Function() _now;
  Timer? _clock;
  bool _categoriesReady = false;
  bool _activitiesReady = false;
  bool _failed = false;

  DateTime localTime(LocalDate date, int hour, int minute) =>
      TzResolver.localToUtc(
          _location, date.year, date.month, date.day, hour, minute);

  void _watchCategories() {
    _categoriesSub?.cancel();
    _categoriesReady = false;
    _categoriesSub =
        _db.activityDao.watchPickableCategories(_userId).listen((cats) {
      _categories = cats;
      _categoriesReady = true;
      _emit();
    }, onError: (_) => _fail());
  }

  void _fail() {
    _failed = true;
    if (!isClosed) emit(state.copyWith(loading: false, error: 'load'));
  }

  String get timezone => _location.name;
  String formatTime(DateTime instant) {
    final local = tz.TZDateTime.from(instant, _location);
    return "${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}";
  }

  void retry() {
    _failed = false;
    emit(state.copyWith(loading: true));
    _watchCategories();
    _watchDate(state.date);
  }

  /// Active activities across an inclusive local-date range (`YYYY-MM-DD`), for
  /// the Home "Minggu" grid.
  Stream<List<ActivityRow>> watchRange(String startDate, String endDate) =>
      _db.activityDao.watchActivitiesForRange(_userId, startDate, endDate);

  StreamSubscription<List<ActivityRow>>? _activitiesSub;
  StreamSubscription<List<ActivityCategoryRow>>? _categoriesSub;
  List<ActivityRow> _activities = const [];
  List<ActivityCategoryRow> _categories = const [];

  void _watchDate(LocalDate date) {
    _activitiesSub?.cancel();
    _activitiesReady = false;
    _activities = const [];
    _activitiesSub = _db.activityDao
        .watchActivitiesForDate(_userId, date.toYmd())
        .listen((rows) {
      _activities = rows;
      _activitiesReady = true;
      _emit();
    }, onError: (_) => _fail());
  }

  void _emit() {
    if (isClosed || _failed) return;
    final completed =
        _activities.where((a) => a.status == ActivityStatus.selesai).length;
    final rate = completionRatePercent(
        completed: completed, planned: _activities.length);

    // Overlap candidates (schema 14.1): active, non-`dilewati`, both
    // start/end set (excludes all-day/flexible).
    final intervals = _activities
        .where((a) =>
            !a.isAllDay &&
            a.startTime != null &&
            a.endTime != null &&
            a.status != ActivityStatus.dilewati)
        .map((a) => ScheduleInterval(
              entityType: 'activity',
              entityId: a.id,
              start: a.startTime!,
              end: a.endTime!,
            ))
        .toList();

    emit(state.copyWith(
      activities: _activities,
      categories: _categories,
      completionRatePercent: rate,
      overlaps: findOverlaps(intervals),
      loading: !(_activitiesReady && _categoriesReady),
      now: _now(),
    ));
  }

  void goToDate(LocalDate date) {
    if (date == state.date) return;
    emit(state.copyWith(date: date, loading: true));
    _watchDate(date);
  }

  void goToPreviousDay() => goToDate(state.date.addDays(-1));

  void goToNextDay() => goToDate(state.date.addDays(1));

  void goToToday() => goToDate(LocalDate.fromInstant(_now(), _location));

  /// Creates a single, non-recurring Activity on the active date (FR-1.1;
  /// schema 8). `reminder_offsets_minutes` must stay `[]` when there is no
  /// `start_time` (schema 8 invariant); the caller is expected to enforce
  /// that in the form before calling this.
  Future<void> createManualActivity({
    required String judul,
    required String activityCategoryId,
    bool isAllDay = false,
    LocalDate? date,
    DateTime? startTime,
    DateTime? endTime,
    List<int> reminderOffsetsMinutes = const [],
  }) async {
    final ts = DateTime.now().toUtc();
    await _db.activityDao.insertActivity(ActivityCompanion.insert(
      id: DeterministicId.v4(),
      createdAt: ts,
      updatedAt: ts,
      userId: _userId,
      occurrenceDate: (date ?? state.date).toYmd(),
      judul: judul,
      activityCategoryId: activityCategoryId,
      startTime: Value(isAllDay ? null : startTime),
      endTime: Value(isAllDay ? null : endTime),
      isAllDay: Value(isAllDay),
      status: ActivityStatus.belum_mulai,
      source: ActivitySource.manual,
      reminderOffsetsMinutes: Value(
          isAllDay || startTime == null ? const [] : reminderOffsetsMinutes),
    ));
  }

  /// Creates a recurrence template (schema 7) and immediately runs the
  /// materializer so occurrences within the rolling window appear right away
  /// (API-SPEC "Materializer berjalan pada ... sesudah template berubah").
  Future<void> createRecurringSeries({
    required String judul,
    required String activityCategoryId,
    required List<int> recurringDays,
    required LocalDate startsOn,
    LocalDate? endsOn,
    bool isAllDay = false,
    String? startTime,
    String? endTime,
    List<int> reminderOffsetsMinutes = const [],
  }) async {
    final ts = DateTime.now().toUtc();
    await _db.activityDao.insertRecurrence(ActivityRecurrenceCompanion.insert(
      id: DeterministicId.v4(),
      createdAt: ts,
      updatedAt: ts,
      userId: _userId,
      judul: judul,
      activityCategoryId: activityCategoryId,
      startTime: Value(isAllDay ? null : startTime),
      endTime: Value(isAllDay ? null : endTime),
      isAllDay: Value(isAllDay),
      recurringDays: recurringDays,
      startsOn: startsOn.toYmd(),
      endsOn: Value(endsOn?.toYmd()),
      reminderOffsetsMinutes: Value(
          isAllDay || startTime == null ? const [] : reminderOffsetsMinutes),
    ));
    await MaterializationRunner(_db).run(userId: _userId, location: _location);
  }

  Future<void> editManualActivity(
          {required ActivityRow existing,
          required String judul,
          required String activityCategoryId,
          bool isAllDay = false,
          DateTime? startTime,
          DateTime? endTime}) =>
      _db.activityDao.editManualActivity(
          userId: _userId,
          id: existing.id,
          judul: judul,
          activityCategoryId: activityCategoryId,
          isAllDay: isAllDay,
          startTime: startTime,
          endTime: endTime);

  Future<void> setStatus(String activityId, ActivityStatus status) =>
      _db.activityDao.setActivityStatus(activityId, status);

  Future<void> deleteActivity(String activityId) =>
      _db.activityDao.softDeleteActivity(activityId);

  @override
  Future<void> close() {
    _clock?.cancel();
    _activitiesSub?.cancel();
    _categoriesSub?.cancel();
    return super.close();
  }
}
