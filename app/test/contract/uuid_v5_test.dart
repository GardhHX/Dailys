import 'package:flutter_test/flutter_test.dart';
import 'package:dailys/core/ids/deterministic_id.dart';

// Golden vectors from schema.md "Deterministic IDs". Must match the Node.js
// implementation as well; do not change without changing the contract.
void main() {
  group('UUIDv5 deterministic ids', () {
    test('habit-log golden vector', () {
      final id = DeterministicId.habitLog(
        '00000000-0000-0000-0000-000000000001',
        '2026-09-03',
      );
      expect(id, 'd4eef7e7-655b-5e0d-9157-89f85d2b78de');
    });

    test('same canonical name is stable across calls', () {
      const userId = '00000000-0000-0000-0000-000000000001';
      expect(
        DeterministicId.userSettings(userId),
        DeterministicId.userSettings(userId),
      );
    });

    test('different names produce different ids', () {
      expect(
        DeterministicId.habitLog('h1', '2026-09-03'),
        isNot(DeterministicId.habitLog('h1', '2026-09-04')),
      );
    });

    test('v4 has valid random-uuid shape', () {
      final v = DeterministicId.v4();
      expect(
        RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')
            .hasMatch(v),
        isTrue,
        reason: 'got $v',
      );
    });
  });
}
