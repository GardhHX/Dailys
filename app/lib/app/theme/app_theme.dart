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
      primaryContainer: t.selectedSurface,
      onPrimaryContainer: t.text,
      secondary: t.accent,
      onSecondary: t.onAccent,
      error: t.danger,
      onError: t.onAccent,
      errorContainer: t.dangerSurface,
      onErrorContainer: t.danger,
      surface: t.surface,
      onSurface: t.text,
      onSurfaceVariant: t.textMuted,
      outline: t.controlBorder,
      outlineVariant: t.divider,
      surfaceTint: Colors.transparent,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: t.background,
      fontFamily: kFontFamilyWindows,
      dividerColor: t.divider,
      textTheme: TextTheme(
        headlineMedium:
            TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: t.text),
        headlineSmall:
            TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: t.text),
        titleLarge:
            TextStyle(fontSize: 19, fontWeight: FontWeight.w600, color: t.text),
        titleMedium:
            TextStyle(fontSize: 19, fontWeight: FontWeight.w600, color: t.text),
        titleSmall:
            TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: t.text),
        bodyLarge: TextStyle(fontSize: 14, color: t.text),
        bodyMedium: TextStyle(fontSize: 14, color: t.text),
        bodySmall: TextStyle(fontSize: 12, color: t.textMuted),
        labelLarge:
            TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.text),
        labelMedium: TextStyle(fontSize: 12, color: t.textMuted),
        labelSmall: TextStyle(fontSize: 11, color: t.textMuted),
      ).apply(fontFamily: kFontFamilyWindows),
      appBarTheme: AppBarTheme(
        backgroundColor: t.background,
        foregroundColor: t.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: BorderSide(color: t.controlBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: BorderSide(color: t.accent, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: t.accent,
          foregroundColor: t.onAccent,
          minimumSize: const Size(44, kMinimumPrimaryTargetPx),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: t.accent,
          foregroundColor: t.onAccent,
          minimumSize: const Size(44, 44),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.control)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
        foregroundColor: t.text,
        minimumSize: const Size(44, 44),
        side: BorderSide(color: t.controlBorder),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control)),
      )),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
        minimumSize: const Size(44, 44),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control)),
      )),
      segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(44, 44)),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control))),
        backgroundColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? t.selectedSurface
                : t.surface),
        foregroundColor: WidgetStatePropertyAll(t.text),
        side: WidgetStatePropertyAll(BorderSide(color: t.controlBorder)),
      )),
      dialogTheme: DialogThemeData(
          backgroundColor: t.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.dialog))),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: t.accent),
    );
  }
}
