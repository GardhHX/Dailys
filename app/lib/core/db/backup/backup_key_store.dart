import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Source of the 32-byte device-local key that encrypts pre-migration backups.
///
/// The key lives in platform secure storage, never next to the backup file and
/// never in the manifest or logs (OPERATIONS 3, schema 3.2/3.8).
abstract class BackupKeyStore {
  Future<List<int>> getOrCreateKey();
}

/// Default [BackupKeyStore] backed by `flutter_secure_storage` (Windows DPAPI /
/// Android Keystore). Generates a CSPRNG key on first use and reuses it after.
class SecureStorageBackupKeyStore implements BackupKeyStore {
  SecureStorageBackupKeyStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _keyName = 'dailys.db_backup_key.v1';

  final FlutterSecureStorage _storage;

  @override
  Future<List<int>> getOrCreateKey() async {
    final existing = await _storage.read(key: _keyName);
    if (existing != null) {
      final decoded = base64Decode(existing);
      if (decoded.length == 32) return decoded;
      // Corrupt/short value: regenerate rather than fail the migration.
    }
    final rng = Random.secure();
    final key = List<int>.generate(32, (_) => rng.nextInt(256));
    await _storage.write(key: _keyName, value: base64Encode(key));
    return key;
  }
}

/// In-memory key store for tests and headless tooling — no platform binding.
class InMemoryBackupKeyStore implements BackupKeyStore {
  InMemoryBackupKeyStore([List<int>? key])
      : _key = key ?? List<int>.generate(32, (i) => (i * 7 + 1) & 0xFF);

  final List<int> _key;

  @override
  Future<List<int>> getOrCreateKey() async => _key;
}
