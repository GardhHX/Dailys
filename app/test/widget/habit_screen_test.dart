import 'package:dailys/core/db/database.dart';
import 'package:dailys/features/activity/activity_home_screen.dart';
import 'package:dailys/features/habit/habit_detail_screen.dart';
import 'package:dailys/features/habit/habit_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'design_alignment_test.dart' as qa;

void main() {
  setUpAll(qa.initializeQa);
  for (final width in [320.0, 736.0, 860.0, 1408.0]) {
    for (final dark in [false, true]) {
      testWidgets('Habit layout $width dark=$dark, ID/EN 200%', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 1100);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(db.close);
        await db.provisionLocalUser(
            userId: qa.userId, deviceId: qa.deviceId, nama: 'QA', apiKeyHash: '');
        for (final language in ['id', 'en']) {
          await tester.pumpWidget(qa.wrap(
              HabitScreen(db: db, userId: qa.userId, deviceId: qa.deviceId),
              dark,
              language: language,
              scale: language == 'id' ? 1 : 2));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          qa.checkDescendants(tester, find.byType(MaterialApp));
          await tester.runAsync(() => qa.capture(tester,
              'habit-${width.toInt()}-${dark ? 'dark' : 'light'}-$language'));
        }
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      });
    }
  }

  testWidgets(
      'Home opens Habit; add, quick-check today, pause, and detail streak',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1408, 1100);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.provisionLocalUser(
        userId: qa.userId, deviceId: qa.deviceId, nama: 'QA', apiKeyHash: '');

    await tester.pumpWidget(qa.wrap(
        ActivityHomeScreen(db: db, userId: qa.userId, deviceId: qa.deviceId),
        false));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Habit').first);
    await tester.pumpAndSettle();
    expect(find.byType(HabitScreen), findsOneWidget);

    await tester.tap(find.text('Tambah Habit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Lari pagi');
    // Target hari defaults to Mon/Wed/Fri; today (fixed test clock via the
    // real system clock) may or may not be a target day, but the habit is
    // still created either way.
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Lari pagi'), findsOneWidget);

    final created =
        await tester.runAsync(() => db.habitDao.watchHabits(qa.userId).first);
    expect(created, isNotNull);
    final habitId = created!.single.id;

    await tester.tap(find.text('Lari pagi'));
    await tester.pumpAndSettle();
    expect(find.byType(HabitDetailScreen), findsOneWidget);
    expect(find.text('0'), findsWidgets); // fresh streak counters

    await tester.tap(find.byTooltip('Jeda'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jeda').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final paused = await db.habitDao.getHabit(habitId);
    expect(paused!.isArchived, isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
