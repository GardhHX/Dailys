import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/enums.dart';
import '../tables/m1_tables.dart';

part 'activity_dao.g.dart';

/// ActivityCategory + ActivityRecurrence + Activity access (schema 6/7/8).
@DriftAccessor(tables: [ActivityCategory, ActivityRecurrence, Activity])
class ActivityDao extends DatabaseAccessor<AppDatabase> with _$ActivityDaoMixin {
  ActivityDao(super.db);

  // --- ActivityCategory ---

  Future<void> insertCategory(ActivityCategoryCompanion row) =>
      into(activityCategory).insert(row);

  /// Active, non-archived categories for the picker (schema 6).
  Stream<List<ActivityCategoryRow>> watchPickableCategories(String userId) =>
      (select(activityCategory)
            ..where((t) =>
                t.userId.equals(userId) &
                t.isDeleted.equals(false) &
                t.isArchived.equals(false))
            ..orderBy([(t) => OrderingTerm(expression: t.nama)]))
          .watch();

  // --- ActivityRecurrence ---

  Future<void> insertRecurrence(ActivityRecurrenceCompanion row) =>
      into(activityRecurrence).insert(row);

  /// Deleting a recurrence stops new occurrences but keeps materialized Activity
  /// rows (schema Section 2): tombstone the template only.
  Future<void> softDeleteRecurrence(String id, {DateTime? now}) async {
    final ts = now ?? DateTime.now().toUtc();
    await (update(activityRecurrence)..where((t) => t.id.equals(id))).write(
      ActivityRecurrenceCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(ts),
        updatedAt: Value(ts),
      ),
    );
  }

  // --- Activity (occurrences) ---

  Future<void> insertActivity(ActivityCompanion row) => into(activity).insert(row);

  /// Idempotent upsert of a materialized occurrence keyed by its deterministic
  /// id (UUIDv5). Used by the recurrence materializer's rolling window
  /// (schema Section 2); re-running does not duplicate rows.
  Future<void> upsertOccurrence(ActivityCompanion row) =>
      into(activity).insertOnConflictUpdate(row);

  /// Active activities on a given local date (`YYYY-MM-DD`), for the Home Today
  /// list (schema 8 index).
  Stream<List<ActivityRow>> watchActivitiesForDate(String userId, String date) =>
      (select(activity)
            ..where((t) =>
                t.userId.equals(userId) &
                t.isDeleted.equals(false) &
                t.occurrenceDate.equals(date))
            ..orderBy([
              (t) => OrderingTerm(expression: t.startTime),
              (t) => OrderingTerm(expression: t.judul),
            ]))
          .watch();

  Future<void> setActivityStatus(String id, ActivityStatus status, {DateTime? now}) async {
    final ts = now ?? DateTime.now().toUtc();
    await (update(activity)..where((t) => t.id.equals(id))).write(
      ActivityCompanion(status: Value(status), updatedAt: Value(ts)),
    );
  }

  Future<void> softDeleteActivity(String id, {DateTime? now}) async {
    final ts = now ?? DateTime.now().toUtc();
    await (update(activity)..where((t) => t.id.equals(id))).write(
      ActivityCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(ts),
        updatedAt: Value(ts),
      ),
    );
  }
}
