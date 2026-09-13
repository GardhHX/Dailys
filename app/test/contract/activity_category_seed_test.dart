import 'package:dailys/core/db/seed/category_seed.dart';
import 'package:dailys/core/ids/deterministic_id.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden vectors pinning the six system ActivityCategory seed ids (schema 6,
/// "Deterministic IDs"). The slugs below are the *contract*: the UUIDv5 canonical
/// name is `urn:dailys:v1.0:activity-category:{user_id}:{slug}`, so the Node.js
/// server implementation MUST use these exact slugs to produce matching ids
/// before sync is enabled. Do not change a slug without changing the contract.
void main() {
  const userId = '00000000-0000-0000-0000-000000000001';

  const goldenIds = <String, String>{
    'kuliah': 'e4616ca7-51b2-56c3-a4cf-304a4211a24b',
    'tugas': 'df3b699d-a959-5535-bd27-b2675cf51514',
    'personal': '53d6bd14-770a-53d3-b219-3099bf07dd42',
    'istirahat': 'd50f065b-7fd7-550d-ae86-a0e69fa5ad1c',
    'sosial': 'd2739764-b2b7-5c93-a16c-c2be726bf2e4',
    'olahraga': '5f0a8a68-4ad5-58e5-b2ed-edf79c21876d',
  };

  test('seed slugs and order are frozen', () {
    expect(
      kSeedActivityCategories.map((s) => s.slug).toList(),
      ['kuliah', 'tugas', 'personal', 'istirahat', 'sosial', 'olahraga'],
    );
  });

  test('seed ids match golden UUIDv5 vectors', () {
    for (final seed in kSeedActivityCategories) {
      expect(
        seed.idFor(userId),
        goldenIds[seed.slug],
        reason: 'slug ${seed.slug} id drifted from the cross-platform contract',
      );
      // idFor must equal the raw canonical-name derivation.
      expect(
        seed.idFor(userId),
        DeterministicId.seedActivityCategory(userId, seed.slug),
      );
    }
  });
}
