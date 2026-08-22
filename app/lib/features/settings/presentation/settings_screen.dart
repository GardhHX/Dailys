import 'package:flutter/material.dart';

/// Placeholder — Settings lengkap (bahasa, status sync, tentang app) ada di
/// Phase 8 (Polish) sesuai PLAN.md. Link "Settings" di sidebar sudah ada di
/// file desain Claude Design sejak awal, jadi entry-point-nya dibuat
/// sekarang supaya UI tidak timpang, isinya menyusul di Phase 8.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings — Phase 8')),
    );
  }
}
