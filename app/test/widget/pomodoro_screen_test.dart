import 'package:dailys/core/db/database.dart';
import 'package:dailys/core/db/tables/enums.dart';
import 'package:dailys/features/activity/activity_home_screen.dart';
import 'package:dailys/features/pomodoro/pomodoro_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'design_alignment_test.dart' as qa;

void main() {
  setUpAll(qa.initializeQa);
  for (final width in [320.0, 736.0, 860.0, 1408.0]) {
    for (final dark in [false, true]) {
      testWidgets('Pomodoro layout $width dark=$dark, ID/EN 200%',
          (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 1100);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(db.close);
        await db.provisionLocalUser(
            userId: qa.userId,
            deviceId: qa.deviceId,
            nama: 'QA',
            apiKeyHash: '');
        for (final language in ['id', 'en']) {
          await tester.pumpWidget(qa.wrap(
              PomodoroScreen(db: db, userId: qa.userId, deviceId: qa.deviceId),
              dark,
              language: language,
              scale: language == 'id' ? 1 : 2));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.text('25:00'), findsOneWidget);
          qa.checkDescendants(tester, find.byType(MaterialApp));
          await tester.runAsync(() => qa.capture(tester,
              'pomodoro-${width.toInt()}-${dark ? 'dark' : 'light'}-$language'));
        }
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      });
    }
  }
  testWidgets('Home opens Pomodoro; start, pause, re-enter, complete and break',
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
    await tester.tap(find.text('Pomodoro').first);
    await tester.pumpAndSettle();
    expect(find.byType(PomodoroScreen), findsOneWidget);
    await tester.tap(find.text('50 menit'));
    await tester.pumpAndSettle();
    expect(find.text('50:00'), findsOneWidget);
    await tester.tap(find.text('Mulai fokus'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jeda'));
    await tester.pumpAndSettle();
    expect(
        (await tester
                .runAsync(() => db.pomodoroDao.getInFlightSession(qa.userId)))!
            .status,
        PomodoroStatus.paused);
    await tester.tap(find.text('Home').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pomodoro').first);
    await tester.pumpAndSettle();
    expect(find.text('Lanjutkan'), findsOneWidget);
    await tester.tap(find.text('Selesaikan'));
    await tester.pumpAndSettle();
    final completed = await tester
        .runAsync(() => db.pomodoroDao.getCompletedFocusSessions(qa.userId));
    expect(completed, hasLength(1));
    final activities = await tester.runAsync(() => db
        .customSelect(
            "SELECT COUNT(*) AS n FROM activity WHERE source = 'pomodoro' AND is_deleted = 0")
        .get());
    expect(activities!.single.read<int>('n'), 1);
    await tester.tap(find.text('Istirahat pendek').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mulai istirahat pendek'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lewati'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
