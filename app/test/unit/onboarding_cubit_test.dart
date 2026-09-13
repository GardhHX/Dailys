import 'dart:ffi';
import 'dart:io';

import 'package:dailys/core/db/database.dart';
import 'package:dailys/core/db/tables/enums.dart';
import 'package:dailys/core/di/locator.dart';
import 'package:dailys/features/onboarding/onboarding_cubit.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';

void main() {
  setUpAll(() {
    if (Platform.isWindows) {
      open.overrideFor(OperatingSystem.windows, () => DynamicLibrary.open('winsqlite3.dll'));
    }
  });

  const userId = '00000000-0000-0000-0000-0000000000aa';
  const deviceId = '00000000-0000-0000-0000-0000000000bb';

  late AppDatabase db;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.provisionLocalUser(
        userId: userId, deviceId: deviceId, nama: 'A', apiKeyHash: 'h');
    if (locator.isRegistered<ValueNotifier<Locale?>>()) {
      locator.unregister<ValueNotifier<Locale?>>();
    }
    locator.registerSingleton<ValueNotifier<Locale?>>(ValueNotifier(null));
  });
  tearDown(() => db.close());

  test('defaults to id / Asia/Jakarta and lists real IANA zones', () {
    final cubit = OnboardingCubit(db: db, userId: userId, deviceId: deviceId);
    expect(cubit.state.language, Language.id);
    expect(cubit.state.timezone, 'Asia/Jakarta');
    expect(cubit.state.availableTimezones, contains('Asia/Jakarta'));
    expect(cubit.state.availableTimezones, contains('America/New_York'));
  });

  test('finish() persists language/timezone and marks onboarding completed', () async {
    final cubit = OnboardingCubit(db: db, userId: userId, deviceId: deviceId);
    cubit.selectLanguage(Language.en);
    cubit.selectTimezone('America/New_York');

    await cubit.finish();

    expect(cubit.state.completed, isTrue);
    expect(cubit.state.error, null);

    final settings = await db.settingsDao.getUserSettings(userId);
    expect(settings!.language, Language.en);
    expect(settings.timezone, 'America/New_York');

    final device = await db.settingsDao.getLocalDeviceSettings();
    expect(device!.onboardingCompletedAt, isNotNull);

    expect(locator<ValueNotifier<Locale?>>().value, const Locale('en'));
  });
}
