import 'package:drift/drift.dart';

import '../../ids/deterministic_id.dart';
import '../../time/local_date.dart';
import '../../time/tz_resolver.dart';
import '../database.dart';
import '../tables/enums.dart';
import '../tables/m1_tables.dart';
import '../tables/m3_tables.dart';

part 'timebox_dao.g.dart';

/// A materialized occurrence joined with its owning template. TimeboxExecution
/// only snapshots time + outcome (schema 10.1); `judul`/category/reminders for
/// a still-pending occurrence live on the schedule, so callers that need to
/// display or remind on an occurrence always read both.
class TimeboxOccurrence {
  const TimeboxOccurrence({required this.execution, required this.schedule});

  final TimeboxExecutionRow execution;
  final TimeboxScheduleRow schedule;
}

/// Thrown by TimeboxExecution commands whose preconditions the schema
/// mandates (schema 10.1): `start`/`complete`/`skip`/`missed` only from
/// `pending`, reschedule target validation.
class TimeboxCommandException implements Exception {
  TimeboxCommandException(this.message);
  final String message;
  @override
  String toString() => 'TimeboxCommandException: $message';
}

/// TimeboxSchedule + TimeboxExecution access (schema 10/10.1). Also touches
/// `Activity` directly (rather than going through `ActivityDao`) so that
/// completion's "create exactly one Activity + stamp `activity_id`" happens in
/// a single transaction with the execution update.
@DriftAccessor(tables: [TimeboxSchedule, TimeboxExecution, Activity])
class TimeboxDao extends DatabaseAccessor<AppDatabase> with _$TimeboxDaoMixin {
  TimeboxDao(super.db);

  // --- TimeboxSchedule ---

  Future<void> insertSchedule(TimeboxScheduleCompanion row) =>
      into(timeboxSchedule).insert(row);

  Future<void> updateSchedule(String id, TimeboxScheduleCompanion patch,
      {DateTime? now}) async {
    final ts = now ?? DateTime.now().toUtc();
    await (update(timeboxSchedule)..where((t) => t.id.equals(id)))
        .write(patch.copyWith(updatedAt: Value(ts)));
  }

  /// FR-3.12: disables/enables the whole template. Does not touch already
  /// materialized executions or their status.
  Future<void> setActive(String id, bool active, {DateTime? now}) async {
    final ts = now ?? DateTime.now().toUtc();
    await (update(timeboxSchedule)..where((t) => t.id.equals(id))).write(
      TimeboxScheduleCompanion(isActive: Value(active), updatedAt: Value(ts)),
    );
  }

