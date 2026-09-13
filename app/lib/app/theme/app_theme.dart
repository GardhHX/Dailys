import 'package:flutter/material.dart';

import 'tokens.dart';

/// Builds the app's light/dark [ThemeData] from [AppColorTokens]. The active
/// theme is chosen by `DeviceSettings.theme` (schema 3.2; PRD FR-7.15),
/// per-device and never synced — see [[dailys-repo-and-m1-stack]].
class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(AppColorTokens.light, Brightness.light);
  static ThemeData dark() => _build(AppColorTokens.dark, Brightness.dark);

  static ThemeData _build(AppColorTokens t, Brightness brightness) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: t.accent,
      onPrimary: t.onAccent,
      secondary: t.accent,
      onSecondary: t.onAccent,
      error: t.danger,
      onError: t.onAccent,
      surface: t.surface,
      onSurface: t.text,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: t.background,
      fontFamily: kFontFamilyWindows,
      dividerColor: t.divider,
      textTheme: ThemeData(brightness: brightness).textTheme.apply(
            bodyColor: t.text,
            displayColor: t.text,
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: t.background,
        foregroundColor: t.text,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: t.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: t.divider),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: BorderSide(color: t.controlBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: t.accent,
          foregroundColor: t.onAccent,
          minimumSize: const Size.fromHeight(kMinimumPrimaryTargetPx),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: t.accent),
    );
  }
}
