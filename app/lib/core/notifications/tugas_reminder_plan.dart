import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../l10n/app_localizations.dart';
import '../db/database.dart';
import '../db/tables/enums.dart';
import '../reminders/task_reminder.dart';
import '../time/local_date.dart';
import 'planned_reminder.dart';

/// Reminder instances for one Tugas (schema 5, FR-6.4): each typed reminder
/// (`calendar_day` or `relative_minutes`) resolved to a concrete Instant.
/// Returns nothing once the task is `selesai` — completing it stops firing
/// pending reminders without a separate cancel step, matching how Activity
/// reminders stop once `belum_mulai` no longer holds.
List<PlannedReminder> planTugasReminders(
  TugasRow row, {
  required AppLocalizations l10n,
  required tz.Location location,
}) {
  if (row.isDeleted || row.status == TugasStatus.selesai) return const [];

  final reminders = TaskReminder.fromJsonList(row.reminders);
  if (reminders.isEmpty) return const [];

  final deadlineLocal = tz.TZDateTime.from(row.deadline, location);
  final dateLabel = DateFormat.yMMMd().format(deadlineLocal);
  final timeLabel = DateFormat.Hm().format(deadlineLocal);
  final body = l10n.reminderTugasBody(dateLabel, timeLabel);
  final deadlineLocalDate =
      LocalDate(deadlineLocal.year, deadlineLocal.month, deadlineLocal.day);

  final out = <PlannedReminder>[];
  for (final r in reminders) {
    final DateTime fireAt;
    if (r is CalendarDayReminder) {
      final fireDate = r.fireDate(deadlineLocalDate);
      final t = r.localTime.split(':').map(int.parse).toList();
      fireAt = tz.TZDateTime(
        location,
        fireDate.year,
        fireDate.month,
        fireDate.day,
        t[0],
        t.length > 1 ? t[1] : 0,
        t.length > 2 ? t[2] : 0,
      ).toUtc();
    } else if (r is RelativeMinutesReminder) {
      fireAt = r.fireInstant(row.deadline);
    } else {
      continue;
    }
    out.add(PlannedReminder(
      id: 'tugas:${row.id}:${r.canonicalKey}',
      fireAt: fireAt,
      title: row.judul,
      body: body,
    ));
  }
  return out;
}
