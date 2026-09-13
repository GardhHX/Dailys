import 'dart:io';
import 'dart:ffi';

import 'package:dailys/core/db/database.dart';
import 'package:dailys/core/db/tables/enums.dart';
import 'package:dailys/core/ids/deterministic_id.dart';
import 'package:dailys/core/notifications/activity_reminder_plan.dart';
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
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.provisionLocalUser(
        userId: userId, deviceId: deviceId, nama: 'A', apiKeyHash: 'h');
    categoryId = DeterministicId.seedActivityCategory(userId, 'kuliah');
  });
  tearDown(() => db.close());

  Future<ActivityRow> insertActivity({
    required String judul,
    bool isAllDay = false,
    DateTime? startTime,
    ActivityStatus status = ActivityStatus.belum_mulai,
    List<int> offsets = const [],
  }) async {
    final ts = DateTime.now().toUtc();
    final id = DeterministicId.v4();
    await db.activityDao.insertActivity(ActivityCompanion.insert(
      id: id,
      createdAt: ts,
      updatedAt: ts,
      userId: userId,
      occurrenceDate: '2026-09-14',
      judul: judul,
      activityCategoryId: categoryId,
      startTime: Value(isAllDay ? null : startTime),
      isAllDay: Value(isAllDay),
      status: status,
      source: ActivitySource.manual,
      reminderOffsetsMinutes: Value(offsets),
    ));
    return (db.select(db.activity)..where((a) => a.id.equals(id))).getSingle();
  }

  test('all-day activities never plan reminders (schema 8 invariant)', () async {
    final row = await insertActivity(judul: 'Libur', isAllDay: true);
    expect(planActivityReminders(row, l10n: l10n, location: jakarta), isEmpty);
  });

  test('no start_time never plans reminders', () async {
    final row = await insertActivity(judul: 'Flexible');
    expect(planActivityReminders(row, l10n: l10n, location: jakarta), isEmpty);
  });

  test('non-belum_mulai status plans nothing', () async {
    final row = await insertActivity(
      judul: 'Done',
      startTime: DateTime.utc(2026, 9, 14, 2),
      offsets: const [30],
      status: ActivityStatus.selesai,
    );
    expect(planActivityReminders(row, l10n: l10n, location: jakarta), isEmpty);
  });

  test('one PlannedReminder per offset, fireAt = start_time - offset', () async {
    final start = DateTime.utc(2026, 9, 14, 2); // 09:00 WIB
    final row = await insertActivity(
      judul: 'Kelas',
      startTime: start,
      offsets: const [10, 30],
    );
    final planned = planActivityReminders(row, l10n: l10n, location: jakarta);
    expect(planned, hasLength(2));
    expect(planned[0].id, 'activity:${row.id}:10');
    // isAtSameMomentAs, not `==`: Drift reads DateTime back with `isUtc:
    // false` even though the instant is identical, and plain `==` treats
    // that as unequal.
    expect(
        planned[0].fireAt.isAtSameMomentAs(start.subtract(const Duration(minutes: 10))), isTrue);
    expect(
        planned[1].fireAt.isAtSameMomentAs(start.subtract(const Duration(minutes: 30))), isTrue);
    expect(planned.every((p) => p.title == 'Kelas'), isTrue);
  });
}
