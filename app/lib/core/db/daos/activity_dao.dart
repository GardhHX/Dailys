import 'package:drift/drift.dart';

import '../../time/local_date.dart';
import '../database.dart';
import '../tables/enums.dart';
import '../tables/m1_tables.dart';

part 'activity_dao.g.dart';

/// ActivityCategory + ActivityRecurrence + Activity access (schema 6/7/8).
@DriftAccessor(tables: [ActivityCategory, ActivityRecurrence, Activity])
class ActivityDao extends DatabaseAccessor<AppDatabase>
    with _$ActivityDaoMixin {
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

  /// Active (non-deleted) recurrence templates for [userId], used by the
  /// materializer's rolling-window run (API-SPEC "Materializer berjalan
  /// pada...").
  Future<List<ActivityRecurrenceRow>> getActiveRecurrences(String userId) =>
      (select(activityRecurrence)
            ..where((t) => t.userId.equals(userId) & t.isDeleted.equals(false)))
          .get();

  /// Applies one recurrence's [RecurrenceMaterializationResult] in a single
  /// transaction: insert-or-ignore each new occurrence (an occurrence already
  /// materialized for that date is an immutable snapshot and is never
  /// overwritten — schema Section 2), then advance the template's
  /// `materialized_through_date` watermark. No-op if there is nothing new and
  /// the watermark is unchanged.
  Future<void> applyMaterialization({
    required String recurrenceId,
    required List<ActivityCompanion> occurrences,
    required LocalDate? materializedThroughDate,
    DateTime? now,
  }) async {
    if (occurrences.isEmpty && materializedThroughDate == null) return;
    await transaction(() async {
      for (final occ in occurrences) {
        await into(activity).insert(occ, mode: InsertMode.insertOrIgnore);
      }
      if (materializedThroughDate != null) {
        final ts = now ?? DateTime.now().toUtc();
        await (update(activityRecurrence)
              ..where((t) => t.id.equals(recurrenceId)))
            .write(
          ActivityRecurrenceCompanion(
            materializedThroughDate: Value(materializedThroughDate.toYmd()),
            updatedAt: Value(ts),
          ),
        );
      }
    });
  }

  // --- Activity (occurrences) ---

  Future<void> insertActivity(ActivityCompanion row) =>
      into(activity).insert(row);

  /// Active activities on a given local date (`YYYY-MM-DD`), for the Home Today
  /// list (schema 8 index).
  Stream<List<ActivityRow>> watchActivitiesForDate(
          String userId, String date) =>
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

  /// Active activities whose local `occurrence_date` falls within the inclusive
  /// `[startDate, endDate]` range (both `YYYY-MM-DD`), for the Home week grid.
  /// String comparison is safe because ISO dates sort lexicographically.
  Stream<List<ActivityRow>> watchActivitiesForRange(
          String userId, String startDate, String endDate) =>
      (select(activity)
            ..where((t) =>
                t.userId.equals(userId) &
                t.isDeleted.equals(false) &
                t.occurrenceDate.isBiggerOrEqualValue(startDate) &
                t.occurrenceDate.isSmallerOrEqualValue(endDate))
            ..orderBy([
              (t) => OrderingTerm(expression: t.occurrenceDate),
              (t) => OrderingTerm(expression: t.startTime),
              (t) => OrderingTerm(expression: t.judul),
            ]))
          .watch();

  /// Active, still-pending, timed activities for [userId] — the candidate set
  /// for reminder scheduling (FR-1.10). Occurrences that are done/skipped, or
  /// have no `start_time` (all-day/flexible, which must carry no reminders
  /// per schema 8), are excluded up front.
  Future<List<ActivityRow>> getReminderCandidates(String userId) => (select(
        activity,
      )..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.isDeleted.equals(false) &
                  t.status.equalsValue(ActivityStatus.belum_mulai) &
                  t.startTime.isNotNull(),
            ))
          .get();

  Future<void> editManualActivity(
      {required String userId,
      required String id,
      required String judul,
      required String activityCategoryId,
      bool isAllDay = false,
      DateTime? startTime,
      DateTime? endTime}) async {
    final row = await (select(activity)
          ..where((a) =>
              a.id.equals(id) &
              a.userId.equals(userId) &
              a.isDeleted.equals(false) &
              a.source.equalsValue(ActivitySource.manual)))
        .getSingleOrNull();
    if (row == null) throw StateError('Activity manual not found');
    final category = await (select(activityCategory)
          ..where((c) =>
              c.id.equals(activityCategoryId) &
              c.userId.equals(userId) &
              c.isDeleted.equals(false) &
              c.isArchived.equals(false)))
        .getSingleOrNull();
    if (category == null || judul.trim().isEmpty) {
      throw ArgumentError('Invalid activity fields');
    }
    final start = isAllDay ? null : startTime;
    final end = isAllDay ? null : endTime;
    if (end != null && (start == null || !end.isAfter(start))) {
      throw ArgumentError('Invalid activity interval');
    }
    await (update(activity)..where((a) => a.id.equals(id))).write(
        ActivityCompanion(
            judul: Value(judul.trim()),
            activityCategoryId: Value(activityCategoryId),
            isAllDay: Value(isAllDay),
            startTime: Value(start),
            endTime: Value(end),
            reminderOffsetsMinutes:
                start == null ? const Value([]) : const Value.absent(),
            updatedAt: Value(DateTime.now().toUtc())));
  }

  Future<void> setActivityStatus(String id, ActivityStatus status,
      {DateTime? now}) async {
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
