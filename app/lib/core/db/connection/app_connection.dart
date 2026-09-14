import 'dart:io';

import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

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
  await prepareDatabaseForOpen(file);
  return AppDatabase(NativeDatabase.createInBackground(file));
}

class DatabaseDowngradeException implements Exception {}

/// Inspect with SQLite before Drift can run an upgrade. The backup must finish
/// verification before any schema change is allowed.
Future<void> prepareDatabaseForOpen(File file,
    {BackupKeyStore? keyStore}) async {
  if (!await file.exists()) return;
  final source = sqlite.sqlite3.open(file.path, mode: sqlite.OpenMode.readOnly);
  late int version;
  String? deviceId;
  try {
    version = source.select('PRAGMA user_version').single.values.single as int;
    if (version > AppDatabase.currentSchemaVersion) {
      throw DatabaseDowngradeException();
    }
    if (version == AppDatabase.currentSchemaVersion) return;
    final tables = source.select(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'");
    if (tables.isEmpty) return;
    if (version == 0) {
      throw MigrationBackupException('Unknown database version');
    }
    if (tables.any((row) => row['name'] == 'device_settings')) {
      final rows =
          source.select('SELECT device_id FROM device_settings LIMIT 1');
      if (rows.isNotEmpty) deviceId = rows.first['device_id'] as String;
    }
    if (deviceId == null) {
      throw MigrationBackupException('Local device unavailable');
    }
  } finally {
    source.dispose();
  }
  final key =
      await (keyStore ?? SecureStorageBackupKeyStore()).getOrCreateKey();
  await MigrationSafety.backupBeforeMigration(
      sourceDbPath: file.path,
      backupDir: p.join(file.parent.path, 'backups'),
      deviceId: deviceId,
      appVersion: '0.1.0+1',
      fromSchemaVersion: version,
      toSchemaVersion: AppDatabase.currentSchemaVersion,
      encryptionKey: key);
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
  final key =
      await (keyStore ?? SecureStorageBackupKeyStore()).getOrCreateKey();
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
