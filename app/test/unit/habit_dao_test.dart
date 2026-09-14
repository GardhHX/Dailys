import 'dart:ffi';
import 'dart:io';

import 'package:dailys/core/db/daos/habit_dao.dart';
import 'package:dailys/core/db/database.dart';
import 'package:dailys/core/db/tables/enums.dart';
import 'package:dailys/core/ids/deterministic_id.dart';
import 'package:dailys/core/time/local_date.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';

/// Contract tests for HabitDao commands (schema.md 11, 11.1, 11.2, FR-5.*):
/// schedule versioning/atomic neighbor adjustment, unique-active constraints,
/// HabitLog <-> derived Activity transitions (FR-5.15), and streak recompute
/// wiring to `core/projections/streak.dart`.
void main() {
  setUpAll(() {
    if (Platform.isWindows) {
      open.overrideFor(
          OperatingSystem.windows, () => DynamicLibrary.open('winsqlite3.dll'));
    }
  });

  const userId = '00000000-0000-0000-0000-0000000000aa';
  const deviceId = '00000000-0000-0000-0000-0000000000bb';

  late AppDatabase db;
  late String categoryId;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.provisionLocalUser(
        userId: userId, deviceId: deviceId, nama: 'A', apiKeyHash: 'h');
    categoryId = DeterministicId.seedActivityCategory(userId, 'personal');
  });
  tearDown(() => db.close());

  test('createHabit makes Habit + first active HabitSchedule', () async {
    final today = LocalDate.parse('2026-09-07');
    final id = await db.habitDao.createHabit(
      userId: userId,
      nama: 'Lari pagi',
      warna: '#4C6FFF',
      targetHari: const {1, 3, 5},
      today: today,
    );
    final habit = await db.habitDao.getHabit(id);
    expect(habit!.nama, 'Lari pagi');
    expect(habit.currentStreak, 0);
    expect(habit.longestStreak, 0);
    expect(habit.isArchived, isFalse);

    final schedules = await db.habitDao.getSchedules(id);
    expect(schedules, hasLength(1));
    expect(schedules.single.effectiveFrom, '2026-09-07');
    expect(schedules.single.effectiveTo, isNull);
    expect(schedules.single.targetHari, [1, 3, 5]);
    expect(schedules.single.state, HabitScheduleState.active);
  });

  test('unique active (habit_id, effective_from) rejects a duplicate insert',
      () async {
    final today = LocalDate.parse('2026-09-07');
    final id = await db.habitDao.createHabit(
      userId: userId,
      nama: 'Lari pagi',
      warna: '#4C6FFF',
      targetHari: const {1, 3, 5},
      today: today,
    );
    await expectLater(
      db.into(db.habitSchedule).insert(HabitScheduleCompanion.insert(
            id: DeterministicId.v4(),
            createdAt: DateTime.now().toUtc(),
            updatedAt: DateTime.now().toUtc(),
            habitId: id,
            effectiveFrom: '2026-09-07',
            targetHari: const [2, 4],
            state: HabitScheduleState.active,
          )),
      throwsException,
    );
  });

  test('updateSchedule creates a new version and closes the old one',
      () async {
    final today = LocalDate.parse('2026-09-07');
    final id = await db.habitDao.createHabit(
      userId: userId,
      nama: 'Lari pagi',
      warna: '#4C6FFF',
      targetHari: const {1, 3, 5},
      today: today,
    );

    await db.habitDao.updateSchedule(
      habitId: id,
      targetHari: const {2, 4},
      maxIzinPerMinggu: 2,
      effectiveFrom: LocalDate.parse('2026-09-10'),
      today: today,
    );

    final schedules = await db.habitDao.getSchedules(id);
    expect(schedules, hasLength(2));
    expect(schedules[0].effectiveFrom, '2026-09-07');
    expect(schedules[0].effectiveTo, '2026-09-09');
    expect(schedules[1].effectiveFrom, '2026-09-10');
    expect(schedules[1].effectiveTo, isNull);
    expect(schedules[1].targetHari, [2, 4]);
    expect(schedules[1].maxIzinPerMinggu, 2);
  });

  test('updateSchedule rejects an effective date before today', () async {
    final today = LocalDate.parse('2026-09-07');
    final id = await db.habitDao.createHabit(
      userId: userId,
      nama: 'Lari pagi',
      warna: '#4C6FFF',
      targetHari: const {1, 3, 5},
      today: today,
    );
    expect(
      () => db.habitDao.updateSchedule(
        habitId: id,
        targetHari: const {2, 4},
        maxIzinPerMinggu: 1,
        effectiveFrom: LocalDate.parse('2026-09-06'),
        today: today,
      ),
      throwsA(isA<HabitCommandException>()),
    );
  });

  test(
      'setArchived pauses effective today, updates the is_archived cache, and resume does not backfill logs',
      () async {
    final today = LocalDate.parse('2026-09-07');
    final id = await db.habitDao.createHabit(
      userId: userId,
      nama: 'Lari pagi',
      warna: '#4C6FFF',
      targetHari: const {1, 3, 5},
      today: today,
    );

    await db.habitDao.setArchived(
        habitId: id, isArchived: true, today: today);
    var habit = await db.habitDao.getHabit(id);
    expect(habit!.isArchived, isTrue);
    var schedules = await db.habitDao.getSchedules(id);
    expect(schedules.last.state, HabitScheduleState.paused);

    final resumeDay = LocalDate.parse('2026-09-14');
    await db.habitDao.setArchived(
        habitId: id, isArchived: false, today: resumeDay);
    habit = await db.habitDao.getHabit(id);
    expect(habit!.isArchived, isFalse);
    schedules = await db.habitDao.getSchedules(id);
    expect(schedules.last.state, HabitScheduleState.active);

    // Resume does not create logs for the paused period.
    final logs = await db.habitDao.getLogs(id);
    expect(logs, isEmpty);
  });

  test('HabitLog done creates exactly one derived Activity (exactly-once)',
      () async {
    final today = LocalDate.parse('2026-09-07');
    final id = await db.habitDao.createHabit(
      userId: userId,
      nama: 'Lari pagi',
      warna: '#4C6FFF',
      targetHari: const {1, 3, 5},
      today: today,
    );

    await db.habitDao.upsertLog(
      habitId: id,
      tanggal: today,
      status: HabitLogStatus.done,
      activityCategoryId: categoryId,
      today: today,
    );
    // Idempotent re-application (e.g. a retried sync mutation) must not
    // create a second Activity.
    await db.habitDao.upsertLog(
      habitId: id,
      tanggal: today,
      status: HabitLogStatus.done,
      activityCategoryId: categoryId,
      catatan: 'lanjut',
      today: today,
    );

    final activities = await db.activityDao.watchActivitiesForDate(
        userId, today.toYmd()).first;
    expect(activities, hasLength(1));
    expect(activities.single.source, ActivitySource.habit);
    expect(activities.single.catatan, 'lanjut');

    final habit = await db.habitDao.getHabit(id);
    expect(habit!.currentStreak, 1);
    expect(habit.longestStreak, 1);
  });

  test('done -> skip tombstones the Activity; skip -> done restores it',
      () async {
    final today = LocalDate.parse('2026-09-07');
    final id = await db.habitDao.createHabit(
      userId: userId,
      nama: 'Lari pagi',
      warna: '#4C6FFF',
      targetHari: const {1, 3, 5},
      today: today,
    );
    await db.habitDao.upsertLog(
      habitId: id,
      tanggal: today,
      status: HabitLogStatus.done,
      activityCategoryId: categoryId,
      today: today,
    );
    var activities = await db.activityDao
        .watchActivitiesForDate(userId, today.toYmd())
        .first;
    expect(activities, hasLength(1));

    await db.habitDao.upsertLog(
      habitId: id,
      tanggal: today,
      status: HabitLogStatus.skip,
      today: today,
    );
    activities = await db.activityDao
        .watchActivitiesForDate(userId, today.toYmd())
        .first;
    expect(activities, isEmpty, reason: 'tombstoned, not visible to active query');

    await db.habitDao.upsertLog(
      habitId: id,
      tanggal: today,
      status: HabitLogStatus.done,
      activityCategoryId: categoryId,
      today: today,
    );
    activities = await db.activityDao
        .watchActivitiesForDate(userId, today.toYmd())
        .first;
    expect(activities, hasLength(1));
    // Same deterministic id restored, not a second Activity row.
    expect(activities.single.id,
        DeterministicId.derivedActivity('habit', DeterministicId.habitLog(id, today.toYmd())));
  });

  test('unique active (habit_id, tanggal) rejects a duplicate insert',
      () async {
    final today = LocalDate.parse('2026-09-07');
    final id = await db.habitDao.createHabit(
      userId: userId,
      nama: 'Lari pagi',
      warna: '#4C6FFF',
      targetHari: const {1, 3, 5},
      today: today,
    );
    await db.habitDao.upsertLog(
      habitId: id,
      tanggal: today,
      status: HabitLogStatus.missed,
      today: today,
    );
    await expectLater(
      db.into(db.habitLog).insert(HabitLogCompanion.insert(
            id: DeterministicId.v4(),
            createdAt: DateTime.now().toUtc(),
            updatedAt: DateTime.now().toUtc(),
            habitId: id,
            tanggal: today.toYmd(),
            status: HabitLogStatus.missed,
          )),
      throwsException,
    );
  });

  test('skip beyond the weekly quota is still recorded but breaks the streak',
      () async {
    final today = LocalDate.parse('2026-09-07');
    final id = await db.habitDao.createHabit(
      userId: userId,
      nama: 'Lari pagi',
      warna: '#4C6FFF',
      targetHari: const {1, 3, 5},
      maxIzinPerMinggu: 1,
      today: today,
    );
    await db.habitDao.upsertLog(
      habitId: id,
      tanggal: LocalDate.parse('2026-09-07'),
      status: HabitLogStatus.done,
      activityCategoryId: categoryId,
      today: LocalDate.parse('2026-09-07'),
    );
    await db.habitDao.upsertLog(
      habitId: id,
      tanggal: LocalDate.parse('2026-09-09'),
      status: HabitLogStatus.skip,
      today: LocalDate.parse('2026-09-09'),
    );
    await db.habitDao.upsertLog(
      habitId: id,
      tanggal: LocalDate.parse('2026-09-11'),
      status: HabitLogStatus.skip,
      today: LocalDate.parse('2026-09-11'),
    );
    final habit = await db.habitDao.getHabit(id);
    expect(habit!.currentStreak, 0);
    expect(habit.longestStreak, 1);
  });

  test('softDeleteHabit cascade-tombstones schedules and logs', () async {
    final today = LocalDate.parse('2026-09-07');
    final id = await db.habitDao.createHabit(
      userId: userId,
      nama: 'Lari pagi',
      warna: '#4C6FFF',
      targetHari: const {1, 3, 5},
      today: today,
    );
    await db.habitDao.upsertLog(
      habitId: id,
      tanggal: today,
      status: HabitLogStatus.done,
      activityCategoryId: categoryId,
      today: today,
    );

    await db.habitDao.softDeleteHabit(id);

    final habit = await db.habitDao.getHabit(id);
    expect(habit!.isDeleted, isTrue);
    expect(await db.habitDao.getSchedules(id), isEmpty);
    expect(await db.habitDao.getLogs(id), isEmpty);
    // Derived Activity history is retained, not tombstoned.
    final activities = await db.activityDao
        .watchActivitiesForDate(userId, today.toYmd())
        .first;
    expect(activities, hasLength(1));
  });

  test('reorder writes the given order into urutan', () async {
    final today = LocalDate.parse('2026-09-07');
    final a = await db.habitDao.createHabit(
        userId: userId,
        nama: 'A',
        warna: '#4C6FFF',
        targetHari: const {1},
        today: today);
    final b = await db.habitDao.createHabit(
        userId: userId,
        nama: 'B',
        warna: '#4C6FFF',
        targetHari: const {1},
        today: today);
    expect((await db.habitDao.getHabit(a))!.urutan, 0);
    expect((await db.habitDao.getHabit(b))!.urutan, 1);

    await db.habitDao.reorder([b, a]);
    expect((await db.habitDao.getHabit(b))!.urutan, 0);
    expect((await db.habitDao.getHabit(a))!.urutan, 1);
  });
}
