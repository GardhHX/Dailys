import 'dart:ffi';
import 'dart:io';

import 'package:dailys/core/db/backup/backup_key_store.dart';
import 'package:dailys/core/db/connection/app_connection.dart';
import 'package:dailys/core/db/database.dart';
import 'package:dailys/core/time/local_date.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';

/// v2 -> v3 upgrade (M4 Habit tables: schema 11, 11.1, 11.2), mirroring
/// `pomodoro_migration_test.dart`'s v1 -> v2 coverage.
void main() {
  setUpAll(() {
    if (Platform.isWindows) {
      open.overrideFor(
          OperatingSystem.windows, () => DynamicLibrary.open('winsqlite3.dll'));
    }
  });
  late Directory dir;
  late File file;
  const uid = '11111111-1111-4111-8111-111111111111';
  const did = '22222222-2222-4222-8222-222222222222';
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('dailys-habit-migration-');
    file = File('${dir.path}/dailys.db');
    final db = AppDatabase(NativeDatabase(file));
    await db.provisionLocalUser(
        userId: uid, deviceId: did, nama: 'QA', apiKeyHash: '');
    await db.close();
    final source = sqlite3.open(file.path);
    source.execute('DROP TABLE habit_log');
    source.execute('DROP TABLE habit_schedule');
    source.execute('DROP TABLE habit');
    source.execute('PRAGMA user_version = 2');
    source.dispose();
  });
  tearDown(() => dir.delete(recursive: true));

  test('v2 backup verified before upgrade; Habit usable after reopen',
      () async {
    await prepareDatabaseForOpen(file, keyStore: InMemoryBackupKeyStore());
    expect(
        Directory('${dir.path}/backups')
            .listSync()
            .where((f) => f.path.endsWith('.db.enc')),
        hasLength(1));
    final db = AppDatabase(NativeDatabase(file));
    final today = LocalDate.parse('2026-09-07');
    final id = await db.habitDao.createHabit(
      userId: uid,
      nama: 'Lari pagi',
      warna: '#4C6FFF',
      targetHari: const {1, 3, 5},
      today: today,
    );
    final habitRow = await db.habitDao.getHabit(id);
    expect(habitRow!.nama, 'Lari pagi');
    await db.close();
    final reopened = AppDatabase(NativeDatabase(file));
    expect((await reopened.habitDao.getHabit(id))!.nama, 'Lari pagi');
    await reopened.close();
  });
}
