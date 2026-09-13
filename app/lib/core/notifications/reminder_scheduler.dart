import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../l10n/app_localizations.dart';
import '../db/database.dart';
import 'activity_reminder_plan.dart';
import 'notification_gateway.dart';
import 'planned_reminder.dart';
import 'tugas_reminder_plan.dart';

/// Drives Activity and Tugas reminders (FR-1.10, FR-6.4) by polling rather
/// than pre-scheduling: `local_notifier` has no OS-level "fire this at time
/// T" API (unlike `flutter_local_notifications`, which isn't available on
/// Windows at all — see `notification_gateway.dart`), so this recomputes the
/// full candidate set on every tick and fires whatever just became due.
///
/// That polling design also means there is no separate cancel/reschedule
/// path: editing a reminder changes its [PlannedReminder.id], and completing/
/// skipping/deleting a row drops it from the candidate set entirely, so a
/// stale reminder simply stops being planned and is pruned from [_fired] —
/// nothing to explicitly cancel.
class ReminderScheduler {
  ReminderScheduler({
    required AppDatabase db,
    required String userId,
    required NotificationGateway gateway,
    this.tickInterval = const Duration(seconds: 60),
    this.graceWindow = const Duration(minutes: 5),
    DateTime Function()? clock,
  })  : _db = db,
        _userId = userId,
        _gateway = gateway,
        _clock = clock ?? (() => DateTime.now().toUtc());

  final AppDatabase _db;
  final String _userId;
  final NotificationGateway _gateway;
  final DateTime Function() _clock;
  final Duration tickInterval;

  /// Reminders due more than this long ago the first time this scheduler
  /// ever sees them are treated as already-lapsed (never notified) rather
  /// than fired late — matches "trigger yang sudah lewat ... tidak
  /// ditembakkan ulang" (schema 5 / FR-1.10, FR-6.4).
  final Duration graceWindow;

  Timer? _timer;
  final Set<String> _fired = {};

  void start() {
    unawaited(_gateway.initialize());
    unawaited(tick());
    _timer ??= Timer.periodic(tickInterval, (_) => tick());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Runs one poll: fetches active reminder candidates, plans their fire
  /// times, and notifies for whatever is newly due. Exposed (not private) so
  /// tests can call it directly instead of waiting on a real [Timer].
  Future<void> tick() async {
    final now = _clock();
    final settings = await _db.settingsDao.getUserSettings(_userId);
    if (settings == null) return; // identity not provisioned yet
    if (!settings.notificationsEnabled) return; // user turned reminders off

    final location = tz.getLocation(settings.timezone);
    final l10n = lookupAppLocalizations(Locale(settings.language.name));

    final activities = await _db.activityDao.getReminderCandidates(_userId);
    final tugasRows = await _db.tugasDao.getReminderCandidates(_userId);

    final planned = <PlannedReminder>[
      for (final a in activities)
        ...planActivityReminders(a, l10n: l10n, location: location),
      for (final t in tugasRows)
        ...planTugasReminders(t, l10n: l10n, location: location),
    ];

    final validIds = planned.map((p) => p.id).toSet();
    _fired.retainAll(validIds);

    for (final p in planned) {
      if (_fired.contains(p.id)) continue;
      if (p.fireAt.isAfter(now)) continue;
      if (p.fireAt.isBefore(now.subtract(graceWindow))) {
        _fired.add(p.id); // already lapsed; never fire it
        continue;
      }
      await _gateway.notifyNow(id: p.id, title: p.title, body: p.body);
      _fired.add(p.id);
    }
  }
}