  /// Tombstones the template only; already materialized executions (and any
  /// Activity they produced) are kept, mirroring
  /// `ActivityDao.softDeleteRecurrence`.
  Future<void> softDeleteSchedule(String id, {DateTime? now}) async {
    final ts = now ?? DateTime.now().toUtc();
    await (update(timeboxSchedule)..where((t) => t.id.equals(id))).write(
      TimeboxScheduleCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(ts),
        updatedAt: Value(ts),
      ),
    );
  }

  Future<TimeboxScheduleRow?> getScheduleById(String id) =>
      (select(timeboxSchedule)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Stream<List<TimeboxScheduleRow>> watchSchedules(String userId) =>
      (select(timeboxSchedule)
            ..where((t) => t.userId.equals(userId) & t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm(expression: t.judul)]))
          .watch();

  /// Active (not deactivated, not deleted) templates for [userId] — the
  /// candidate set for the materializer's rolling-window run.
  Future<List<TimeboxScheduleRow>> getActiveSchedules(String userId) =>
      (select(timeboxSchedule)
            ..where((t) =>
                t.userId.equals(userId) &
                t.isDeleted.equals(false) &
                t.isActive.equals(true)))
          .get();

  // --- TimeboxExecution: materialization ---

  /// Applies one schedule's materialization result in a single transaction:
  /// insert-or-ignore each new execution (an execution already materialized
  /// for that `planned_start_at` is immutable and never overwritten — schema
  /// 10.1 unique-active constraint), then advance the watermark.
  Future<void> applyMaterialization({
    required String scheduleId,
    required List<TimeboxExecutionCompanion> executions,
    required LocalDate? materializedThroughDate,
    DateTime? now,
  }) async {
    if (executions.isEmpty && materializedThroughDate == null) return;
    await transaction(() async {
      for (final exec in executions) {
        await into(timeboxExecution).insert(exec, mode: InsertMode.insertOrIgnore);
      }
      if (materializedThroughDate != null) {
        final ts = now ?? DateTime.now().toUtc();
        await (update(timeboxSchedule)..where((t) => t.id.equals(scheduleId))).write(
          TimeboxScheduleCompanion(
            materializedThroughDate: Value(materializedThroughDate.toYmd()),
            updatedAt: Value(ts),
          ),
        );
      }
    });
  }

  // --- TimeboxExecution: reads ---

  Future<TimeboxExecutionRow?> getExecutionById(String id) =>
      (select(timeboxExecution)..where((t) => t.id.equals(id))).getSingleOrNull();

  JoinedSelectStatement<HasResultSet, dynamic> _occurrenceJoin() =>
      select(timeboxExecution).join([
        innerJoin(
            timeboxSchedule, timeboxSchedule.id.equalsExp(timeboxExecution.scheduleId)),
      ]);

  List<TimeboxOccurrence> _readOccurrences(List<TypedResult> rows) => rows
      .map((row) => TimeboxOccurrence(
            execution: row.readTable(timeboxExecution),
            schedule: row.readTable(timeboxSchedule),
          ))
      .toList();

  /// Active occurrences for [userId] whose local `occurrence_date` falls
  /// within the inclusive `[startDate, endDate]` range — for the Home weekly
  /// grid and daily timeline (same range convention as
  /// `ActivityDao.watchActivitiesForRange`).
  Stream<List<TimeboxOccurrence>> watchOccurrencesForRange(
      String userId, String startDate, String endDate) {
    final query = _occurrenceJoin()
      ..where(timeboxSchedule.userId.equals(userId) &
          timeboxSchedule.isDeleted.equals(false) &
          timeboxExecution.isDeleted.equals(false) &
          timeboxExecution.occurrenceDate.isBiggerOrEqualValue(startDate) &
          timeboxExecution.occurrenceDate.isSmallerOrEqualValue(endDate))
      ..orderBy([OrderingTerm(expression: timeboxExecution.plannedStartAt)]);
    return query.watch().map(_readOccurrences);
  }

  /// Active, still-pending occurrences for [userId] — the candidate set for
  /// reminder scheduling (FR-3.13). Reminder offsets are read live from the
  /// (possibly since-edited) schedule; see `timebox_reminder_plan.dart` for
  /// why that still satisfies "edit hanya berlaku untuk execution yang belum
  /// dimaterialisasi".
  Future<List<TimeboxOccurrence>> getReminderCandidates(String userId) {
    final query = _occurrenceJoin()
      ..where(timeboxSchedule.userId.equals(userId) &
          timeboxSchedule.isDeleted.equals(false) &
          timeboxExecution.isDeleted.equals(false) &
          timeboxExecution.status.equalsValue(TimeboxExecutionStatus.pending));
    return query.get().then(_readOccurrences);
  }

  // --- TimeboxExecution: commands ---

  Future<TimeboxExecutionRow> _pendingOrThrow(String executionId) async {
    final row = await getExecutionById(executionId);
    if (row == null || row.isDeleted) {
      throw TimeboxCommandException('Execution tidak ditemukan: $executionId');
    }
    if (row.status != TimeboxExecutionStatus.pending) {
      throw TimeboxCommandException(
          'Command hanya berlaku dari status pending (saat ini: ${row.status.name})');
    }
    return row;
  }

  /// FR-3.6: mengisi `actual_start_at` tanpa mengubah status (schema 10.1).
  Future<void> start(String executionId, {DateTime? now}) async {
    await _pendingOrThrow(executionId);
    final ts = now ?? DateTime.now().toUtc();
    await (update(timeboxExecution)..where((t) => t.id.equals(executionId))).write(
      TimeboxExecutionCompanion(actualStartAt: Value(ts), updatedAt: Value(ts)),
    );
  }

  /// FR-3.14: completion membuat tepat satu Activity deterministik dan
  /// mewajibkan `activity_id` (schema 10.1), dalam satu transaction dengan
  /// update status execution.
  Future<String> complete(String executionId, {DateTime? now, String? catatan}) async {
    final ts = now ?? DateTime.now().toUtc();
    return transaction(() async {
      final execution = await _pendingOrThrow(executionId);
      final schedule = await getScheduleById(execution.scheduleId);
      if (schedule == null) {
        throw TimeboxCommandException('Schedule tidak ditemukan: ${execution.scheduleId}');
      }
      final activityId = DeterministicId.derivedActivity('timebox', execution.id);
      await into(activity).insert(
        ActivityCompanion.insert(
          id: activityId,
          createdAt: ts,
          updatedAt: ts,
          userId: schedule.userId,
          occurrenceDate: execution.occurrenceDate,
          judul: schedule.judul,
          activityCategoryId: schedule.activityCategoryId,
          startTime: Value(execution.actualStartAt ?? execution.plannedStartAt),
          endTime: Value(ts),
          isAllDay: const Value(false),
          status: ActivityStatus.selesai,
          source: ActivitySource.timebox,
          sourceId: Value(execution.id),
          reminderOffsetsMinutes: const Value([]),
          catatan: Value(catatan),
          originDeviceId: Value(schedule.originDeviceId),
        ),
        mode: InsertMode.insertOrIgnore,
      );
      await (update(timeboxExecution)..where((t) => t.id.equals(executionId))).write(
        TimeboxExecutionCompanion(
          status: const Value(TimeboxExecutionStatus.completed),
          actualEndAt: Value(ts),
          activityId: Value(activityId),
          catatan: catatan == null ? const Value.absent() : Value(catatan),
          updatedAt: Value(ts),
        ),
      );
      return activityId;
    });
  }

  /// FR-3.12 "Lewati kejadian ini": one execution only, no Activity, and
  /// `TimeboxSchedule.is_active` is never touched by this method.
  Future<void> skip(String executionId, {DateTime? now, String? catatan}) async {
    await _pendingOrThrow(executionId);
    final ts = now ?? DateTime.now().toUtc();
    await (update(timeboxExecution)..where((t) => t.id.equals(executionId))).write(
      TimeboxExecutionCompanion(
        status: const Value(TimeboxExecutionStatus.skipped),
        catatan: catatan == null ? const Value.absent() : Value(catatan),
        updatedAt: Value(ts),
      ),
    );
  }

  /// FR-3.7: user confirms the block was missed.
  Future<void> markMissed(String executionId, {DateTime? now, String? catatan}) async {
    await _pendingOrThrow(executionId);
    final ts = now ?? DateTime.now().toUtc();
    await (update(timeboxExecution)..where((t) => t.id.equals(executionId))).write(
      TimeboxExecutionCompanion(
        status: const Value(TimeboxExecutionStatus.missed),
        catatan: catatan == null ? const Value.absent() : Value(catatan),
        updatedAt: Value(ts),
      ),
    );
  }

  /// FR-3.7 reschedule: creates a destination `pending` execution preserving
  /// the source's planned duration, then marks the source `rescheduled` with
  /// `rescheduled_to_id`, in one transaction. Rejects a target equal to the
  /// source's own `planned_start_at`, or one already occupied by another
  /// active (non-deleted) execution of the *same* schedule — the scope the
  /// schema's unique-active index (`schedule_id, planned_start_at`) itself
  /// covers.
  Future<String> reschedule({
    required String sourceExecutionId,
    required DateTime targetStart,
    required String targetOccurrenceDate,
    DateTime? now,
    String? catatan,
  }) async {
    final ts = now ?? DateTime.now().toUtc();
    return transaction(() async {
      final source = await _pendingOrThrow(sourceExecutionId);
      if (targetStart.isAtSameMomentAs(source.plannedStartAt)) {
        throw TimeboxCommandException('Target reschedule sama dengan source.');
      }
      final duration = source.plannedEndAt.difference(source.plannedStartAt);
      final targetEnd = targetStart.add(duration);

      final collision = await (select(timeboxExecution)
            ..where((t) =>
                t.scheduleId.equals(source.scheduleId) &
                t.isDeleted.equals(false) &
                t.plannedStartAt.equals(targetStart)))
          .getSingleOrNull();
      if (collision != null) {
        throw TimeboxCommandException(
            'Target reschedule bertabrakan dengan execution aktif lain.');
      }

      final destinationId = DeterministicId.timeboxExecution(
        source.scheduleId,
        TzResolver.toContractUtc(targetStart),
      );
      await into(timeboxExecution).insert(
        TimeboxExecutionCompanion.insert(
          id: destinationId,
          createdAt: ts,
          updatedAt: ts,
          scheduleId: source.scheduleId,
          occurrenceDate: targetOccurrenceDate,
          plannedStartAt: targetStart,
          plannedEndAt: targetEnd,
          status: TimeboxExecutionStatus.pending,
          originDeviceId: Value(source.originDeviceId),
        ),
      );
      await (update(timeboxExecution)..where((t) => t.id.equals(sourceExecutionId))).write(
        TimeboxExecutionCompanion(
          status: const Value(TimeboxExecutionStatus.rescheduled),
          rescheduledToId: Value(destinationId),
          catatan: catatan == null ? const Value.absent() : Value(catatan),
          updatedAt: Value(ts),
        ),
      );
      return destinationId;
    });
  }

  Future<void> softDeleteExecution(String id, {DateTime? now}) async {
    final ts = now ?? DateTime.now().toUtc();
    await (update(timeboxExecution)..where((t) => t.id.equals(id))).write(
      TimeboxExecutionCompanion(
        isDeleted: const Value(true),
        deletedAt: Value(ts),
        updatedAt: Value(ts),
      ),
    );
  }
}
