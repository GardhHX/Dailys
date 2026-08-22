import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_radius.dart';

/// DESIGN.md Section 1: Material 3 dengan palet kustom (bukan default
/// ungu Material), dark mode disiapkan dari awal.
class AppTheme {
  AppTheme._();

  // `secondary`/`secondaryContainer` sengaja disamakan dengan `primary` —
  // DESIGN.md cuma mendefinisikan 1 warna aksen (bukan sistem 2 warna
  // primary+secondary terpisah). Tanpa ini, beberapa widget M3
  // (SegmentedButton selected segment, NavigationRail selected indicator)
  // jatuh ke default teal Material karena field `secondary` di
  // `ColorScheme.light()`/`.dark()` punya nilai hardcoded sendiri kalau
  // tidak di-override eksplisit — ditemukan saat verifikasi Phase 3
  // (toggle "Today View/Weekly Grid" tampil teal, bukan warna brand).
  static final ColorScheme _lightScheme = ColorScheme.light(
    primary: AppColors.primaryLight,
    primaryContainer: AppColors.primaryContainerLight,
    // `onPrimaryContainer` di-set eksplisit = warna teks utama. DESIGN.md
    // Section 5: teks isi banner konflik itu `onSurface` NETRAL, bukan
    // merah. Tanpa override ini, M3 mengisi slot tsb dengan default-nya
    // sendiri yang tidak ada hubungannya dengan palet desain.
    onPrimaryContainer: AppColors.onSurfaceLight,
    secondary: AppColors.primaryLight,
    secondaryContainer: AppColors.primaryContainerLight,
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
    onPrimaryContainer: AppColors.onSurfaceDark,
    secondary: AppColors.primaryDark,
    secondaryContainer: AppColors.primaryContainerDark,
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
    // DESIGN.md Section 3 — font Archivo (ganti dari Manrope, dikonfirmasi
    // dari file desain Claude Design 22 Agu 2026). Extra Bold dipakai untuk
    // judul/label tombol — di-apply lewat textTheme.copyWith di bawah
    // karena GoogleFonts.archivoTextTheme() default-nya masih regular/bold
    // biasa untuk sebagian besar style, bukan extra bold.
    // Ukuran/weight/letterSpacing di bawah diverifikasi 23 Agu 2026 lewat
    // getComputedStyle() pada `Dailys Desktop (standalone).html`:
    // - headlineMedium (judul ScreenHeader, mis. "Home"): 30px/800,
    //   letterSpacing -0.45px — direvisi dari 28px tanpa letterSpacing.
    // - labelSmall (eyebrow "HOME" di ScreenHeader): 11px/800,
    //   letterSpacing 1.1px — direvisi dari weight 700/letterSpacing 0.6.
    final baseTextTheme = GoogleFonts.archivoTextTheme();
    final textTheme = baseTextTheme.copyWith(
      displayMedium: GoogleFonts.archivo(fontSize: 32, fontWeight: FontWeight.w800),
      headlineMedium: GoogleFonts.archivo(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -0.45),
      titleLarge: GoogleFonts.archivo(fontSize: 18, fontWeight: FontWeight.w700),
      bodyLarge: GoogleFonts.archivo(fontSize: 15, fontWeight: FontWeight.w600),
      bodyMedium: GoogleFonts.archivo(fontSize: 13, fontWeight: FontWeight.w400),
      bodySmall: GoogleFonts.archivo(fontSize: 13, fontWeight: FontWeight.w400),
      labelLarge: GoogleFonts.archivo(fontSize: 14, fontWeight: FontWeight.w800),
      labelSmall: GoogleFonts.archivo(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1),
    );

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
          minimumSize: const Size.fromHeight(48),
          textStyle: GoogleFonts.archivo(fontSize: 14, fontWeight: FontWeight.w800),
        ),
      ),
      // Tombol outline ("Mark all done", "Reschedule unfinished" di file
      // desain) — DIREVISI 23 Agu 2026: getComputedStyle() menunjukkan teks
      // & ikonnya warna netral (`onSurface`), BUKAN primary seperti diduga
      // sesi sebelumnya (tanpa override ini, default M3 jatuh ke
      // `colorScheme.primary` utk foreground OutlinedButton). Border tetap
      // `scheme.outline`, radius sama dengan tombol solid.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(color: scheme.outline),
          foregroundColor: scheme.onSurface,
          textStyle: GoogleFonts.archivo(fontSize: 14, fontWeight: FontWeight.w800),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
      ),
      // DIREVISI 23 Agu 2026 — form tambah/edit (Activity, Tugas, Timebox,
      // Mata Kuliah) ternyata modal terpusat (`Dialog`) di file desain,
      // BUKAN bottom sheet yang naik dari bawah seperti draft sebelumnya
      // (user tunjukkan langsung screenshot "Add activity" — dialognya
      // muncul di tengah layar). `surfaceContainerHighest` dipakai sebagai
      // bg dialog, konsisten dengan konvensi "elevated card surface" yang
      // sudah dipakai di kanban tile/stat card.
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      ),
    );
  }
}
