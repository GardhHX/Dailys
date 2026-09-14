import 'package:flutter/material.dart';

import '../../core/db/database.dart';
import '../../core/notifications/notification_gateway.dart';
import '../../core/notifications/reminder_scheduler.dart';
import '../../l10n/app_localizations.dart';
import '../activity/activity_home_screen.dart';
import '../pomodoro/pomodoro_screen.dart';
import '../tugas/tugas_list_screen.dart';

/// Bottom-nav shell for the primary tabs (PRD Section 7). M1 shipped Home and
/// Tugas; M3 adds Pomodoro. Habit/Keuangan (M4) and Weekly Review (M5) tabs
/// are still intentionally absent rather than faked (M1-PLAN Section 4). Each
/// tab keeps its own Scaffold (AppBar/FAB); this shell only owns the
/// NavigationBar and preserves each tab's state via an IndexedStack.
///
/// Also owns the single, app-wide [ReminderScheduler] instance (FR-1.10,
/// FR-6.4): one poller for the whole session, started once identity is known
/// and stopped when the shell goes away, rather than one per tab/screen.
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
  late final ReminderScheduler _reminderScheduler = ReminderScheduler(
    db: widget.db,
    userId: widget.userId,
    gateway: LocalNotifierGateway(),
  )..start();

  @override
  void dispose() {
    _reminderScheduler.stop();
    super.dispose();
  }

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
          PomodoroScreen(
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
          NavigationDestination(
            icon: const Icon(Icons.timer_outlined),
            selectedIcon: const Icon(Icons.timer),
            label: l10n.navPomodoro,
          ),
        ],
      ),
    );
  }
}
