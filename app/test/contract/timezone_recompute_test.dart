import 'dart:ffi';
import 'dart:io';

import 'package:dailys/core/db/database.dart';
import 'package:dailys/core/db/tables/enums.dart';
import 'package:dailys/core/ids/deterministic_id.dart';
import 'package:dailys/core/time/local_date.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Golden fixture from schema.md 23.2: changing `UserSettings.timezone` from
/// `Asia/Jakarta` (UTC+7, no DST) to `America/Los_Angeles` (PDT on
/// 2026-06-15, UTC-7), around the fixed Instant `2026-06-15T02:00:00Z`.
///
/// "Batas hari ini" and other derived projections are recomputed against
/// whatever timezone is current — [LocalDate.fromInstant] is already exactly
/// that recompute utility, stateless by construction, so there is nothing
/// to build here beyond the test itself ("siapkan util-nya" is already
/// satisfied). What the schema actually constrains is that *materialized*
/// Local dates and already-scheduled Instants are never rewritten by a
/// timezone change; that half is exercised against a real Activity row.
///
/// PomodoroSession's stats bucket (schema 23.2's second "changes" row) needs
/// M3's table and stays out of scope here; HabitLog/streak recompute is M4.
void main() {
  setUpAll(() {
    if (Platform.isWindows) {
      open.overrideFor(OperatingSystem.windows, () => DynamicLibrary.open('winsqlite3.dll'));
    }
    tzdata.initializeTimeZones();
  });

  const userId = '00000000-0000-0000-0000-0000000000aa';
  const deviceId = '00000000-0000-0000-0000-0000000000bb';
  final referenceInstant = DateTime.utc(2026, 6, 15, 2); // 2026-06-15T02:00:00Z

  test('"today" boundary recomputes from the current timezone, not a cached value', () {
    final jakarta = tz.getLocation('Asia/Jakarta'); // UTC+7, no DST
    final losAngeles = tz.getLocation('America/Los_Angeles'); // PDT here, UTC-7

    // 2026-06-15T02:00:00Z is 09:00 in Jakarta but 19:00 the day before in LA.
    expect(LocalDate.fromInstant(referenceInstant, jakarta), const LocalDate(2026, 6, 15));
    expect(LocalDate.fromInstant(referenceInstant, losAngeles), const LocalDate(2026, 6, 14));
  });

  test('materialized Local date and scheduled Instants survive a timezone change unwritten',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.provisionLocalUser(
        userId: userId, deviceId: deviceId, nama: 'A', apiKeyHash: 'h');
    final categoryId = DeterministicId.seedActivityCategory(userId, 'kuliah');

    const activityId = '11111111-1111-4111-8111-111111111111';
    await db.activityDao.insertActivity(ActivityCompanion.insert(
      id: activityId,
      createdAt: referenceInstant,
      updatedAt: referenceInstant,
      userId: userId,
      // Materialized while the user's timezone was still Asia/Jakarta.
      occurrenceDate: '2026-06-15',
      judul: 'Kelas',
      activityCategoryId: categoryId,
      startTime: Value(referenceInstant),
      status: ActivityStatus.belum_mulai,
      source: ActivitySource.manual,
      reminderOffsetsMinutes: const Value([30]),
    ));

    // Switch the user's timezone (FR-7.2 / API-SPEC 9.8).
    await db.settingsDao.updateUserSettings(
      userId,
      const UserSettingsCompanion(timezone: Value('America/Los_Angeles')),
    );

    final row =
        await (db.select(db.activity)..where((a) => a.id.equals(activityId))).getSingle();
    // occurrence_date (materialized Local date) is untouched...
    expect(row.occurrenceDate, '2026-06-15');
    // ...and so is the scheduled Instant the reminder is offset from.
    expect(row.startTime!.isAtSameMomentAs(referenceInstant), isTrue);
  });
}
