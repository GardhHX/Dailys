import 'dart:io';

import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../backup/backup_key_store.dart';
import '../database.dart';
import '../migrations.dart';

/// Opens the app's on-disk database in the platform documents directory.
///
/// Uses a background isolate (`createInBackground`) so schema creation and
/// queries never block the UI thread. The native sqlite3 library is provided by
/// `sqlite3_flutter_libs` in release builds.
Future<AppDatabase> openAppDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, 'dailys.db'));
  return AppDatabase(NativeDatabase.createInBackground(file));
}

/// Directory next to the database file where verified pre-migration backups and
/// their manifests are written (OPERATIONS 3).
Future<String> databaseBackupDir() async {
  final dir = await getApplicationDocumentsDirectory();
  final backup = Directory(p.join(dir.path, 'backups'));
  await backup.create(recursive: true);
  return backup.path;
}

/// Runs the OPERATIONS 3 pre-migration backup for the app's on-disk database,
/// encrypting the copy with the device-local key from secure storage.
///
/// Call this after stopping domain writes/sync and before opening the database
/// for an upgrade, whenever real data exists. [keyStore] is injectable for tests.
Future<MigrationBackupResult> backupAppDatabaseBeforeMigration({
  required String deviceId,
  required String appVersion,
  required int fromSchemaVersion,
  required int toSchemaVersion,
  BackupKeyStore? keyStore,
}) async {
  final dir = await getApplicationDocumentsDirectory();
  final dbPath = p.join(dir.path, 'dailys.db');
  final backupDir = await databaseBackupDir();
  final key = await (keyStore ?? SecureStorageBackupKeyStore()).getOrCreateKey();
  return MigrationSafety.backupBeforeMigration(
    sourceDbPath: dbPath,
    backupDir: backupDir,
    deviceId: deviceId,
    appVersion: appVersion,
    fromSchemaVersion: fromSchemaVersion,
    toSchemaVersion: toSchemaVersion,
    encryptionKey: key,
  );
}
