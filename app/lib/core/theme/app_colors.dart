import 'package:flutter/material.dart';

/// Sumber tunggal warna kategori (Activity/Timebox pakai warna yang sama —
/// lihat CLAUDE.md Section 4 & FR-3.10) supaya tidak hardcode hex berulang
/// di tiap fitur.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF06B6D4);
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF22C55E);

  static const Map<String, Color> kategoriDefault = {
    'Kuliah': Color(0xFF4F46E5),
    'Tugas': Color(0xFFF59E0B),
    'Personal': Color(0xFF06B6D4),
    'Istirahat': Color(0xFF22C55E),
    'Sosial': Color(0xFFEC4899),
    'Olahraga': Color(0xFF14B8A6),
  };

  static Color kategoriColor(String kategori) =>
      kategoriDefault[kategori] ?? primary;
}
