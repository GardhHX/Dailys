import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../app/theme/theme_mode_mapping.dart';
import '../../core/db/connection/app_connection.dart';
import '../../core/db/database.dart';
import '../../core/di/locator.dart';
import '../../core/ids/deterministic_id.dart';
import '../../core/recurrence/materialization_runner.dart';
import '../../core/recurrence/timebox_materialization_runner.dart';
import '../../core/time/tz_data.dart';
import 'splash_state.dart';

/// Runs the Splash startup sequence (design/screens/splash.md "Tugas
/// startup"): open the local database, provision identity on a fresh install,
/// kick off (non-blocking) recurrence materialization, then decide the exit
/// route. Splash never touches the network or requests permissions.
///
/// Migration-before-upgrade (OPERATIONS Section 3) is not exercised yet: M1
/// only ever creates schema v1, so there is nothing to migrate from. Wiring
/// `backupAppDatabaseBeforeMigration` into this sequence is required before
/// `AppDatabase.schemaVersion` is ever bumped past 1.
class SplashCubit extends Cubit<SplashState> {
  SplashCubit({Future<AppDatabase> Function()? databaseOpener})
      : _openDatabase = databaseOpener ?? openAppDatabase,
        super(const SplashState.opening());

  final Future<AppDatabase> Function() _openDatabase;

  Future<void> start() async {
    emit(const SplashState.opening());
    try {
      ensureTimeZoneDatabaseLoaded();
      final db = await _openDatabase();
      if (!locator.isRegistered<AppDatabase>()) {
        locator.registerSingleton<AppDatabase>(db);
      }

      var user = await db.settingsDao.getLocalUser();
      var device = await db.settingsDao.getLocalDeviceSettings();

      if (user == null || device == null) {
        emit(const SplashState.newInstall());
        final userId = DeterministicId.v4();
        final deviceId = DeterministicId.v4();
        await db.provisionLocalUser(
          userId: userId,
          deviceId: deviceId,
          nama: 'Mahasiswa',
          // No server/API key exists before sync (M2) provisions one; empty
          // string is an explicit placeholder, never a real secret.
          apiKeyHash: '',
        );
        user = await db.settingsDao.getLocalUser();
        device = await db.settingsDao.getLocalDeviceSettings();
      }

      final settings = await db.settingsDao.getUserSettings(user!.id);
      if (settings != null) {
        // Non-blocking: design/screens/splash.md "Materialisasi ringan ...
        // boleh dimulai tanpa memblokir tampilan".
        final location = tz.getLocation(settings.timezone);
        unawaited(MaterializationRunner(db).run(userId: user.id, location: location));
        unawaited(
            TimeboxMaterializationRunner(db).run(userId: user.id, location: location));

        if (locator.isRegistered<ValueNotifier<Locale?>>()) {
          locator<ValueNotifier<Locale?>>().value = Locale(settings.language.name);
        }
      }

      // Apply the per-device theme before the shell is visible (design/screens/
      // splash.md: "menerapkannya tanpa flash permukaan terang pada mode gelap").
      if (locator.isRegistered<ValueNotifier<ThemeMode>>()) {
        locator<ValueNotifier<ThemeMode>>().value = themeModeFromPreference(device!.theme);
      }

      final destination = device!.onboardingCompletedAt == null
          ? SplashDestination.onboarding
          : SplashDestination.home;
      emit(SplashState.ready(
        destination: destination,
        db: db,
        userId: user.id,
        deviceId: device.deviceId,
      ));
    } catch (_) {
      // Splash does not surface SQL/paths/stack traces (design spec "Panduan
      // pemulihan"); the generic "could not open" message with retry covers
      // the retriable cases (locked file, transient IO) it can distinguish
      // without deeper native testing.
      emit(const SplashState.failed(reasonKey: 'splashOpenFailed', retriable: true));
    }
  }
}
