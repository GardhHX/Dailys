import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'dailys.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
