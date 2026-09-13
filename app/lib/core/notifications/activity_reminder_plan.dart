import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../l10n/app_localizations.dart';
import '../db/database.dart';
import '../db/tables/enums.dart';
import 'planned_reminder.dart';

/// Reminder instances for one Activity occurrence (schema 8, FR-1.10):
/// `reminder_offsets_minutes` before `start_time`. Returns nothing for
/// all-day/flexible occurrences (which must carry no reminders — schema 8
/// invariant) or once the occurrence is no longer `belum_mulai`, so
/// completing/skipping/deleting a task naturally stops firing it without a
/// separate cancel step.
List<PlannedReminder> planActivityReminders(
  ActivityRow row, {
  required AppLocalizations l10n,
  required tz.Location location,
}) {
  if (row.isDeleted || row.isAllDay || row.startTime == null) return const [];
  if (row.status != ActivityStatus.belum_mulai) return const [];

  final start = row.startTime!;
  final localTime = tz.TZDateTime.from(start, location);
  final timeLabel = DateFormat.Hm().format(localTime);

  return [
    for (final offset in row.reminderOffsetsMinutes)
      PlannedReminder(
        id: 'activity:${row.id}:$offset',
        fireAt: start.subtract(Duration(minutes: offset)),
        title: row.judul,
        body: l10n.reminderActivityBody(timeLabel),
      ),
  ];
}
