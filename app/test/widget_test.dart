import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dailys/core/database/database.dart';
import 'package:dailys/features/activity/application/activity_providers.dart';
import 'package:dailys/main.dart';

void main() {
  testWidgets('App boots and shows Home tab', (WidgetTester tester) async {
    final testDb = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(testDb.close);

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(testDb)],
      child: const DailysApp(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Belum Mulai (0)'), findsOneWidget);
    expect(find.text('Selesai (0)'), findsOneWidget);
    expect(find.text('Dilewati (0)'), findsOneWidget);

    // Drift schedules a zero-duration cleanup timer when its query streams
    // are disposed. Tear down the tree ourselves and pump once more so that
    // timer fires inside the test body, before flutter_test's strict
    // `!timersPending` check runs during automatic teardown.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
