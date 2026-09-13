import '../../core/db/database.dart';

class SettingsState {
  const SettingsState({
    this.loading = true,
    this.userSettings,
    this.deviceSettings,
    this.error,
  });

  final bool loading;
  final UserSettingsRow? userSettings;
  final DeviceSettingsRow? deviceSettings;

  /// ARB key for the last save error, or an out-of-range field message. Null
  /// once a subsequent save succeeds.
  final String? error;

  SettingsState copyWith({
    bool? loading,
    UserSettingsRow? userSettings,
    DeviceSettingsRow? deviceSettings,
    String? error,
  }) =>
      SettingsState(
        loading: loading ?? this.loading,
        userSettings: userSettings ?? this.userSettings,
        deviceSettings: deviceSettings ?? this.deviceSettings,
        error: error,
      );
}
