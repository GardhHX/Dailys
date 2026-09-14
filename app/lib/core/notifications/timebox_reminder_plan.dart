import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../l10n/app_localizations.dart';
import '../db/daos/timebox_dao.dart';
import '../db/tables/enums.dart';
import 'planned_reminder.dart';

/// Reminder instances for one TimeboxExecution occurrence (schema 10/10.1,
/// FR-3.13): `reminder_offsets_minutes` before `planned_start_at`. Returns
/// nothing once the occurrence is no longer `pending` (started, completed,
/// missed, skipped, or rescheduled all naturally stop it firing, same as
/// `planActivityReminders`).
///
/// TimeboxExecution carries no `reminder_offsets_minutes` of its own (unlike
/// Activity, which snapshots the template's reminders at materialization
/// time) — schema 10.1 only snapshots *time* fields, not content. So this
/// reads the schedule's *current* offsets against the execution's immutable
/// `planned_start_at`. That still honors "edit reminder hanya berlaku untuk
/// execution yang belum dimaterialisasi" in the sense that matters
/// operationally: a schedule edit can only ever change a reminder that has
/// not fired yet (every candidate here is still `pending`, i.e. still in the
/// future or not yet resolved); it can never resurrect or rewrite a reminder
/// for an execution that already started, completed, was skipped, or missed.
List<PlannedReminder> planTimeboxReminders(
  TimeboxOccurrence occurrence, {
  required AppLocalizations l10n,
  required tz.Location location,
}) {
  final execution = occurrence.execution;
  final schedule = occurrence.schedule;
  if (execution.isDeleted || schedule.isDeleted) return const [];
  if (execution.status != TimeboxExecutionStatus.pending) return const [];

  final start = execution.plannedStartAt;
  final localTime = tz.TZDateTime.from(start, location);
  final timeLabel = DateFormat.Hm().format(localTime);

  return [
    for (final offset in schedule.reminderOffsetsMinutes)
      PlannedReminder(
        id: 'timebox:${execution.id}:$offset',
        fireAt: start.subtract(Duration(minutes: offset)),
        title: schedule.judul,
        body: l10n.reminderTimeboxBody(timeLabel),
      ),
  ];
}
