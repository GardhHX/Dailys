import 'package:flutter/material.dart';

import '../../core/db/database.dart';
import '../../l10n/app_localizations.dart';
import '../activity/activity_home_screen.dart';
import '../tugas/tugas_list_screen.dart';

/// Bottom-nav shell for the primary tabs (PRD Section 7). M1 ships Home and
/// Tugas; Pomodoro/Timebox (M3), Habit/Keuangan (M4), and Weekly Review (M5)
/// tabs are intentionally absent rather than faked (M1-PLAN Section 4). Each
/// tab keeps its own Scaffold (AppBar/FAB); this shell only owns the
/// NavigationBar and preserves each tab's state via an IndexedStack.
class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.db,
    required this.userId,
    required this.deviceId,
  });

  final AppDatabase db;
  final String userId;
  final String deviceId;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          ActivityHomeScreen(
            db: widget.db,
            userId: widget.userId,
            deviceId: widget.deviceId,
          ),
          TugasListScreen(
            db: widget.db,
            userId: widget.userId,
            deviceId: widget.deviceId,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.checklist_outlined),
            selectedIcon: const Icon(Icons.checklist),
            label: l10n.navTugas,
          ),
        ],
      ),
    );
  }
}
