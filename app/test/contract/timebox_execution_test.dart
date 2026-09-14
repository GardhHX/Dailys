import 'dart:ffi';
import 'dart:io';

import 'package:dailys/core/db/daos/timebox_dao.dart';
import 'package:dailys/core/db/database.dart';
import 'package:dailys/core/db/tables/enums.dart';
import 'package:dailys/core/ids/deterministic_id.dart';
import 'package:dailys/core/time/tz_resolver.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';

/// Contract tests for the TimeboxExecution invariants schema.md 10.1
/// mandates: completion creates exactly one deterministic Activity, skip
/// never touches `TimeboxSchedule.is_active`, reschedule is atomic and
/// rejects a same/colliding target, and `(schedule_id, planned_start_at)` is
/// unique among active rows.
void main() {
  setUpAll(() {
    if (Platform.isWindows) {
      open.overrideFor(OperatingSystem.windows, () => DynamicLibrary.open('winsqlite3.dll'));
    }
  });

  const userId = '00000000-0000-0000-0000-0000000000aa';
  const deviceId = '00000000-0000-0000-0000-0000000000bb';
  final now = DateTime.utc(2026, 9, 1);

  late AppDatabase db;
  late String categoryId;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.provisionLocalUser(userId: userId, deviceId: deviceId, nama: 'A', apiKeyHash: 'h');
    categoryId = DeterministicId.seedActivityCategory(userId, 'kuliah');
  });
  tearDown(() => db.close());

  Future<String> insertSchedule({
    bool isRecurring = true,
    int? hari = 1,
    String? tanggalSpesifik,
    bool isActive = true,
  }) async {
    final id = DeterministicId.v4();
    await db.timeboxDao.insertSchedule(TimeboxScheduleCompanion.insert(
      id: id,
      createdAt: now,
      updatedAt: now,
      userId: userId,
      judul: 'Kelas Basis Data',
      activityCategoryId: categoryId,
      startTime: '09:00:00',
      endTime: '10:00:00',
      hari: Value(hari),
      tanggalSpesifik: Value(tanggalSpesifik),
      isRecurring: isRecurring,
      isActive: Value(isActive),
    ));
    return id;
  }

  /// Inserts one pending execution directly (bypassing the materializer,
  /// which has its own dedicated pure-function tests) using the same
  /// deterministic id scheme it would produce, so DAO-command tests can focus
  /// purely on the command invariants.
  Future<String> insertExecution({
    required String scheduleId,
    DateTime? plannedStart,
    DateTime? plannedEnd,
    String occurrenceDate = '2026-09-07',
  }) async {
    final start = plannedStart ?? DateTime.utc(2026, 9, 7, 2); // 09:00 WIB
    final end = plannedEnd ?? start.add(const Duration(hours: 1));
    final id = DeterministicId.timeboxExecution(scheduleId, TzResolver.toContractUtc(start));
    await db.into(db.timeboxExecution).insert(TimeboxExecutionCompanion.insert(
          id: id,
          createdAt: now,
          updatedAt: now,
          scheduleId: scheduleId,
          occurrenceDate: occurrenceDate,
          plannedStartAt: start,
          plannedEndAt: end,
          status: TimeboxExecutionStatus.pending,
        ));
    return id;
  }

  group('complete', () {
    test('creates exactly one deterministic Activity and stamps activity_id', () async {
      final scheduleId = await insertSchedule();
      final execId = await insertExecution(scheduleId: scheduleId);

      final activityId = await db.timeboxDao.complete(execId);

      expect(activityId, DeterministicId.derivedActivity('timebox', execId));
      final activity = await (db.select(db.activity)..where((a) => a.id.equals(activityId)))
          .getSingle();
      expect(activity.source, ActivitySource.timebox);
      expect(activity.sourceId, execId);
      expect(activity.status, ActivityStatus.selesai);
      expect(activity.activityCategoryId, categoryId);

      final execution =
          await (db.select(db.timeboxExecution)..where((e) => e.id.equals(execId))).getSingle();
      expect(execution.status, TimeboxExecutionStatus.completed);
      expect(execution.activityId, activityId);
      expect(execution.actualEndAt, isNotNull);
    });

    test('cannot be completed twice (guards double-Activity creation)', () async {
      final scheduleId = await insertSchedule();
      final execId = await insertExecution(scheduleId: scheduleId);
      await db.timeboxDao.complete(execId);

      expect(
        () => db.timeboxDao.complete(execId),
        throwsA(isA<TimeboxCommandException>()),
      );
      // Still exactly one Activity for this source.
      final activities =
          await (db.select(db.activity)..where((a) => a.sourceId.equals(execId))).get();
      expect(activities, hasLength(1));
    });

    test('a second Activity with the same (source, source_id) is rejected at the DB level '
        '(uq_activity_source backstop)', () async {
      final scheduleId = await insertSchedule();
      final execId = await insertExecution(scheduleId: scheduleId);
      await db.timeboxDao.complete(execId);

      final dupe = ActivityCompanion.insert(
        id: DeterministicId.v4(),
        createdAt: now,
        updatedAt: now,
        userId: userId,
        occurrenceDate: '2026-09-07',
        judul: 'Duplicate',
        activityCategoryId: categoryId,
        status: ActivityStatus.selesai,
        source: ActivitySource.timebox,
        sourceId: Value(execId),
      );
      await expectLater(
        db.activityDao.insertActivity(dupe),
        throwsA(isA<SqliteException>()),
      );
    });
  });

  group('skip', () {
    test('never flips TimeboxSchedule.is_active and creates no Activity', () async {
      final scheduleId = await insertSchedule(isActive: true);
      final execId = await insertExecution(scheduleId: scheduleId);

      await db.timeboxDao.skip(execId);

      final execution =
          await (db.select(db.timeboxExecution)..where((e) => e.id.equals(execId))).getSingle();
      expect(execution.status, TimeboxExecutionStatus.skipped);
      expect(execution.activityId, isNull);

      final schedule =
          await (db.select(db.timeboxSchedule)..where((s) => s.id.equals(scheduleId))).getSingle();
      expect(schedule.isActive, isTrue,
          reason: 'FR-3.12: skipping one occurrence must not deactivate the template');
    });

    test('skipped is a distinct terminal status from missed (not double-counted)', () async {
      final scheduleId = await insertSchedule();
      final execId = await insertExecution(scheduleId: scheduleId);
      await db.timeboxDao.skip(execId);

      final execution =
          await (db.select(db.timeboxExecution)..where((e) => e.id.equals(execId))).getSingle();
      expect(execution.status, isNot(TimeboxExecutionStatus.missed));
    });
  });

  group('reschedule', () {
    test('creates a destination pending execution and marks the source rescheduled, '
        'preserving the planned duration', () async {
      final scheduleId = await insertSchedule();
      final sourceId = await insertExecution(
        scheduleId: scheduleId,
        plannedStart: DateTime.utc(2026, 9, 7, 2),
        plannedEnd: DateTime.utc(2026, 9, 7, 3, 30), // 90 minutes
      );
      final target = DateTime.utc(2026, 9, 8, 2);

      final destinationId = await db.timeboxDao.reschedule(
        sourceExecutionId: sourceId,
        targetStart: target,
        targetOccurrenceDate: '2026-09-08',
      );

      final source =
          await (db.select(db.timeboxExecution)..where((e) => e.id.equals(sourceId))).getSingle();
      expect(source.status, TimeboxExecutionStatus.rescheduled);
      expect(source.rescheduledToId, destinationId);

      final destination = await (db.select(db.timeboxExecution)
            ..where((e) => e.id.equals(destinationId)))
          .getSingle();
      expect(destination.status, TimeboxExecutionStatus.pending);
      expect(destination.scheduleId, scheduleId);
      expect(destination.plannedStartAt.isAtSameMomentAs(target), isTrue);
      expect(
          destination.plannedEndAt.difference(destination.plannedStartAt),
          const Duration(minutes: 90),
          reason: 'reschedule must preserve the source\'s planned duration');
    });

    test('rejects a target equal to the source\'s own planned_start_at', () async {
      final scheduleId = await insertSchedule();
      final start = DateTime.utc(2026, 9, 7, 2);
      final sourceId = await insertExecution(scheduleId: scheduleId, plannedStart: start);

      expect(
        () => db.timeboxDao.reschedule(
          sourceExecutionId: sourceId,
          targetStart: start,
          targetOccurrenceDate: '2026-09-07',
        ),
        throwsA(isA<TimeboxCommandException>()),
      );
    });

    test('rejects a target colliding with another active execution of the same schedule',
        () async {
      final scheduleId = await insertSchedule();
      final sourceId = await insertExecution(
        scheduleId: scheduleId,
        plannedStart: DateTime.utc(2026, 9, 7, 2),
      );
      final collisionTarget = DateTime.utc(2026, 9, 8, 2);
      await insertExecution(
        scheduleId: scheduleId,
        plannedStart: collisionTarget,
        occurrenceDate: '2026-09-08',
      );

      expect(
        () => db.timeboxDao.reschedule(
          sourceExecutionId: sourceId,
          targetStart: collisionTarget,
          targetOccurrenceDate: '2026-09-08',
        ),
        throwsA(isA<TimeboxCommandException>()),
      );
    });

    test('is atomic: a rejected reschedule leaves the source untouched', () async {
      final scheduleId = await insertSchedule();
      final start = DateTime.utc(2026, 9, 7, 2);
      final sourceId = await insertExecution(scheduleId: scheduleId, plannedStart: start);

      await expectLater(
        db.timeboxDao.reschedule(
          sourceExecutionId: sourceId,
          targetStart: start,
          targetOccurrenceDate: '2026-09-07',
        ),
        throwsA(isA<TimeboxCommandException>()),
      );

      final source =
          await (db.select(db.timeboxExecution)..where((e) => e.id.equals(sourceId))).getSingle();
      expect(source.status, TimeboxExecutionStatus.pending,
          reason: 'a rejected reschedule must not partially mutate the source');
    });
  });

  group('unique active (schedule_id, planned_start_at)', () {
    test('a second active execution at the same instant for the same schedule is rejected',
        () async {
      final scheduleId = await insertSchedule();
      final start = DateTime.utc(2026, 9, 7, 2);
      await insertExecution(scheduleId: scheduleId, plannedStart: start);

      final dupe = TimeboxExecutionCompanion.insert(
        id: DeterministicId.v4(),
        createdAt: now,
        updatedAt: now,
        scheduleId: scheduleId,
        occurrenceDate: '2026-09-07',
        plannedStartAt: start,
        plannedEndAt: start.add(const Duration(hours: 1)),
        status: TimeboxExecutionStatus.pending,
      );
      await expectLater(
        db.into(db.timeboxExecution).insert(dupe),
        throwsA(isA<SqliteException>()),
      );
    });

    test('a soft-deleted row does not block a new active row at the same instant', () async {
      final scheduleId = await insertSchedule();
      final start = DateTime.utc(2026, 9, 7, 2);
      final firstId = await insertExecution(scheduleId: scheduleId, plannedStart: start);
      await db.timeboxDao.softDeleteExecution(firstId);

      final replacement = TimeboxExecutionCompanion.insert(
        id: DeterministicId.v4(),
        createdAt: now,
        updatedAt: now,
        scheduleId: scheduleId,
        occurrenceDate: '2026-09-07',
        plannedStartAt: start,
        plannedEndAt: start.add(const Duration(hours: 1)),
        status: TimeboxExecutionStatus.pending,
      );
      await expectLater(db.into(db.timeboxExecution).insert(replacement), completes);
    });
  });

  group('materialization idempotency (deterministic id)', () {
    test('the same (schedule_id, planned_start_at) always derives the same execution id',
        () async {
      final scheduleId = await insertSchedule();
      final start = DateTime.utc(2026, 9, 7, 2);
      final idA = DeterministicId.timeboxExecution(scheduleId, TzResolver.toContractUtc(start));
      final idB = DeterministicId.timeboxExecution(scheduleId, TzResolver.toContractUtc(start));
      expect(idA, idB);
    });
  });
}
