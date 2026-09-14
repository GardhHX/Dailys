import 'dart:ffi';
import 'dart:io';

import 'package:dailys/core/db/daos/timebox_dao.dart';
import 'package:dailys/core/db/database.dart';
import 'package:dailys/core/db/tables/enums.dart';
import 'package:dailys/core/ids/deterministic_id.dart';
import 'package:dailys/core/notifications/timebox_reminder_plan.dart';
import 'package:dailys/l10n/app_localizations.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(() {
    if (Platform.isWindows) {
      open.overrideFor(OperatingSystem.windows, () => DynamicLibrary.open('winsqlite3.dll'));
    }
    tzdata.initializeTimeZones();
  });

  const userId = '00000000-0000-0000-0000-0000000000aa';
  const deviceId = '00000000-0000-0000-0000-0000000000bb';
  late tz.Location jakarta;
  late AppLocalizations l10n;
  setUpAll(() {
    jakarta = tz.getLocation('Asia/Jakarta');
    l10n = lookupAppLocalizations(const Locale('en'));
  });

  late AppDatabase db;
  late String categoryId;
  final now = DateTime.utc(2026, 9, 1);
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.provisionLocalUser(userId: userId, deviceId: deviceId, nama: 'A', apiKeyHash: 'h');
    categoryId = DeterministicId.seedActivityCategory(userId, 'kuliah');
  });
  tearDown(() => db.close());

  Future<TimeboxOccurrence> insertOccurrence({
    List<int> offsets = const [],
    TimeboxExecutionStatus status = TimeboxExecutionStatus.pending,
    DateTime? plannedStart,
  }) async {
    final scheduleId = DeterministicId.v4();
    await db.timeboxDao.insertSchedule(TimeboxScheduleCompanion.insert(
      id: scheduleId,
      createdAt: now,
      updatedAt: now,
      userId: userId,
      judul: 'Kelas',
      activityCategoryId: categoryId,
      startTime: '09:00:00',
      endTime: '10:00:00',
      hari: const Value(1),
      isRecurring: true,
      reminderOffsetsMinutes: Value(offsets),
    ));
    final start = plannedStart ?? DateTime.utc(2026, 9, 7, 2); // 09:00 WIB
    final execId = DeterministicId.v4();
    await db.into(db.timeboxExecution).insert(TimeboxExecutionCompanion.insert(
          id: execId,
          createdAt: now,
          updatedAt: now,
          scheduleId: scheduleId,
          occurrenceDate: '2026-09-07',
          plannedStartAt: start,
          plannedEndAt: start.add(const Duration(hours: 1)),
          status: status,
        ));
    final execution =
        await (db.select(db.timeboxExecution)..where((e) => e.id.equals(execId))).getSingle();
    final schedule = await (db.select(db.timeboxSchedule)..where((s) => s.id.equals(scheduleId)))
        .getSingle();
    return TimeboxOccurrence(execution: execution, schedule: schedule);
  }

  test('one PlannedReminder per schedule offset, fireAt = planned_start_at - offset', () async {
    final occurrence = await insertOccurrence(offsets: const [10, 30]);
    final planned = planTimeboxReminders(occurrence, l10n: l10n, location: jakarta);
    expect(planned, hasLength(2));
    expect(planned[0].id, 'timebox:${occurrence.execution.id}:10');
    expect(
      planned[0].fireAt.isAtSameMomentAs(
          occurrence.execution.plannedStartAt.subtract(const Duration(minutes: 10))),
      isTrue,
    );
    expect(planned.every((p) => p.title == 'Kelas'), isTrue);
  });

  test('no offsets plans nothing', () async {
    final occurrence = await insertOccurrence();
    expect(planTimeboxReminders(occurrence, l10n: l10n, location: jakarta), isEmpty);
  });

  test('non-pending status plans nothing (missed/skipped/rescheduled stop firing; '
      '`completed` is covered indirectly — it requires a non-null activity_id per the '
      'schema 10.1 CHECK constraint, exercised by TimeboxDao.complete in the contract '
      'test instead)', () async {
    for (final status in [
      TimeboxExecutionStatus.missed,
      TimeboxExecutionStatus.skipped,
      TimeboxExecutionStatus.rescheduled,
    ]) {
      final occurrence = await insertOccurrence(offsets: const [10], status: status);
      expect(planTimeboxReminders(occurrence, l10n: l10n, location: jakarta), isEmpty,
          reason: 'status=$status must not plan a reminder');
    }
  });
}
