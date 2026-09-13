import 'dart:ffi';
import 'dart:io';

import 'package:dailys/core/db/database.dart';
import 'package:dailys/core/di/locator.dart';
import 'package:dailys/features/onboarding/onboarding_screen.dart';
import 'package:dailys/features/splash/splash_screen.dart';
import 'package:dailys/features/splash/splash_state.dart';
import 'package:dailys/l10n/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';

/// Widget-level check that Splash actually drives navigation via the real
/// [SplashCubit] (not a mock), proving the DI + DAO wiring works end to end.
/// Every case injects `databaseOpener` so no test touches `path_provider` or
/// real disk.
void main() {
  setUpAll(() {
    if (Platform.isWindows) {
      open.overrideFor(OperatingSystem.windows, () => DynamicLibrary.open('winsqlite3.dll'));
    }
  });

  setUp(() {
    if (locator.isRegistered<AppDatabase>()) locator.unregister<AppDatabase>();
    if (locator.isRegistered<ValueNotifier<ThemeMode>>()) {
      locator.unregister<ValueNotifier<ThemeMode>>();
    }
    if (locator.isRegistered<ValueNotifier<Locale?>>()) {
      locator.unregister<ValueNotifier<Locale?>>();
    }
    locator.registerSingleton<ValueNotifier<ThemeMode>>(ValueNotifier(ThemeMode.system));
    locator.registerSingleton<ValueNotifier<Locale?>>(ValueNotifier(null));
  });

  Widget wrap(Widget child) => MaterialApp(
        locale: const Locale('id'), // pin so button text assertions are deterministic
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      );

  testWidgets('fresh install provisions identity and routes to onboarding', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    SplashDestination? routed;
    String? routedUserId;

    await tester.pumpWidget(wrap(SplashScreen(
      databaseOpener: () async => db,
      onReady: (dest, gotDb, userId, deviceId) {
        routed = dest;
        routedUserId = userId;
      },
    )));
    await tester.pumpAndSettle();

    expect(routed, SplashDestination.onboarding);
    expect(routedUserId, isNotNull);
    expect((await db.settingsDao.getLocalUser())!.id, routedUserId);
  });

  testWidgets('existing install (onboarding already completed) routes to home', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.provisionLocalUser(
      userId: '11111111-1111-4111-8111-111111111111',
      deviceId: '22222222-2222-4222-8222-222222222222',
      nama: 'A',
      apiKeyHash: 'h',
    );
    await db.settingsDao.markOnboardingCompleted('22222222-2222-4222-8222-222222222222');

    SplashDestination? routed;
    await tester.pumpWidget(wrap(SplashScreen(
      databaseOpener: () async => db,
      onReady: (dest, gotDb, userId, deviceId) => routed = dest,
    )));
    await tester.pumpAndSettle();

    expect(routed, SplashDestination.home);
  });

  testWidgets('onboarding finish() navigates via onCompleted', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.provisionLocalUser(
      userId: '33333333-3333-4333-8333-333333333333',
      deviceId: '44444444-4444-4444-8444-444444444444',
      nama: 'A',
      apiKeyHash: 'h',
    );

    var completed = false;
    await tester.pumpWidget(wrap(OnboardingScreen(
      db: db,
      userId: '33333333-3333-4333-8333-333333333333',
      deviceId: '44444444-4444-4444-8444-444444444444',
      onCompleted: () => completed = true,
    )));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lanjutkan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mulai'));
    await tester.pumpAndSettle();

    expect(completed, isTrue);
    final device = await db.settingsDao.getLocalDeviceSettings();
    expect(device!.onboardingCompletedAt, isNotNull);
  });
}
