import 'dart:ffi';
import 'dart:io';

import 'package:dailys/core/db/database.dart';
import 'package:dailys/core/db/tables/enums.dart';
import 'package:dailys/features/tugas/domain/tugas_history.dart';
import 'package:dailys/features/tugas/tugas_list_cubit.dart';
import 'package:dailys/features/tugas/tugas_list_state.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:dailys/core/time/local_date.dart';

void main() {
  setUpAll(() {
    if (Platform.isWindows) {
      open.overrideFor(
          OperatingSystem.windows, () => DynamicLibrary.open('winsqlite3.dll'));
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

  TugasListCubit makeCubit() =>
      TugasListCubit(db: db, userId: userId, location: jakarta);

  Future<void> pump() => Future<void>.delayed(const Duration(milliseconds: 20));

  Future<String> seedTask(TugasListCubit cubit, {String judul = 'T'}) async {
    await cubit.createTugas(
      judul: judul,
      deadline: DateTime.utc(2026, 9, 20, 2),
      prioritas: TugasPrioritas.medium,
    );
    await pump();
    return cubit.state.tugas.firstWhere((t) => t.judul == judul).id;
  }

  test('createTugas seeds default reminders and shows in active list',
      () async {
    final cubit = makeCubit();
    addTearDown(cubit.close);
    await pump();
    await seedTask(cubit);

    expect(cubit.state.active, hasLength(1));
    final row = cubit.state.tugas.single;
    expect(row.status, TugasStatus.belum);
    expect(row.reminders, hasLength(4)); // schema 5 defaults
  });

  test('checklist edit preserves identity and done; invalid draft rolls back task', () async {
    final cubit = makeCubit();
    addTearDown(cubit.close);
    await cubit.createTugas(judul: 'Checklist', deadline: DateTime.utc(2026, 9, 20),
      prioritas: TugasPrioritas.medium, checklist: [const ChecklistDraft(title: 'Keep'), const ChecklistDraft(title: 'Remove')]);
    await pump();
    final id = cubit.state.tugas.single.id;
    final before = await cubit.loadChecklist(id);
    await db.tugasDao.setChecklistDone(before.first.id, true);
    await cubit.editTugas(id: id, judul: 'Edited', deadline: DateTime.utc(2026, 9, 20),
      prioritas: TugasPrioritas.medium, checklist: [ChecklistDraft(id: before.first.id, title: 'Renamed'), const ChecklistDraft(title: 'New')]);
    final after = await cubit.loadChecklist(id);
    expect(after.first.id, before.first.id);
    expect(after.first.isDone, isTrue);
    expect(after.map((r) => r.judul), ['Renamed', 'New']);
    await expectLater(cubit.editTugas(id: id, judul: 'Should rollback', deadline: DateTime.utc(2026, 9, 20),
      prioritas: TugasPrioritas.high, checklist: [const ChecklistDraft(title: '')]), throwsArgumentError);
    await pump();
    expect(cubit.state.tugas.single.judul, 'Edited');
    expect((await cubit.loadChecklist(id)).map((r) => r.id), after.map((r) => r.id));
  });

  test('completing a task keeps it active during the 7-day grace window',
      () async {
    final cubit = makeCubit();
    addTearDown(cubit.close);
    await pump();
    final id = await seedTask(cubit);

    // Complete at a fixed Instant: 2026-09-14 10:00 WIB.
    await db.tugasDao.setStatus(id, TugasStatus.selesai,
        completedAt: DateTime.utc(2026, 9, 14, 3),
        now: DateTime.utc(2026, 9, 14, 3));
    await pump();

    final row = cubit.state.tugas.single;
    final classifier = TugasClassifier(jakarta);
    // auto-archive date = completed Local date (2026-09-14) + 7 = 2026-09-21.
    expect(classifier.autoArchiveDate(row), const LocalDate(2026, 9, 21));
    expect(classifier.isActive(row, const LocalDate(2026, 9, 20)), isTrue);
    expect(classifier.isActive(row, const LocalDate(2026, 9, 21)), isFalse);
    expect(classifier.historyDate(row), const LocalDate(2026, 9, 21));
  });

  test('manual archive moves the task to history immediately', () async {
    final cubit = makeCubit();
    addTearDown(cubit.close);
    await pump();
    final id = await seedTask(cubit);

    await db.tugasDao.setArchived(id, true, now: DateTime.utc(2026, 9, 15, 5));
    await pump();

    final row = cubit.state.tugas.single;
    final classifier = TugasClassifier(jakarta);
    expect(classifier.isActive(row, const LocalDate(2026, 9, 15)), isFalse);
    // archived_at 2026-09-15 12:00 WIB → Local date 2026-09-15.
    expect(classifier.historyDate(row), const LocalDate(2026, 9, 15));
  });

  test('deleting a task cascade-removes it and its checklist', () async {
    final cubit = makeCubit();
    addTearDown(cubit.close);
    await pump();
    final id = await seedTask(cubit);
    await cubit.deleteTugas(id);
    await pump();
    expect(cubit.state.tugas, isEmpty);
  });

  test('status filter narrows the active list', () async {
    final cubit = makeCubit();
    addTearDown(cubit.close);
    await pump();
    final a = await seedTask(cubit, judul: 'A');
    await seedTask(cubit, judul: 'B');
    await db.tugasDao.setStatus(a, TugasStatus.progress);
    await pump();

    cubit.setStatusFilter(TugasStatus.progress);
    expect(cubit.state.active.map((t) => t.judul), ['A']);

    cubit.setStatusFilter(null);
    expect(cubit.state.active, hasLength(2));
  });

  test('priority sort orders high before low', () async {
    final cubit = makeCubit();
    addTearDown(cubit.close);
    await pump();
    await cubit.createTugas(
        judul: 'low',
        deadline: DateTime.utc(2026, 9, 18),
        prioritas: TugasPrioritas.low);
    await cubit.createTugas(
        judul: 'high',
        deadline: DateTime.utc(2026, 9, 25),
        prioritas: TugasPrioritas.high);
    await pump();

    cubit.setSort(TugasSort.prioritas);
    expect(cubit.state.active.map((t) => t.judul), ['high', 'low']);
  });
}
