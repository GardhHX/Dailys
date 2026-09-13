import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show Locale, ThemeMode, ValueNotifier;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/theme/theme_mode_mapping.dart';
import '../../core/db/database.dart';
import '../../core/db/tables/enums.dart';
import '../../core/di/locator.dart';
import 'settings_state.dart';

/// Loads and mutates `UserSettings` (synced) and `DeviceSettings`
/// (local-only) for the Settings screen (design/screens/settings.md,
/// schema 3.1/3.2). Saves per field change; each write bumps `updated_at`
/// (schema Section 2) and re-reads the full row so the UI always reflects the
/// stored form, not just the optimistic patch.
///
/// M1 scope: sections "Tampilan & bahasa" through "Weekly Review" and
/// "Perangkat ini" (theme + alarm volume). "Pusat Sync" and device
/// registration are M2 (no sync yet); "Tentang" is not wired here.
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required AppDatabase db,
    required String userId,
    required String deviceId,
  })  : _db = db,
        _userId = userId,
        _deviceId = deviceId,
        super(const SettingsState());

  final AppDatabase _db;
  final String _userId;
  final String _deviceId;

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    final us = await _db.settingsDao.getUserSettings(_userId);
    final ds = await _db.settingsDao.getLocalDeviceSettings();
    emit(SettingsState(loading: false, userSettings: us, deviceSettings: ds));
  }

  Future<void> _updateUser(UserSettingsCompanion patch) async {
    try {
      await _db.settingsDao.updateUserSettings(_userId, patch);
      emit(state.copyWith(
        userSettings: await _db.settingsDao.getUserSettings(_userId),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: 'settingsSaveFailed'));
    }
  }

  Future<void> _updateDevice(DeviceSettingsCompanion patch) async {
    try {
      await _db.settingsDao.updateDeviceSettings(_deviceId, patch);
      emit(state.copyWith(
        deviceSettings: await _db.settingsDao.getLocalDeviceSettings(),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: 'settingsSaveFailed'));
    }
  }

  Future<void> setLanguage(Language v) async {
    await _updateUser(UserSettingsCompanion(language: Value(v)));
    if (locator.isRegistered<ValueNotifier<Locale?>>()) {
      locator<ValueNotifier<Locale?>>().value = Locale(v.name);
    }
  }

  void setTimezone(String v) => _updateUser(UserSettingsCompanion(timezone: Value(v)));

  /// `1..180` (schema 3.1). Running sessions keep their snapshot duration —
  /// no PomodoroSession table exists yet in M1, so there is nothing to leave
  /// untouched here beyond the setting itself.
  void setPomodoroFocusMinutes(int v) => _setBounded(v, 1, 180,
      (v) => UserSettingsCompanion(pomodoroFocusMinutes: Value(v)));

  void setPomodoroShortBreakMinutes(int v) => _setBounded(v, 1, 60,
      (v) => UserSettingsCompanion(pomodoroShortBreakMinutes: Value(v)));

  void setPomodoroLongBreakMinutes(int v) => _setBounded(v, 1, 120,
      (v) => UserSettingsCompanion(pomodoroLongBreakMinutes: Value(v)));

  void setPomodoroLongBreakInterval(int v) => _setBounded(v, 2, 12,
      (v) => UserSettingsCompanion(pomodoroLongBreakInterval: Value(v)));

  void setNotificationsEnabled(bool v) =>
      _updateUser(UserSettingsCompanion(notificationsEnabled: Value(v)));

  void setAlarmMode(AlarmMode v) => _updateUser(UserSettingsCompanion(alarmMode: Value(v)));

  /// `HH:mm:ss` local time; day stays fixed Sunday in v1.0 (schema 3.1).
  void setWeeklyReviewTime(String hms) =>
      _updateUser(UserSettingsCompanion(weeklyReviewTime: Value(hms)));

  Future<void> setTheme(ThemePreference v) async {
    await _updateDevice(DeviceSettingsCompanion(theme: Value(v)));
    if (locator.isRegistered<ValueNotifier<ThemeMode>>()) {
      locator<ValueNotifier<ThemeMode>>().value = themeModeFromPreference(v);
    }
  }

  void setAlarmVolumePercent(int v) => _setBoundedDevice(v, 0, 100,
      (v) => DeviceSettingsCompanion(alarmVolumePercent: Value(v)));

  void _setBounded(int v, int min, int max, UserSettingsCompanion Function(int) build) {
    if (v < min || v > max) {
      emit(state.copyWith(error: 'settingsValueOutOfRange'));
      return;
    }
    _updateUser(build(v));
  }

  void _setBoundedDevice(int v, int min, int max, DeviceSettingsCompanion Function(int) build) {
    if (v < min || v > max) {
      emit(state.copyWith(error: 'settingsValueOutOfRange'));
      return;
    }
    _updateDevice(build(v));
  }
}
