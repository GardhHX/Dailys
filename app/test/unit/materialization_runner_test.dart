import 'dart:ffi';
import 'dart:io';

import 'package:dailys/core/db/database.dart';
import 'package:dailys/core/db/tables/enums.dart';
import 'package:dailys/core/ids/deterministic_id.dart';
import 'package:dailys/core/recurrence/materialization_runner.dart';
import 'package:dailys/core/time/local_date.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// DB-integration tests for [MaterializationRunner]: persists occurrences via
/// [ActivityDao.applyMaterialization] and never overwrites an already
/// materialized snapshot on a later run (schema Section 2).
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

  setUpAll(() => jakarta = tz.getLocation('Asia/Jakarta'));

  late AppDatabase db;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.provisionLocalUser(
        userId: userId, deviceId: deviceId, nama: 'A', apiKeyHash: 'h');
  });
  tearDown(() => db.close());

  Future<String> insertRecurrence({
    String startsOn = '2026-09-01',
    String? endsOn,
    List<int> recurringDays = const [1, 3, 5],
    String judul = 'Kelas Basis Data',
  }) async {
    final catId = DeterministicId.seedActivityCategory(userId, 'kuliah');
    const recId = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
    final now = DateTime.utc(2026, 9, 1);
    await db.activityDao.insertRecurrence(ActivityRecurrenceCompanion.insert(
      id: recId,
      createdAt: now,
      updatedAt: now,
      userId: userId,
      judul: judul,
      activityCategoryId: catId,
      startsOn: startsOn,
      endsOn: Value(endsOn),
      recurringDays: recurringDays,
      startTime: const Value('09:00:00'),
      endTime: const Value('10:00:00'),
    ));
    return recId;
  }

  test('run() materializes occurrences and advances the watermark', () async {
    await insertRecurrence();
    final runner = MaterializationRunner(db);
    final today = DateTime.utc(2026, 9, 14, 3); // 2026-09-14 10:00 WIB, Monday

    await runner.run(userId: userId, location: jakarta, now: today);

    final occurrences = await db.select(db.activity).get();
    expect(occurrences, isNotEmpty);
    expect(occurrences.every((o) => o.source == ActivitySource.manual), isTrue);
    expect(occurrences.every((o) => o.status == ActivityStatus.belum_mulai), isTrue);

    final template = await (db.select(db.activityRecurrence)).getSingle();
    expect(template.materializedThroughDate, const LocalDate(2026, 10, 14).toYmd());
  });

  test('re-running does not duplicate occurrences (idempotent)', () async {
    await insertRecurrence();
    final runner = MaterializationRunner(db);
    final today = DateTime.utc(2026, 9, 14, 3);

    await runner.run(userId: userId, location: jakarta, now: today);
    final countAfterFirst = (await db.select(db.activity).get()).length;

    await runner.run(userId: userId, location: jakarta, now: today);
    final countAfterSecond = (await db.select(db.activity).get()).length;

    expect(countAfterSecond, countAfterFirst);
  });

  test(
      'editing the template after materialization does not rewrite already-materialized '
      'occurrences (schema Section 2 immutable snapshot)', () async {
    final recId = await insertRecurrence();
    final runner = MaterializationRunner(db);
    final today = DateTime.utc(2026, 9, 14, 3); // Monday

    await runner.run(userId: userId, location: jakarta, now: today);

    final beforeEdit = await (db.select(db.activity)
          ..where((t) => t.occurrenceDate.equals('2026-09-14')))
        .getSingle();
    expect(beforeEdit.judul, 'Kelas Basis Data');

    // Edit the template's title directly (simulating a user edit mutation).
    await (db.update(db.activityRecurrence)..where((t) => t.id.equals(recId))).write(
      const ActivityRecurrenceCompanion(judul: Value('Kelas Basis Data (Revisi)')),
    );

    // Re-run materialization for the same window.
    await runner.run(userId: userId, location: jakarta, now: today);

    final afterEdit = await (db.select(db.activity)
          ..where((t) => t.occurrenceDate.equals('2026-09-14')))
        .getSingle();
    expect(afterEdit.judul, 'Kelas Basis Data',
        reason: 'already-materialized occurrence must stay an immutable snapshot');

    // A date beyond the old watermark, materialized only after the edit,
    // should use the NEW template value.
    final future = DateTime.utc(2026, 10, 20, 3); // after original horizon
    await runner.run(userId: userId, location: jakarta, now: future);
    final newOccurrence = await (db.select(db.activity)
          ..where((t) => t.occurrenceDate.equals('2026-10-21'))) // Wednesday
        .getSingleOrNull();
    expect(newOccurrence?.judul, 'Kelas Basis Data (Revisi)');
  });

  test('deleted recurrence is skipped by run()', () async {
    final recId = await insertRecurrence();
    await db.activityDao.softDeleteRecurrence(recId, now: DateTime.utc(2026, 9, 2));

    final runner = MaterializationRunner(db);
    await runner.run(
      userId: userId,
      location: jakarta,
      now: DateTime.utc(2026, 9, 14, 3),
    );

    expect(await db.select(db.activity).get(), isEmpty);
  });
}
