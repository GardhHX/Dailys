import 'package:flutter/material.dart';

import '../../core/db/tables/enums.dart';

/// Maps the per-device `DeviceSettings.theme` preference (schema 3.2) to
/// Flutter's [ThemeMode].
ThemeMode themeModeFromPreference(ThemePreference preference) {
  switch (preference) {
    case ThemePreference.light:
      return ThemeMode.light;
    case ThemePreference.dark:
      return ThemeMode.dark;
    case ThemePreference.system:
      return ThemeMode.system;
  }
}
