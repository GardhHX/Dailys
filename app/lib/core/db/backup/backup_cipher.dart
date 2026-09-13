import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// AES-256-GCM file encryption for the pre-migration SQLite backup copy
/// (OPERATIONS 3: "App mengenkripsi copy dengan key device-local").
///
/// File layout: `magic(4) | nonce(12) | mac(16) | ciphertext`. The key is 32
/// bytes and never stored next to the file — see [BackupKeyStore].
class BackupCipher {
  BackupCipher();

  /// `DBK1` — container magic + version.
  static const List<int> magic = [0x44, 0x42, 0x4b, 0x31];
  static const int _nonceLen = 12;
  static const int _macLen = 16;

  final AesGcm _algo = AesGcm.with256bits();

  static void _checkKey(List<int> key) {
    if (key.length != 32) {
      throw ArgumentError('backup key must be 32 bytes, got ${key.length}');
    }
  }

  /// Encrypts [plaintext]'s bytes into [output].
  Future<void> encryptFile({
    required File plaintext,
    required File output,
    required List<int> key,
  }) async {
    _checkKey(key);
    final clear = await plaintext.readAsBytes();
    final secretBox = await _algo.encrypt(
      clear,
      secretKey: SecretKey(key),
      nonce: _algo.newNonce(),
    );
    final sink = output.openWrite();
    try {
      sink.add(magic);
      sink.add(secretBox.nonce);
      sink.add(secretBox.mac.bytes);
      sink.add(secretBox.cipherText);
    } finally {
      await sink.close();
    }
  }

  /// Decrypts [input] to cleartext bytes, verifying the GCM tag (throws on
  /// tamper or wrong key).
  Future<Uint8List> decryptToBytes({
    required File input,
    required List<int> key,
  }) async {
    _checkKey(key);
    final bytes = await input.readAsBytes();
    final headerLen = magic.length + _nonceLen + _macLen;
    if (bytes.length < headerLen) {
      throw const FormatException('backup file too short / not a DBK1 container');
    }
    for (var i = 0; i < magic.length; i++) {
      if (bytes[i] != magic[i]) {
        throw const FormatException('bad backup magic (not a DBK1 container)');
      }
    }
    var offset = magic.length;
    final nonce = bytes.sublist(offset, offset + _nonceLen);
    offset += _nonceLen;
    final mac = bytes.sublist(offset, offset + _macLen);
    offset += _macLen;
    final cipherText = bytes.sublist(offset);

    final clear = await _algo.decrypt(
      SecretBox(cipherText, nonce: nonce, mac: Mac(mac)),
      secretKey: SecretKey(key),
    );
    return Uint8List.fromList(clear);
  }
}
