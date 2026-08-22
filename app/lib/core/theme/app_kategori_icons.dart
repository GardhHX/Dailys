import 'package:flutter/material.dart';

/// Ikon per kategori Activity/Timebox (FR-1.2, FR-3.10) — dipakai bareng
/// oleh Activity & Timebox. DESIGN.md v2 Section 2.4: kategori sekarang
/// dibedakan lewat ikon + aksen warna tipis, bukan lagi blok warna besar.
const kKategoriIcons = {
  'Kuliah': Icons.school_outlined,
  'Tugas': Icons.assignment_outlined,
  'Personal': Icons.person_outline,
  'Istirahat': Icons.free_breakfast_outlined,
  'Sosial': Icons.groups_outlined,
  'Olahraga': Icons.fitness_center_outlined,
};

IconData kategoriIcon(String kategori) => kKategoriIcons[kategori] ?? Icons.event_outlined;
