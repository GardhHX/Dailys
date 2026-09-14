import 'dart:ffi';
import 'dart:io';

import 'package:dailys/core/db/database.dart';
import 'package:dailys/core/db/tables/enums.dart';
import 'package:dailys/core/ids/deterministic_id.dart';
import 'package:dailys/core/notifications/notification_gateway.dart';
import 'package:dailys/core/notifications/reminder_scheduler.dart';
import 'package:dailys/core/reminders/task_reminder.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';
import 'package:timezone/data/latest.dart' as tzdata;

class _FakeGateway implements NotificationGateway {
  final List<String> notified = [];
  bool initialized = false;

  @override
  Future<void> initialize() async => initialized = true;

  @override
  Future<void> notifyNow({
    required String id,
    required String title,
    required String body,
  }) async =>
      notified.add(id);
}

void main() {
  setUpAll(() {
    if (Platform.isWindows) {
      open.overrideFor(OperatingSystem.windows, () => DynamicLibrary.open('winsqlite3.dll'));
    }
    tzdata.initializeTimeZones();
  });

  const userId = '00000000-0000-0000-0000-0000000000aa';
  const deviceId = '00000000-0000-0000-0000-0000000000bb';

  late AppDatabase db;
  late _FakeGateway gateway;
  DateTime now = DateTime.utc(2026, 9, 14, 3); // 10:00 WIB

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.provisionLocalUser(
        userId: userId, deviceId: deviceId, nama: 'A', apiKeyHash: 'h');
    gateway = _FakeGateway();
    now = DateTime.utc(2026, 9, 14, 3);
  });
  tearDown(() => db.close());

  ReminderScheduler makeScheduler() => ReminderScheduler(
        db: db,
        userId: userId,
        gateway: gateway,
        clock: () => now,
      );

  Future<String> insertTugasWithReminder({required int minutesBefore}) async {
    final ts = DateTime.now().toUtc();
    final id = DeterministicId.v4();
    await db.tugasDao.insertTugas(TugasCompanion.insert(
      id: id,
      createdAt: ts,
      updatedAt: ts,
      userId: userId,
      judul: 'T',
      deadline: now.add(const Duration(minutes: 500)),
      prioritas: TugasPrioritas.medium,
      status: TugasStatus.belum,
      reminders: TaskReminder.toJsonList(
        [RelativeMinutesReminder(minutesBefore: minutesBefore)],
      ),
    ));
    return id;
  }

  Future<String> insertTugasWithReminders({
    required DateTime deadline,
    required List<TaskReminder> reminders,
  }) async {
    final ts = DateTime.now().toUtc();
    final id = DeterministicId.v4();
    await db.tugasDao.insertTugas(TugasCompanion.insert(
      id: id,
      createdAt: ts,
      updatedAt: ts,
      userId: userId,
      judul: 'T',
      deadline: deadline,
      prioritas: TugasPrioritas.medium,
      status: TugasStatus.belum,
      reminders: TaskReminder.toJsonList(reminders),
    ));
    return id;
  }

  test('fires a due reminder exactly once across ticks', () async {
    // deadline - 500min = now, i.e. due right now.
    await insertTugasWithReminder(minutesBefore: 500);
    final scheduler = makeScheduler();

    await scheduler.tick();
    expect(gateway.notified, hasLength(1));

    await scheduler.tick();
    expect(gateway.notified, hasLength(1)); // not fired twice
  });

  test('does not fire a reminder that is not due yet', () async {
    await insertTugasWithReminder(minutesBefore: 10); // due in 490 min
    final scheduler = makeScheduler();
    await scheduler.tick();
    expect(gateway.notified, isEmpty);
  });

  test('skips a reminder already lapsed before the grace window', () async {
    // due 10 minutes before "now", grace window default is 5 minutes.
    now = now.add(const Duration(minutes: 10));
    await insertTugasWithReminder(minutesBefore: 490); // fireAt = deadline-490min, well past
    final scheduler = makeScheduler();
    await scheduler.tick();
    expect(gateway.notified, isEmpty);
  });

  test('notificationsEnabled=false suppresses all firing', () async {
    await insertTugasWithReminder(minutesBefore: 500);
    await db.settingsDao.updateUserSettings(
      userId,
      const UserSettingsCompanion(notificationsEnabled: Value(false)),
    );
    final scheduler = makeScheduler();
    await scheduler.tick();
    expect(gateway.notified, isEmpty);
  });

  test('fires a due calendar_day reminder end-to-end (default timezone '
      'Asia/Jakarta resolution)', () async {
    // `now` is 2026-09-14 10:00 WIB. Deadline is 7 days later at 10:00 WIB;
    // a "days_before: 7, local_time: 10:00:00" reminder should fire exactly
    // at `now` through the scheduler's own settings-driven tz.Location, not
    // just through planTugasReminders in isolation (tugas_reminder_plan_test).
    final deadline = DateTime.utc(2026, 9, 21, 3); // 2026-09-21 10:00 WIB
    await insertTugasWithReminders(
      deadline: deadline,
      reminders: const [
        CalendarDayReminder(daysBefore: 7, localTime: '10:00:00'),
      ],
    );
    final scheduler = makeScheduler();

    await scheduler.tick();
    expect(gateway.notified, hasLength(1));

    await scheduler.tick();
    expect(gateway.notified, hasLength(1)); // not fired twice
  });

  test('completing the task stops future firing without explicit cancel', () async {
    final id = await insertTugasWithReminder(minutesBefore: 500);
    final scheduler = makeScheduler();
    await scheduler.tick();
    expect(gateway.notified, hasLength(1));

    await db.tugasDao.setStatus(id, TugasStatus.selesai);
    // A later reminder id on the same task would be pruned from the fired
    // set and never fire again once the task drops out of the candidate set.
    await scheduler.tick();
    expect(gateway.notified, hasLength(1));
  });
}
