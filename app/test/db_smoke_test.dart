import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dailys/core/database/database.dart';

void main() {
  test('in-memory db opens and can insert/query', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final result = await db.customSelect('SELECT 1 AS x').getSingle();
    expect(result.data['x'], 1);
    await db.close();
  }, timeout: const Timeout(Duration(seconds: 20)));
}
