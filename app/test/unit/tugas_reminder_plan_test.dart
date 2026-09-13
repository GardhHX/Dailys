import 'dart:ffi';
import 'dart:io';

import 'package:dailys/core/db/database.dart';
import 'package:dailys/core/db/tables/enums.dart';
import 'package:dailys/core/ids/deterministic_id.dart';
import 'package:dailys/core/notifications/tugas_reminder_plan.dart';
import 'package:dailys/core/reminders/task_reminder.dart';
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
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.provisionLocalUser(
        userId: userId, deviceId: deviceId, nama: 'A', apiKeyHash: 'h');
  });
  tearDown(() => db.close());

  Future<TugasRow> insertTugas({
    required String judul,
    required DateTime deadline,
    TugasStatus status = TugasStatus.belum,
    List<TaskReminder> reminders = const [],
  }) async {
    final ts = DateTime.now().toUtc();
    final id = DeterministicId.v4();
    await db.tugasDao.insertTugas(TugasCompanion.insert(
      id: id,
      createdAt: ts,
      updatedAt: ts,
      userId: userId,
      judul: judul,
      deadline: deadline,
      prioritas: TugasPrioritas.medium,
      status: status,
      // completed_at is required iff status = selesai (schema 5 CHECK).
      completedAt: Value(status == TugasStatus.selesai ? ts : null),
      reminders: TaskReminder.toJsonList(reminders),
    ));
    return (db.select(db.tugas)..where((t) => t.id.equals(id))).getSingle();
  }

  test('selesai tasks never plan reminders', () async {
    final row = await insertTugas(
      judul: 'Done',
      deadline: DateTime.utc(2026, 9, 20),
      status: TugasStatus.selesai,
      reminders: const [RelativeMinutesReminder(minutesBefore: 120)],
    );
    expect(planTugasReminders(row, l10n: l10n, location: jakarta), isEmpty);
  });

  test('empty reminders plans nothing', () async {
    final row = await insertTugas(judul: 'No reminders', deadline: DateTime.utc(2026, 9, 20));
    expect(planTugasReminders(row, l10n: l10n, location: jakarta), isEmpty);
  });

  test('relative_minutes fires deadline - minutes', () async {
    final deadline = DateTime.utc(2026, 9, 20, 3); // 10:00 WIB
    final row = await insertTugas(
      judul: 'Tugas A',
      deadline: deadline,
      reminders: const [RelativeMinutesReminder(minutesBefore: 120)],
    );
    final planned = planTugasReminders(row, l10n: l10n, location: jakarta);
    expect(planned, hasLength(1));
    expect(planned.single.id, 'tugas:${row.id}:relative_minutes:120');
    // isAtSameMomentAs, not `==`: Drift reads DateTime back with `isUtc:
    // false` even though the instant is identical, and plain `==` treats
    // that as unequal.
    expect(planned.single.fireAt.isAtSameMomentAs(deadline.subtract(const Duration(minutes: 120))),
        isTrue);
  });

  test('calendar_day fires on deadline local date - days_before at local_time', () async {
    final deadline = DateTime.utc(2026, 9, 20, 3); // 2026-09-20 10:00 WIB
    final row = await insertTugas(
      judul: 'Tugas B',
      deadline: deadline,
      reminders: const [CalendarDayReminder(daysBefore: 7, localTime: '09:00:00')],
    );
    final planned = planTugasReminders(row, l10n: l10n, location: jakarta);
    expect(planned, hasLength(1));
    // 2026-09-13 09:00 WIB (UTC+7) = 2026-09-13 02:00 UTC.
    expect(planned.single.fireAt.isAtSameMomentAs(DateTime.utc(2026, 9, 13, 2)), isTrue);
  });

  test('multiple reminders each get a distinct id', () async {
    final row = await insertTugas(
      judul: 'Tugas C',
      deadline: DateTime.utc(2026, 9, 20, 3),
      reminders: TaskReminder.defaults(),
    );
    final planned = planTugasReminders(row, l10n: l10n, location: jakarta);
    expect(planned, hasLength(4));
    expect(planned.map((p) => p.id).toSet(), hasLength(4));
  });
}
