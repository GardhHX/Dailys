import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Toggle "Dark mode" di sidebar (ada di file desain Claude Design, belum
/// ada di app sebelumnya) — switch biner light/dark, bukan 3-state
/// light/dark/system, konsisten dengan toggle sederhana di file desain.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);
