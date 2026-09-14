import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import 'backup/backup_cipher.dart';

/// Index DDL for the M1 schema.
///
/// Kept as raw statements (rather than Drift `@TableIndex`) because several
/// uniqueness rules are *active-only* — SQLite partial unique indexes over
/// `WHERE is_deleted = 0` — which the annotation form cannot express. They run in
/// `MigrationStrategy.onCreate` after `createAll()`.
const List<String> m1Indexes = [
  // Regular indexes (schema Sections 4–8).
  'CREATE INDEX idx_mata_kuliah_user ON mata_kuliah (user_id, is_deleted, nama)',
  'CREATE INDEX idx_course_note_parent ON course_note (mata_kuliah_id, is_deleted, tanggal, created_at)',
  'CREATE INDEX idx_tugas_status ON tugas (user_id, is_deleted, status, deadline)',
  'CREATE INDEX idx_tugas_mk ON tugas (user_id, mata_kuliah_id, is_deleted)',
  'CREATE INDEX idx_checklist_parent ON tugas_checklist (tugas_id, is_deleted, urutan)',
  'CREATE INDEX idx_recurrence_range ON activity_recurrence (user_id, is_deleted, starts_on, ends_on)',
  'CREATE INDEX idx_activity_date ON activity (user_id, is_deleted, occurrence_date, status)',

  // Active-only unique constraints (partial indexes).
  'CREATE UNIQUE INDEX uq_activity_category_name ON activity_category (user_id, lower(nama)) WHERE is_deleted = 0',
  'CREATE UNIQUE INDEX uq_checklist_urutan ON tugas_checklist (tugas_id, urutan) WHERE is_deleted = 0',
  'CREATE UNIQUE INDEX uq_activity_occurrence ON activity (user_id, recurrence_id, occurrence_date) '
      'WHERE is_deleted = 0 AND recurrence_id IS NOT NULL',
  'CREATE UNIQUE INDEX uq_activity_source ON activity (user_id, source, source_id) '
      'WHERE is_deleted = 0 AND source_id IS NOT NULL',
];

/// Index DDL for the M3 tables (schema 9, 10, 10.1). Applied on fresh install
/// (`onCreate`) and on the v1 -> v2 upgrade (`onUpgrade`).
const List<String> m3Indexes = [
  'CREATE INDEX idx_pomodoro_user_start ON pomodoro_session (user_id, is_deleted, start_time)',
  'CREATE INDEX idx_pomodoro_user_status ON pomodoro_session (user_id, status, start_time)',
  'CREATE INDEX idx_timebox_schedule_user ON timebox_schedule (user_id, is_deleted, is_active)',
  'CREATE INDEX idx_timebox_execution_range ON timebox_execution '
      '(schedule_id, is_deleted, occurrence_date, planned_start_at)',
  // Unique active (schedule_id, planned_start_at) (schema 10.1).
  'CREATE UNIQUE INDEX uq_timebox_execution_active ON timebox_execution (schedule_id, planned_start_at) '
      'WHERE is_deleted = 0',
];

/// Index DDL for the M4 Habit tables (schema 11, 11.1, 11.2). Applied on
/// fresh install (`onCreate`) and on the v2 -> v3 upgrade (`onUpgrade`).
const List<String> m4HabitIndexes = [
  'CREATE INDEX idx_habit_user ON habit (user_id, is_deleted, is_archived, urutan)',
  'CREATE INDEX idx_habit_schedule_habit ON habit_schedule (habit_id, is_deleted, effective_from)',
  'CREATE INDEX idx_habit_log_habit ON habit_log (habit_id, is_deleted, tanggal)',
  // Unique active (habit_id, effective_from) (schema 11.1).
  'CREATE UNIQUE INDEX uq_habit_schedule_active ON habit_schedule (habit_id, effective_from) '
      'WHERE is_deleted = 0',
  // Unique active (habit_id, tanggal) (schema 11.2).
  'CREATE UNIQUE INDEX uq_habit_log_active ON habit_log (habit_id, tanggal) '
      'WHERE is_deleted = 0',
];

