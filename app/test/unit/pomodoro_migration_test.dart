import 'dart:ffi';
import 'dart:io';

import 'package:dailys/core/db/backup/backup_key_store.dart';
import 'package:dailys/core/db/connection/app_connection.dart';
import 'package:dailys/core/db/database.dart';
import 'package:dailys/core/db/tables/enums.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';

class FailingKeyStore implements BackupKeyStore {
  @override
  Future<List<int>> getOrCreateKey() async =>
      throw StateError('QA key unavailable');
}

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
    dir = await Directory.systemTemp.createTemp('dailys-pomodoro-migration-');
    file = File('${dir.path}/dailys.db');
    final db = AppDatabase(NativeDatabase(file));
    await db.provisionLocalUser(
        userId: uid, deviceId: did, nama: 'QA', apiKeyHash: '');
    await db.close();
    final source = sqlite3.open(file.path);
    source.execute('DROP TABLE timebox_execution');
    source.execute('DROP TABLE timebox_schedule');
    source.execute('DROP TABLE pomodoro_session');
    source.execute('PRAGMA user_version = 1');
    source.dispose();
  });
  tearDown(() => dir.delete(recursive: true));

  test('v1 backup verified before upgrade; identity and settings retained',
      () async {
    await prepareDatabaseForOpen(file, keyStore: InMemoryBackupKeyStore());
    expect(
        Directory('${dir.path}/backups')
            .listSync()
            .where((f) => f.path.endsWith('.db.enc')),
        hasLength(1));
    final db = AppDatabase(NativeDatabase(file));
    expect((await db.settingsDao.getLocalUser())!.id, uid);
    expect(
        (await db.settingsDao.getUserSettings(uid))!.pomodoroFocusMinutes, 25);
    final id = await db.pomodoroDao
        .start(userId: uid, durasiMenit: 25, jenis: PomodoroJenis.fokus);
    await db.pomodoroDao.pause(id);
    await db.close();
    final reopened = AppDatabase(NativeDatabase(file));
    expect((await reopened.pomodoroDao.getInFlightSession(uid))!.status,
        PomodoroStatus.paused);
    await reopened.close();
  });

  test('failed backup leaves schema v1 untouched', () async {
    await expectLater(prepareDatabaseForOpen(file, keyStore: FailingKeyStore()),
        throwsStateError);
    final source = sqlite3.open(file.path);
    expect(source.select('PRAGMA user_version').single.values.single, 1);
    expect(
        source.select(
            "SELECT name FROM sqlite_master WHERE name = 'pomodoro_session'"),
        isEmpty);
    source.dispose();
  });

  test('newer schema blocks opening without downgrade', () async {
    final source = sqlite3.open(file.path);
    source.execute('PRAGMA user_version = 3');
    source.dispose();
    await expectLater(
        prepareDatabaseForOpen(file, keyStore: InMemoryBackupKeyStore()),
        throwsA(isA<DatabaseDowngradeException>()));
  });
}
