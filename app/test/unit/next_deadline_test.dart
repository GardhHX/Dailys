import 'dart:ffi';
import 'dart:io';

import 'package:dailys/core/db/database.dart';
import 'package:dailys/core/db/tables/enums.dart';
import 'package:dailys/core/ids/deterministic_id.dart';
import 'package:dailys/core/time/local_date.dart';
import 'package:dailys/features/tugas/domain/next_deadline.dart';
import 'package:dailys/features/tugas/domain/tugas_history.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
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

  test('daysBetweenLocalDates is positive for future, negative for past', () {
    const today = LocalDate(2026, 9, 14);
    expect(daysBetweenLocalDates(today, const LocalDate(2026, 9, 17)), 3);
    expect(daysBetweenLocalDates(today, const LocalDate(2026, 9, 10)), -4);
    expect(daysBetweenLocalDates(today, today), 0);
  });

  group('computeNextDeadline (DB-backed)', () {
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

    Future<void> insertTugas({
      required String judul,
      required DateTime deadline,
      TugasStatus status = TugasStatus.belum,
      DateTime? completedAt,
      DateTime? archivedAt,
    }) async {
      final ts = DateTime.now().toUtc();
      await db.tugasDao.insertTugas(TugasCompanion.insert(
        id: DeterministicId.v4(),
        createdAt: ts,
        updatedAt: ts,
        userId: userId,
        judul: judul,
        deadline: deadline,
        prioritas: TugasPrioritas.medium,
        status: status,
        completedAt: Value(completedAt),
        archivedAt: Value(archivedAt),
        reminders: const [],
      ));
    }

    TugasClassifier classifier() => TugasClassifier(jakarta);
    const today = LocalDate(2026, 9, 14);
    final now = DateTime.utc(2026, 9, 14, 3); // 10:00 WIB

    test('splits overdue (earliest first) from nearest upcoming', () async {
      await insertTugas(judul: 'old overdue', deadline: DateTime.utc(2026, 9, 10));
      await insertTugas(judul: 'recent overdue', deadline: DateTime.utc(2026, 9, 13));
      await insertTugas(judul: 'soon', deadline: DateTime.utc(2026, 9, 16));
      await insertTugas(judul: 'later', deadline: DateTime.utc(2026, 9, 20));

      final rows = await db.tugasDao.watchActiveTugas(userId).first;
      final data = computeNextDeadline(
          allTugas: rows, classifier: classifier(), today: today, now: now);

      expect(data.overdue.map((t) => t.judul), ['old overdue', 'recent overdue']);
      expect(data.upcoming!.judul, 'soon');
    });

    test('completed tasks never count, even within the history grace window',
        () async {
      await insertTugas(
        judul: 'done recently',
        deadline: DateTime.utc(2026, 9, 5), // deadline in the past
        status: TugasStatus.selesai,
        completedAt: DateTime.utc(2026, 9, 12), // still within +7 grace
      );

      final rows = await db.tugasDao.watchActiveTugas(userId).first;
      final data = computeNextDeadline(
          allTugas: rows, classifier: classifier(), today: today, now: now);

      expect(data.isEmpty, isTrue);
    });

    test('manually archived tasks are excluded (schema 5: not active)', () async {
      await insertTugas(
        judul: 'archived overdue',
        deadline: DateTime.utc(2026, 9, 1),
        archivedAt: DateTime.utc(2026, 9, 13),
      );

      final rows = await db.tugasDao.watchActiveTugas(userId).first;
      final data = computeNextDeadline(
          allTugas: rows, classifier: classifier(), today: today, now: now);

      expect(data.isEmpty, isTrue);
    });

    test('no data yields an empty result', () async {
      final rows = await db.tugasDao.watchActiveTugas(userId).first;
      final data = computeNextDeadline(
          allTugas: rows, classifier: classifier(), today: today, now: now);
      expect(data.isEmpty, isTrue);
      expect(data.upcoming, isNull);
    });
  });
}
