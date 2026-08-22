import 'package:flutter/material.dart';

/// Token warna — 1:1 dengan `DESIGN.md` Section 2. Jangan hardcode hex di
/// widget manapun, selalu referensi dari sini.
class AppColors {
  AppColors._();

  // 2.1 Primary & Surface
  static const Color primaryLight = Color(0xFF3D5AFE);
  static const Color primaryDark = Color(0xFF7B93FF);
  static const Color primaryContainerLight = Color(0xFFE0E4FF);
  static const Color primaryContainerDark = Color(0xFF2A3470);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color surfaceVariantLight = Color(0xFFF4F5F9);
  static const Color surfaceVariantDark = Color(0xFF1E1E1E);
  static const Color outlineLight = Color(0xFFD8DAE3);
  static const Color outlineDark = Color(0xFF3A3A3A);
  static const Color onSurfaceLight = Color(0xFF1A1B23);
  static const Color onSurfaceDark = Color(0xFFEDEDED);
  static const Color onSurfaceMutedLight = Color(0xFF6B6E7C);
  static const Color onSurfaceMutedDark = Color(0xFF9A9A9A);

  // Alias tanpa suffix — dipakai widget yang tidak butuh varian light/dark
  // eksplisit (mis. warna semantic yang sama di kedua tema).
  static const Color primary = primaryLight;

  // 2.2 Semantic Status
  static const Color success = Color(0xFF2E9E5B);
  static const Color warning = Color(0xFFE0A62E);
  static const Color danger = Color(0xFFE14B4B);
  static const Color info = Color(0xFF3D8BFF);

  // 2.3 Prioritas Tugas (FR-6.2)
  static const Color priorityLow = Color(0xFF7BAE7F);
  static const Color priorityMedium = Color(0xFFE0A62E);
  static const Color priorityHigh = Color(0xFFE14B4B);

  // 2.4 Kategori Activity/Timebox Predefined (FR-1.2, FR-3.10)
  static const Map<String, Color> kategoriDefault = {
    'Kuliah': Color(0xFF3D5AFE),
    'Tugas': Color(0xFFFF7A45),
    'Personal': Color(0xFF8B6BD8),
    'Istirahat': Color(0xFF4FB0A5),
    'Sosial': Color(0xFFF2578F),
    'Olahraga': Color(0xFF5CB85C),
  };

  static Color kategoriColor(String kategori) => kategoriDefault[kategori] ?? primary;

  // 2.5 Kategori Keuangan Predefined (FR-4.3)
  static const Map<String, Color> keuanganKategoriDefault = {
    'Belanja': Color(0xFF8B6BD8),
    'Hiburan': Color(0xFFF2578F),
    'Makanan': Color(0xFFFF7A45),
    'Kendaraan': Color(0xFF3D8BFF),
    'Pulsa': Color(0xFF4FB0A5),
    'Rokok': Color(0xFF6B6E7C),
    'Tagihan': Color(0xFFE0A62E),
  };

  /// 2.6 — Palet warna generik untuk entity yang butuh warna bebas-pilih
  /// (bukan kategori activity) — mis. Mata Kuliah (FR-6.18), Habit
  /// (FR-5.14). Diambil dari kombinasi warna kategori + beberapa variasi,
  /// disimpan sebagai hex string ("#RRGGBB") di database sesuai schema.md.
  static const List<Color> palette = [
    Color(0xFF3D5AFE),
    Color(0xFFFF7A45),
    Color(0xFF8B6BD8),
    Color(0xFF4FB0A5),
    Color(0xFFF2578F),
    Color(0xFF5CB85C),
    Color(0xFFE0A62E),
    Color(0xFF3D8BFF),
    Color(0xFF6B6E7C),
  ];

  static String colorToHex(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  static Color hexToColor(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    final value = int.tryParse(cleaned, radix: 16);
    return value == null ? primary : Color(0xFF000000 | value);
  }
}
