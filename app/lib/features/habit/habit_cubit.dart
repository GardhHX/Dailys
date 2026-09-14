import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/db/database.dart';
import '../../core/db/tables/enums.dart';
import '../../core/ids/deterministic_id.dart';
import '../../core/time/local_date.dart';
import 'habit_state.dart';

/// Drives the Habit tab (design/screens/habit.md; PRD 4.5 FR-5.*) and the
/// Home Habits panel, which uses this same cubit/DAO as its source of truth
/// (no more in-memory placeholder).
///
/// The list itself is stream-driven: every mutating `HabitDao` command
/// recomputes and writes the streak cache onto the `Habit` row (schema 11.3),
/// so `watchHabits` always re-emits after a schedule/log change and this
/// cubit never needs to manually refresh — it just re-derives the per-item
/// schedule/log/quota context for the new row set.
class HabitCubit extends Cubit<HabitState> {
  HabitCubit({
    required AppDatabase db,
    required String userId,
    required tz.Location location,
  })  : _db = db,
        _userId = userId,
        _location = location,
        super(const HabitState()) {
    _init();
  }

  final AppDatabase _db;
  final String _userId;
  final tz.Location _location;
  StreamSubscription<List<HabitRow>>? _sub;
  Future<void>? _pending;
  int _version = 0;

  LocalDate get today =>
      LocalDate.fromInstant(DateTime.now().toUtc(), _location);

  String get _personalCategoryId =>
      DeterministicId.seedActivityCategory(_userId, 'personal');

  void _init() {
    _sub = _db.habitDao.watchHabits(_userId).listen(_onHabits, onError: (_) {
      if (!isClosed) emit(state.copyWith(loading: false, error: 'read'));
    });
  }

  Future<void> _onHabits(List<HabitRow> rows) async {
    final myVersion = ++_version;
    final asOf = today;
    final items = <HabitListItem>[];
    for (final row in rows) {
      final schedule = await _db.habitDao.getScheduleForDate(row.id, asOf);
      final log = await _db.habitDao.getLogForDate(row.id, asOf);
      final remaining = schedule == null
          ? 0
          : await _db.habitDao.remainingIzinForWeek(row.id, asOf);
      items.add(HabitListItem(
        habit: row,
        scheduleToday: schedule,
        logToday: log,
        isTargetToday: schedule != null &&
            schedule.state == HabitScheduleState.active &&
            schedule.targetHari.contains(asOf.weekday),
        remainingIzinThisWeek: remaining,
      ));
    }
    if (isClosed || myVersion != _version) return;
    emit(state.copyWith(items: items, today: asOf, loading: false));
  }

  Future<void> _command(Future<void> Function() action) async {
    if (state.busy) return;
    emit(state.copyWith(busy: true));
    try {
      _pending = action();
      await _pending;
      if (!isClosed) emit(state.copyWith(busy: false));
    } catch (_) {
      if (!isClosed) emit(state.copyWith(busy: false, error: 'save'));
    } finally {
      _pending = null;
    }
  }

  void retry() {
    emit(const HabitState(loading: true));
    _sub?.cancel();
    _init();
  }

  /// FR-5.1: create habit + first HabitSchedule.
  Future<void> create({
    required String nama,
    required String warna,
    String? icon,
    required Set<int> targetHari,
    int maxIzinPerMinggu = 1,
  }) =>
      _command(() => _db.habitDao.createHabit(
            userId: _userId,
            nama: nama,
            warna: warna,
            icon: icon,
            targetHari: targetHari,
            maxIzinPerMinggu: maxIzinPerMinggu,
            today: today,
          ));

  Future<void> updateDefinition(String id,
          {String? nama, String? warna, String? icon}) =>
      _command(() => _db.habitDao
          .updateDefinition(id, nama: nama, warna: warna, icon: icon));

  /// FR-5.9.
  Future<void> updateSchedule(
    String id, {
    required Set<int> targetHari,
    required int maxIzinPerMinggu,
    LocalDate? effectiveFrom,
  }) =>
      _command(() => _db.habitDao.updateSchedule(
            habitId: id,
            targetHari: targetHari,
            maxIzinPerMinggu: maxIzinPerMinggu,
            effectiveFrom: effectiveFrom ?? today,
            today: today,
          ));

  /// FR-5.8: Jeda/Lanjutkan.
  Future<void> setArchived(String id,
          {required bool isArchived, LocalDate? effectiveFrom}) =>
      _command(() => _db.habitDao.setArchived(
            habitId: id,
            isArchived: isArchived,
            scheduleEffectiveFrom: effectiveFrom,
            today: today,
          ));

  /// FR-5.11.
  Future<void> reorder(List<String> orderedIds) =>
      _command(() => _db.habitDao.reorder(orderedIds));

  /// FR-5.10.
  Future<void> delete(String id) =>
      _command(() => _db.habitDao.softDeleteHabit(id));

  /// FR-5.7/5.12/5.15: check-in for [tanggal] (defaults today). Only `done`
  /// needs an ActivityCategory — Habit carries none of its own, so this
  /// mirrors `PomodoroCubit.complete`'s default to the seeded "Personal"
  /// category.
  Future<void> setLog({
    required String habitId,
    LocalDate? tanggal,
    required HabitLogStatus status,
    String? catatan,
  }) =>
      _command(() => _db.habitDao.upsertLog(
            habitId: habitId,
            tanggal: tanggal ?? today,
            status: status,
            catatan: catatan,
            activityCategoryId:
                status == HabitLogStatus.done ? _personalCategoryId : null,
            today: today,
          ));

  /// Remaining skip quota for the Monday-Sunday week containing [date] —
  /// exposed for the detail heatmap's per-date log modal, which (unlike the
  /// list's "today" quick-check) can target any past date.
  Future<int> remainingIzinForDate(String habitId, LocalDate date) =>
      _db.habitDao.remainingIzinForWeek(habitId, date);

  Stream<List<HabitScheduleRow>> watchSchedules(String habitId) =>
      _db.habitDao.watchSchedules(habitId);

  Stream<List<HabitLogRow>> watchLogs(String habitId,
          {String? startDate, String? endDate}) =>
      _db.habitDao
          .watchLogs(habitId, startDate: startDate, endDate: endDate);

  @override
  Future<void> close() async {
    await _sub?.cancel();
    await _pending;
    await super.close();
  }
}
