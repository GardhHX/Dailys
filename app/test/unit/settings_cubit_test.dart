import 'dart:ffi';
import 'dart:io';

import 'package:dailys/core/db/database.dart';
import 'package:dailys/core/db/tables/enums.dart';
import 'package:dailys/core/di/locator.dart';
import 'package:dailys/features/settings/settings_cubit.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
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
  late SettingsCubit cubit;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.provisionLocalUser(
        userId: userId, deviceId: deviceId, nama: 'A', apiKeyHash: 'h');
    if (locator.isRegistered<ValueNotifier<ThemeMode>>()) {
      locator.unregister<ValueNotifier<ThemeMode>>();
    }
    if (locator.isRegistered<ValueNotifier<Locale?>>()) {
      locator.unregister<ValueNotifier<Locale?>>();
    }
    locator.registerSingleton<ValueNotifier<ThemeMode>>(ValueNotifier(ThemeMode.system));
    locator.registerSingleton<ValueNotifier<Locale?>>(ValueNotifier(null));
    cubit = SettingsCubit(db: db, userId: userId, deviceId: deviceId);
    await cubit.load();
  });
  tearDown(() => db.close());

  test('load() reads the provisioned defaults', () {
    expect(cubit.state.userSettings!.pomodoroFocusMinutes, 25);
    expect(cubit.state.deviceSettings!.theme, ThemePreference.system);
  });

  test('setPomodoroFocusMinutes persists a valid value', () async {
    cubit.setPomodoroFocusMinutes(50);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.userSettings!.pomodoroFocusMinutes, 50);
    expect(cubit.state.error, null);

    final reread = await db.settingsDao.getUserSettings(userId);
    expect(reread!.pomodoroFocusMinutes, 50);
  });

  test('setPomodoroFocusMinutes rejects out-of-range values without writing', () async {
    cubit.setPomodoroFocusMinutes(181);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.error, 'settingsValueOutOfRange');
    expect(cubit.state.userSettings!.pomodoroFocusMinutes, 25, reason: 'unchanged');
  });

  test('setPomodoroLongBreakInterval enforces the 2..12 bound', () async {
    cubit.setPomodoroLongBreakInterval(1);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.error, 'settingsValueOutOfRange');

    cubit.setPomodoroLongBreakInterval(12);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.userSettings!.pomodoroLongBreakInterval, 12);
  });

  test('setAlarmVolumePercent enforces 0..100 and updates DeviceSettings only', () async {
    cubit.setAlarmVolumePercent(101);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.error, 'settingsValueOutOfRange');

    cubit.setAlarmVolumePercent(70);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.deviceSettings!.alarmVolumePercent, 70);
  });

  test('setTheme updates DeviceSettings and the shared ThemeMode notifier', () async {
    await cubit.setTheme(ThemePreference.dark);
    expect(cubit.state.deviceSettings!.theme, ThemePreference.dark);
    expect(locator<ValueNotifier<ThemeMode>>().value, ThemeMode.dark);
  });

  test('setLanguage updates UserSettings and the shared Locale notifier', () async {
    await cubit.setLanguage(Language.en);
    expect(cubit.state.userSettings!.language, Language.en);
    expect(locator<ValueNotifier<Locale?>>().value, const Locale('en'));
  });

  test('setWeeklyReviewTime stores HH:mm:ss without touching other fields', () async {
    cubit.setWeeklyReviewTime('18:30:00');
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.userSettings!.weeklyReviewTime, '18:30:00');
    expect(cubit.state.userSettings!.pomodoroFocusMinutes, 25);
  });
}
