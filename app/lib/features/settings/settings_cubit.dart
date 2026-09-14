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
  Future<void> _writes = Future.value();
  final _versions = <String, int>{};
  final _retries = <String, Future<bool> Function()>{};

  Future<void> retry(String field) async {
    await _retries[field]?.call();
  }

  Future<bool> _save(
      String field, Object value, Future<void> Function() write) {
    final version = (_versions[field] ?? 0) + 1;
    _versions[field] = version;
    _retries[field] = () => _save(field, value, write);
    emit(state.copyWith(
        feedback: {...state.feedback, field: 'saving'},
        drafts: {...state.drafts, field: value}));
    final result = _writes.then((_) async {
      try {
        await write();
        final us = await _db.settingsDao.getUserSettings(_userId);
        final ds = await _db.settingsDao.getLocalDeviceSettings();
        if (us == null || ds == null) throw StateError('Settings unavailable');
        if (isClosed) return false;
        final latest = _versions[field] == version;
        final drafts = {...state.drafts};
        if (latest) {
          drafts.remove(field);
          _retries.remove(field);
        }
        emit(state.copyWith(
            userSettings: us,
            deviceSettings: ds,
            drafts: drafts,
            feedback:
                latest ? {...state.feedback, field: 'saved'} : state.feedback));
        if (latest &&
            field == 'language' &&
            locator.isRegistered<ValueNotifier<Locale?>>()) {
          locator<ValueNotifier<Locale?>>().value =
              Locale((value as Language).name);
        }
        if (latest &&
            field == 'theme' &&
            locator.isRegistered<ValueNotifier<ThemeMode>>()) {
          locator<ValueNotifier<ThemeMode>>().value =
              themeModeFromPreference(value as ThemePreference);
        }
        return latest;
      } catch (_) {
        if (!isClosed && _versions[field] == version) {
          emit(state.copyWith(
              error: 'settingsSaveFailed',
              feedback: {...state.feedback, field: 'error'}));
        }
        return false;
      }
    });
    _writes = result.then((_) {});
    return result;
  }

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    try {
      final us = await _db.settingsDao.getUserSettings(_userId);
      final ds = await _db.settingsDao.getLocalDeviceSettings();
      emit(SettingsState(loading: false, userSettings: us, deviceSettings: ds));
    } catch (_) {
      emit(state.copyWith(loading: false, error: 'settingsSaveFailed'));
    }
  }

  Future<bool> _updateUser(
          UserSettingsCompanion patch, String field, Object value) =>
      _save(field, value,
          () => _db.settingsDao.updateUserSettings(_userId, patch));

  Future<bool> _updateDevice(
          DeviceSettingsCompanion patch, String field, Object value) =>
      _save(field, value,
          () => _db.settingsDao.updateDeviceSettings(_deviceId, patch));

  Future<void> setLanguage(Language v) async {
    await _updateUser(UserSettingsCompanion(language: Value(v)), 'language', v);
  }

  void setTimezone(String v) =>
      _updateUser(UserSettingsCompanion(timezone: Value(v)), 'timezone', v);

  /// `1..180` (schema 3.1). Running sessions keep their snapshot duration —
  /// no PomodoroSession table exists yet in M1, so there is nothing to leave
  /// untouched here beyond the setting itself.
  void setPomodoroFocusMinutes(int v) => _setBounded(v, 1, 180, 'focus',
      (v) => UserSettingsCompanion(pomodoroFocusMinutes: Value(v)));

  void setPomodoroShortBreakMinutes(int v) => _setBounded(
      v,
      1,
      60,
      'shortBreak',
      (v) => UserSettingsCompanion(pomodoroShortBreakMinutes: Value(v)));

  void setPomodoroLongBreakMinutes(int v) => _setBounded(v, 1, 120, 'longBreak',
      (v) => UserSettingsCompanion(pomodoroLongBreakMinutes: Value(v)));

  void setPomodoroLongBreakInterval(int v) => _setBounded(v, 2, 12, 'interval',
      (v) => UserSettingsCompanion(pomodoroLongBreakInterval: Value(v)));

  void setNotificationsEnabled(bool v) => _updateUser(
      UserSettingsCompanion(notificationsEnabled: Value(v)),
      'notifications',
      v);

  void setAlarmMode(AlarmMode v) =>
      _updateUser(UserSettingsCompanion(alarmMode: Value(v)), 'alarm', v);

  /// `HH:mm:ss` local time; day stays fixed Sunday in v1.0 (schema 3.1).
  void setWeeklyReviewTime(String hms) => _updateUser(
      UserSettingsCompanion(weeklyReviewTime: Value(hms)), 'reviewTime', hms);

  Future<void> setTheme(ThemePreference v) async {
    await _updateDevice(DeviceSettingsCompanion(theme: Value(v)), 'theme', v);
  }

  void setAlarmVolumePercent(int v) => _setBoundedDevice(v, 0, 100, 'volume',
      (v) => DeviceSettingsCompanion(alarmVolumePercent: Value(v)));

  void _setBounded(int v, int min, int max, String field,
      UserSettingsCompanion Function(int) build) {
    if (v < min || v > max) {
      emit(state.copyWith(
          error: 'settingsValueOutOfRange',
          feedback: {...state.feedback, field: 'invalid'},
          drafts: {...state.drafts, field: v}));
      return;
    }
    _updateUser(build(v), field, v);
  }

  void _setBoundedDevice(int v, int min, int max, String field,
      DeviceSettingsCompanion Function(int) build) {
    if (v < min || v > max) {
      emit(state.copyWith(
          error: 'settingsValueOutOfRange',
          feedback: {...state.feedback, field: 'invalid'},
          drafts: {...state.drafts, field: v}));
      return;
    }
    _updateDevice(build(v), field, v);
  }

  @override
  Future<void> close() async {
    await _writes;
    await super.close();
  }
}
