import 'package:flutter/material.dart';

import '../../core/db/database.dart';
import '../../core/notifications/notification_gateway.dart';
import '../../core/notifications/reminder_scheduler.dart';
import '../activity/activity_home_screen.dart';

/// Owns the session's reminder scheduler. Home provides the responsive five-item navigation.
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
  Widget build(BuildContext context) => ActivityHomeScreen(
      db: widget.db, userId: widget.userId, deviceId: widget.deviceId);
}
