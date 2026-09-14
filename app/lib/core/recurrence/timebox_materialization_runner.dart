import 'package:timezone/timezone.dart' as tz;

import '../db/database.dart';
import '../time/local_date.dart';
import 'timebox_materializer.dart';

/// Orchestrates [TimeboxMaterializer] against the local database for a user,
/// mirroring [MaterializationRunner] one level up: loads active
/// `TimeboxSchedule` templates, derives "today" for the given timezone, and
/// persists each result with insert-or-ignore semantics.
///
/// Call [run] at the same points as the Activity recurrence runner (app
/// start, after a successful pull, immediately after a schedule is created or
/// edited, and once per local-day change).
class TimeboxMaterializationRunner {
  const TimeboxMaterializationRunner(this._db);

  final AppDatabase _db;

  Future<void> run({
    required String userId,
    required tz.Location location,
    DateTime? now,
  }) async {
    final ts = now ?? DateTime.now().toUtc();
    final today = LocalDate.fromInstant(ts, location);
    final schedules = await _db.timeboxDao.getActiveSchedules(userId);
    for (final schedule in schedules) {
      final result = TimeboxMaterializer.materialize(
        schedule: schedule,
        location: location,
        today: today,
        now: ts,
      );
      await _db.timeboxDao.applyMaterialization(
        scheduleId: schedule.id,
        executions: result.executions,
        materializedThroughDate: result.materializedThroughDate,
        now: ts,
      );
    }
  }
}
