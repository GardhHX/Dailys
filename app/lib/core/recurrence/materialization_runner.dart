import 'package:timezone/timezone.dart' as tz;

import '../db/database.dart';
import '../time/local_date.dart';
import 'materializer.dart';

/// Orchestrates [RecurrenceMaterializer] against the local database for a
/// user: loads active `ActivityRecurrence` templates, derives "today" for the
/// given timezone, and persists each result with insert-or-ignore semantics.
///
/// Call [run] at app start, after a successful pull (M2), immediately after a
/// recurrence template is created or edited, and once per local-day change
/// (API-SPEC "Materializer berjalan pada app start, sesudah pull, sesudah
/// template berubah, dan setiap pergantian hari lokal").
class MaterializationRunner {
  const MaterializationRunner(this._db);

  final AppDatabase _db;

  /// Runs the rolling-window materializer for every active recurrence owned by
  /// [userId]. [location] must be the resolved `UserSettings.timezone`.
  Future<void> run({
    required String userId,
    required tz.Location location,
    DateTime? now,
  }) async {
    final ts = now ?? DateTime.now().toUtc();
    final today = LocalDate.fromInstant(ts, location);
    final templates = await _db.activityDao.getActiveRecurrences(userId);
    for (final template in templates) {
      final result = RecurrenceMaterializer.materialize(
        template: template,
        location: location,
        today: today,
        now: ts,
      );
      await _db.activityDao.applyMaterialization(
        recurrenceId: template.id,
        occurrences: result.occurrences,
        materializedThroughDate: result.materializedThroughDate,
        now: ts,
      );
    }
  }
}
