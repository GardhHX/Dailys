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
  })  : _db = db,
        _userId = userId,
        _location = location,
        super(ActivityHomeState(
          date: initialDate ?? LocalDate.fromInstant(DateTime.now().toUtc(), location),
        )) {
    _categoriesSub = _db.activityDao.watchPickableCategories(_userId).listen((cats) {
      _categories = cats;
      _emit();
    });
    _watchDate(state.date);
  }

  final AppDatabase _db;
  final String _userId;
  final tz.Location _location;

  StreamSubscription<List<ActivityRow>>? _activitiesSub;
  StreamSubscription<List<ActivityCategoryRow>>? _categoriesSub;
  List<ActivityRow> _activities = const [];
  List<ActivityCategoryRow> _categories = const [];

  void _watchDate(LocalDate date) {
    _activitiesSub?.cancel();
    _activitiesSub = _db.activityDao.watchActivitiesForDate(_userId, date.toYmd()).listen((rows) {
      _activities = rows;
      _emit();
    });
  }

  void _emit() {
    final completed = _activities.where((a) => a.status == ActivityStatus.selesai).length;
    final rate = completionRatePercent(completed: completed, planned: _activities.length);

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
      loading: false,
    ));
  }

  void goToDate(LocalDate date) {
    if (date == state.date) return;
    emit(state.copyWith(date: date, loading: true));
    _watchDate(date);
  }

  void goToPreviousDay() => goToDate(state.date.addDays(-1));

  void goToNextDay() => goToDate(state.date.addDays(1));

  void goToToday() =>
      goToDate(LocalDate.fromInstant(DateTime.now().toUtc(), _location));

  /// Creates a single, non-recurring Activity on the active date (FR-1.1;
  /// schema 8). `reminder_offsets_minutes` must stay `[]` when there is no
  /// `start_time` (schema 8 invariant); the caller is expected to enforce
  /// that in the form before calling this.
  Future<void> createManualActivity({
    required String judul,
    required String activityCategoryId,
    bool isAllDay = false,
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
      occurrenceDate: state.date.toYmd(),
      judul: judul,
      activityCategoryId: activityCategoryId,
      startTime: Value(isAllDay ? null : startTime),
      endTime: Value(isAllDay ? null : endTime),
      isAllDay: Value(isAllDay),
      status: ActivityStatus.belum_mulai,
      source: ActivitySource.manual,
      reminderOffsetsMinutes: Value(isAllDay || startTime == null ? const [] : reminderOffsetsMinutes),
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
      reminderOffsetsMinutes: Value(isAllDay || startTime == null ? const [] : reminderOffsetsMinutes),
    ));
    await MaterializationRunner(_db).run(userId: _userId, location: _location);
  }

  Future<void> setStatus(String activityId, ActivityStatus status) =>
      _db.activityDao.setActivityStatus(activityId, status);

  Future<void> deleteActivity(String activityId) =>
      _db.activityDao.softDeleteActivity(activityId);

  @override
  Future<void> close() {
    _activitiesSub?.cancel();
    _categoriesSub?.cancel();
    return super.close();
  }
}