/// Domain + local tables whose row counts are compared source-vs-copy during the
/// pre-migration backup (OPERATIONS 3 step 5). Deferred M2+ tables
/// (`SyncOutbox`, `SyncEntityBase`, …) are not created in M1, so only the tables
/// that actually exist in both databases are compared at runtime.
const List<String> _backupVerifiedTables = [
  'user',
  'user_settings',
  'mata_kuliah',
  'course_note',
  'tugas',
  'tugas_checklist',
  'activity_category',
  'activity_recurrence',
  'activity',
  'device_settings',
  'pomodoro_session',
  'timebox_schedule',
  'timebox_execution',
  'habit',
  'habit_schedule',
  'habit_log',
];

/// Applies M1 index DDL. Called from [MigrationStrategy.onCreate].
Future<void> createM1Indexes(Migrator m) async {
  for (final stmt in m1Indexes) {
    await m.database.customStatement(stmt);
  }
}

/// Applies M3 index DDL (see [m3Indexes]). Called from both a fresh install's
/// `onCreate` and the v1 -> v2 `onUpgrade` step.
Future<void> createM3Indexes(Migrator m) async {
  for (final stmt in m3Indexes) {
    await m.database.customStatement(stmt);
  }
}

/// Applies M4 Habit index DDL (see [m4HabitIndexes]). Called from both a
/// fresh install's `onCreate` and the v2 -> v3 `onUpgrade` step.
Future<void> createM4HabitIndexes(Migrator m) async {
  for (final stmt in m4HabitIndexes) {
    await m.database.customStatement(stmt);
  }
}

/// Result of a verified, encrypted pre-migration SQLite backup (OPERATIONS 3).
class MigrationBackupResult {
  const MigrationBackupResult({
    required this.backupPath,
    required this.manifestPath,
    required this.ciphertextSha256,
    required this.plaintextSha256,
    required this.sizeBytes,
  });

  /// Path of the encrypted backup artifact (`*.db.enc`).
  final String backupPath;
  final String manifestPath;

  /// SHA-256 of the encrypted file on disk (the retained artifact).
  final String ciphertextSha256;

  /// SHA-256 of the verified plaintext copy, for post-decrypt integrity checks
  /// during recovery.
  final String plaintextSha256;

  /// Size of the encrypted artifact in bytes.
  final int sizeBytes;
}

/// Thrown when any OPERATIONS 3 verification step fails. Migration must not run.
class MigrationBackupException implements Exception {
  MigrationBackupException(this.message);
  final String message;
  @override
  String toString() => 'MigrationBackupException: $message';
}

/// Verified, encrypted SQLite backup taken before every local schema migration
/// when real data exists (OPERATIONS 3). The caller must first stop domain
/// writes and sync and wait for active transactions to finish (step 1).
///
/// Steps performed here:
///  2. `PRAGMA integrity_check` on the source.
///  3. WAL checkpoint, then a consistent copy via `VACUUM INTO` (SQLite backup)
///     to a temporary plaintext file.
///  4. Verify that plaintext copy: reopen, `integrity_check`, and compare row
///     counts of the domain tables + `device_settings` against the source.
///  5. Encrypt the verified copy with the device-local [encryptionKey]
///     (AES-256-GCM, [BackupCipher]) into `*.db.enc`, then delete the plaintext
///     temp. The key comes from `BackupKeyStore` (secure storage) — never stored
///     next to the file or in the manifest.
///  6. Local manifest: app version, from/to schema version, device id, UTC time,
///     encrypted size, ciphertext + plaintext SHA-256, `encrypted: true`.
///
/// [encryptionKey] must be 32 bytes. See [[dailys-repo-and-m1-stack]].
class MigrationSafety {
  const MigrationSafety._();

