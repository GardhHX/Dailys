import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/activity_dao.dart';
import 'daos/tugas_dao.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    MataKuliah,
    Tugas,
    TugasChecklist,
    Activity,
    PomodoroSession,
    TimeboxSchedule,
    Habit,
    HabitLog,
    Akun,
    CategoryKeuangan,
    Transaksi,
  ],
  daos: [ActivityDao, TugasDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'dailys.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
