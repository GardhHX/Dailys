import 'dart:ffi';
import 'dart:io';

import 'package:dailys/core/db/daos/pomodoro_dao.dart';
import 'package:dailys/core/db/database.dart';
import 'package:dailys/core/db/tables/enums.dart';
import 'package:dailys/core/ids/deterministic_id.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';

/// Contract tests for PomodoroSession commands (schema.md Section 9,
/// FR-2.7-2.12): pause/resume accumulation, completion's single derived
/// Activity for `fokus` only, and the command-guard invariants.
void main() {
  setUpAll(() {
    if (Platform.isWindows) {
      open.overrideFor(OperatingSystem.windows, () => DynamicLibrary.open('winsqlite3.dll'));
    }
  });

  const userId = '00000000-0000-0000-0000-0000000000aa';
  const deviceId = '00000000-0000-0000-0000-0000000000bb';

  late AppDatabase db;
  late String categoryId;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.provisionLocalUser(userId: userId, deviceId: deviceId, nama: 'A', apiKeyHash: 'h');
    categoryId = DeterministicId.seedActivityCategory(userId, 'personal');
  });
  tearDown(() => db.close());

  test('start creates a running fokus session', () async {
    final start = DateTime.utc(2026, 9, 7, 2);
    final id = await db.pomodoroDao.start(
      userId: userId,
      durasiMenit: 25,
      jenis: PomodoroJenis.fokus,
      now: start,
    );
    final row = await db.pomodoroDao.getById(id);
    expect(row!.status, PomodoroStatus.running);
    // isAtSameMomentAs, not `==`: Drift reads DateTime back with `isUtc:
    // false` even though the instant is identical, and plain `==` treats
    // that as unequal.
    expect(row.startTime.isAtSameMomentAs(start), isTrue);
    expect(row.accumulatedPauseSeconds, 0);
    expect(row.pausedAt, isNull);
  });

  test('pause stores paused_at; resume adds the pause length to the accumulator', () async {
    final start = DateTime.utc(2026, 9, 7, 2);
    final id = await db.pomodoroDao
        .start(userId: userId, durasiMenit: 25, jenis: PomodoroJenis.fokus, now: start);

    await db.pomodoroDao.pause(id, now: start.add(const Duration(minutes: 5)));
    var row = await db.pomodoroDao.getById(id);
    expect(row!.status, PomodoroStatus.paused);
    expect(row.pausedAt!.isAtSameMomentAs(start.add(const Duration(minutes: 5))), isTrue);

    await db.pomodoroDao.resume(id, now: start.add(const Duration(minutes: 8)));
    row = await db.pomodoroDao.getById(id);
    expect(row!.status, PomodoroStatus.running);
    expect(row.pausedAt, isNull);
    expect(row.accumulatedPauseSeconds, const Duration(minutes: 3).inSeconds);
  });

  test('pause only from running; resume only from paused', () async {
    final id = await db.pomodoroDao
        .start(userId: userId, durasiMenit: 25, jenis: PomodoroJenis.fokus);
    expect(() => db.pomodoroDao.resume(id), throwsA(isA<PomodoroCommandException>()));

    await db.pomodoroDao.pause(id);
    expect(() => db.pomodoroDao.pause(id), throwsA(isA<PomodoroCommandException>()));
  });

  group('complete', () {
    test('a fokus session creates exactly one Activity with actual_seconds excluding pause',
        () async {
      final start = DateTime.utc(2026, 9, 7, 2);
      final id = await db.pomodoroDao
          .start(userId: userId, durasiMenit: 25, jenis: PomodoroJenis.fokus, now: start);
      await db.pomodoroDao.pause(id, now: start.add(const Duration(minutes: 10)));
      await db.pomodoroDao.resume(id, now: start.add(const Duration(minutes: 15)));
      final end = start.add(const Duration(minutes: 40));

      final activityId = await db.pomodoroDao.complete(
        id,
        now: end,
        activityCategoryId: categoryId,
        occurrenceDate: '2026-09-07',
      );

      expect(activityId, DeterministicId.derivedActivity('pomodoro', id));
      final activities =
          await (db.select(db.activity)..where((a) => a.sourceId.equals(id))).get();
      expect(activities, hasLength(1));
      expect(activities.single.source, ActivitySource.pomodoro);
      expect(activities.single.status, ActivityStatus.selesai);

      final session = await db.pomodoroDao.getById(id);
      expect(session!.status, PomodoroStatus.completed);
      // 40 minutes elapsed - 5 minutes paused = 35 minutes actual.
      expect(session.actualSeconds, const Duration(minutes: 35).inSeconds);
    });

    test('completing while still paused folds the open pause into the accumulator first',
        () async {
      final start = DateTime.utc(2026, 9, 7, 2);
      final id = await db.pomodoroDao
          .start(userId: userId, durasiMenit: 25, jenis: PomodoroJenis.fokus, now: start);
      await db.pomodoroDao.pause(id, now: start.add(const Duration(minutes: 10)));
      final end = start.add(const Duration(minutes: 20)); // completed while paused

      await db.pomodoroDao.complete(
        id,
        now: end,
        activityCategoryId: categoryId,
        occurrenceDate: '2026-09-07',
      );

      final session = await db.pomodoroDao.getById(id);
      // 20 minutes elapsed, all but the first 10 were an open pause.
      expect(session!.actualSeconds, const Duration(minutes: 10).inSeconds);
      expect(session.pausedAt, isNull);
    });

    test('a short/long break session produces no Activity', () async {
      for (final jenis in [PomodoroJenis.istirahat_pendek, PomodoroJenis.istirahat_panjang]) {
        final id = await db.pomodoroDao.start(userId: userId, durasiMenit: 5, jenis: jenis);
        final activityId = await db.pomodoroDao.complete(id);
        expect(activityId, isNull);
        final activities =
            await (db.select(db.activity)..where((a) => a.sourceId.equals(id))).get();
        expect(activities, isEmpty, reason: '$jenis must never produce an Activity');
      }
    });

    test('only from running or paused', () async {
      final id = await db.pomodoroDao
          .start(userId: userId, durasiMenit: 25, jenis: PomodoroJenis.istirahat_pendek);
      await db.pomodoroDao.complete(id);
      expect(() => db.pomodoroDao.complete(id), throwsA(isA<PomodoroCommandException>()));
    });
  });

  group('cancel', () {
    test('produces no Activity even for a fokus session', () async {
      final id = await db.pomodoroDao
          .start(userId: userId, durasiMenit: 25, jenis: PomodoroJenis.fokus);
      await db.pomodoroDao.cancel(id);

      final session = await db.pomodoroDao.getById(id);
      expect(session!.status, PomodoroStatus.cancelled);
      final activities =
          await (db.select(db.activity)..where((a) => a.sourceId.equals(id))).get();
      expect(activities, isEmpty);
    });

    test('folds an open pause into the accumulator like complete does', () async {
      final start = DateTime.utc(2026, 9, 7, 2);
      final id = await db.pomodoroDao
          .start(userId: userId, durasiMenit: 25, jenis: PomodoroJenis.fokus, now: start);
      await db.pomodoroDao.pause(id, now: start.add(const Duration(minutes: 5)));
      await db.pomodoroDao.cancel(id, now: start.add(const Duration(minutes: 12)));

      final session = await db.pomodoroDao.getById(id);
      expect(session!.accumulatedPauseSeconds, const Duration(minutes: 7).inSeconds);
      expect(session.pausedAt, isNull);
    });
  });

  test('getInFlightSession finds a running or paused session but not a terminal one', () async {
    expect(await db.pomodoroDao.getInFlightSession(userId), isNull);
    final id = await db.pomodoroDao
        .start(userId: userId, durasiMenit: 25, jenis: PomodoroJenis.fokus);
    expect((await db.pomodoroDao.getInFlightSession(userId))?.id, id);

    await db.pomodoroDao.cancel(id);
    expect(await db.pomodoroDao.getInFlightSession(userId), isNull);
  });
}