  static Future<MigrationBackupResult> backupBeforeMigration({
    required String sourceDbPath,
    required String backupDir,
    required String deviceId,
    required String appVersion,
    required int fromSchemaVersion,
    required int toSchemaVersion,
    required List<int> encryptionKey,
    BackupCipher? cipher,
    DateTime? now,
  }) async {
    if (encryptionKey.length != 32) {
      throw MigrationBackupException(
        'encryption key must be 32 bytes, got ${encryptionKey.length}',
      );
    }
    final aes = cipher ?? BackupCipher();
    final stamp = (now ?? DateTime.now().toUtc());
    await Directory(backupDir).create(recursive: true);
    final base =
        'dailys-${stamp.millisecondsSinceEpoch}-v$fromSchemaVersion-to-v$toSchemaVersion';
    final plaintextTemp = File(p.join(backupDir, '$base.plain.tmp'));
    final backupPath = p.join(backupDir, '$base.db.enc');
    final manifestPath = p.join(backupDir, '$base.manifest.json');

    try {
      // Step 2 + 3: integrity check, checkpoint, consistent plaintext copy.
      final source = sqlite3.open(sourceDbPath);
      final Map<String, int> sourceCounts;
      try {
        _assertIntegrityOk(source, 'source');
        source.execute('PRAGMA wal_checkpoint(TRUNCATE)');
        if (plaintextTemp.existsSync()) plaintextTemp.deleteSync();
        // VACUUM INTO makes a defragmented, transactionally consistent copy.
        source.execute('VACUUM INTO ?', [plaintextTemp.path]);
        sourceCounts = _rowCounts(source);
      } finally {
        source.dispose();
      }

      // Step 4: verify the plaintext copy independently, before encrypting.
      final copy = sqlite3.open(plaintextTemp.path);
      try {
        _assertIntegrityOk(copy, 'backup copy');
        final copyCounts = _rowCounts(copy);
        for (final entry in sourceCounts.entries) {
          final copied = copyCounts[entry.key];
          if (copied != entry.value) {
            throw MigrationBackupException(
              'row count mismatch for ${entry.key}: source ${entry.value}, copy $copied',
            );
          }
        }
      } finally {
        copy.dispose();
      }

      final plaintextBytes = await plaintextTemp.readAsBytes();
      final plaintextDigest = sha256.convert(plaintextBytes).toString();

      // Step 5: encrypt with the device-local key, then drop the plaintext.
      if (File(backupPath).existsSync()) File(backupPath).deleteSync();
      await aes.encryptFile(
        plaintext: plaintextTemp,
        output: File(backupPath),
        key: encryptionKey,
      );

      // Step 6: checksum the encrypted artifact + write manifest.
      final encBytes = await File(backupPath).readAsBytes();
      final ciphertextDigest = sha256.convert(encBytes).toString();
      final sizeBytes = encBytes.length;

      final manifest = <String, Object?>{
        'app_version': appVersion,
        'schema_version_from': fromSchemaVersion,
        'schema_version_to': toSchemaVersion,
        'device_id': deviceId,
        'created_at_utc': stamp.toIso8601String(),
        'size_bytes': sizeBytes,
        'encrypted': true,
        'cipher': 'AES-256-GCM',
        'sha256': ciphertextDigest,
        'plaintext_sha256': plaintextDigest,
        'row_counts': sourceCounts,
      };
      await File(manifestPath)
          .writeAsString(const JsonEncoder.withIndent('  ').convert(manifest));

      return MigrationBackupResult(
        backupPath: backupPath,
        manifestPath: manifestPath,
        ciphertextSha256: ciphertextDigest,
        plaintextSha256: plaintextDigest,
        sizeBytes: sizeBytes,
      );
    } finally {
      // Never leave an unencrypted copy behind, even on failure.
      if (plaintextTemp.existsSync()) {
        try {
          plaintextTemp.deleteSync();
        } catch (_) {/* best effort */}
      }
    }
  }

  static void _assertIntegrityOk(Database db, String label) {
    final rows = db.select('PRAGMA integrity_check');
    final result = rows.isEmpty ? '' : rows.first.values.first;
    if (result != 'ok') {
      throw MigrationBackupException(
          'integrity_check failed on $label: $result');
    }
  }

  static Map<String, int> _rowCounts(Database db) {
    final present = db
        .select("SELECT name FROM sqlite_master WHERE type = 'table'")
        .map((r) => r['name'] as String)
        .toSet();
    final counts = <String, int>{};
    for (final table in _backupVerifiedTables) {
      if (!present.contains(table)) continue;
      final row = db.select('SELECT COUNT(*) AS n FROM "$table"').first;
      counts[table] = row['n'] as int;
    }
    return counts;
  }
}
