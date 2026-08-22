import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_radius.dart';

/// DESIGN.md Section 1: Material 3 dengan palet kustom (bukan default
/// ungu Material), dark mode disiapkan dari awal.
class AppTheme {
  AppTheme._();

  static final ColorScheme _lightScheme = ColorScheme.light(
    primary: AppColors.primaryLight,
    primaryContainer: AppColors.primaryContainerLight,
    surface: AppColors.surfaceLight,
    surfaceContainerHighest: AppColors.surfaceVariantLight,
    outline: AppColors.outlineLight,
    onSurface: AppColors.onSurfaceLight,
    onSurfaceVariant: AppColors.onSurfaceMutedLight,
    error: AppColors.danger,
  );

  static final ColorScheme _darkScheme = ColorScheme.dark(
    primary: AppColors.primaryDark,
    primaryContainer: AppColors.primaryContainerDark,
    surface: AppColors.surfaceDark,
    surfaceContainerHighest: AppColors.surfaceVariantDark,
    outline: AppColors.outlineDark,
    onSurface: AppColors.onSurfaceDark,
    onSurfaceVariant: AppColors.onSurfaceMutedDark,
    error: AppColors.danger,
  );

  static ThemeData get light => _build(_lightScheme);
  static ThemeData get dark => _build(_darkScheme);

  static ThemeData _build(ColorScheme scheme) {
    // DESIGN.md Section 3 — font Manrope, fallback Inter.
    final textTheme = GoogleFonts.manropeTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      scaffoldBackgroundColor: scheme.surface,
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerHighest,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
          minimumSize: const Size.fromHeight(48),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
      ),
    );
  }
}
