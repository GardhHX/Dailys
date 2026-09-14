import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme/tokens.dart';
import '../../core/db/daos/timebox_dao.dart';
import '../../core/db/database.dart';
import '../../core/db/tables/enums.dart';
import '../../core/time/local_date.dart';
import '../../l10n/app_localizations.dart';
import 'timebox_cubit.dart';

Color? timeboxCategoryColor(
    List<ActivityCategoryRow> categories, String categoryId) {
  final category = categories.where((c) => c.id == categoryId).firstOrNull;
  if (category == null) return null;
  final clean = category.warna.replaceFirst('#', '');
  return Color(int.parse('FF$clean', radix: 16));
}

String? timeboxCategoryName(
        List<ActivityCategoryRow> categories, String categoryId) =>
    categories.where((c) => c.id == categoryId).firstOrNull?.nama;

String timeboxStatusLabel(TimeboxExecutionRow execution, AppLocalizations l10n) {
  switch (execution.status) {
    case TimeboxExecutionStatus.pending:
      return execution.actualStartAt != null
          ? l10n.timeboxBlockStarted
          : l10n.timeboxNotStarted;
    case TimeboxExecutionStatus.completed:
      return l10n.activityStatusSelesai;
    case TimeboxExecutionStatus.missed:
      return l10n.timeboxStatusMissed;
    case TimeboxExecutionStatus.skipped:
      return l10n.timeboxStatusSkipped;
    case TimeboxExecutionStatus.rescheduled:
      return l10n.timeboxStatusRescheduled;
  }
}

/// A pending/missed/skipped/rescheduled TimeboxExecution rendered like
/// `_AgendaEntry` (design/screens/home.md "Timebox terpilih memakai bidang
/// indigo dominan"). Completed occurrences never reach this widget — their
/// derived Activity is the single displayed unit instead.
class TimeboxAgendaCard extends StatelessWidget {
  const TimeboxAgendaCard({
    super.key,
    required this.occurrence,
    required this.categories,
    required this.cubit,
    required this.l10n,
    required this.feature,
    required this.onTap,
  });

  final TimeboxOccurrence occurrence;
  final List<ActivityCategoryRow> categories;
  final TimeboxCubit cubit;
  final AppLocalizations l10n;
  final bool feature;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final execution = occurrence.execution;
    final schedule = occurrence.schedule;
    final onSurface = feature ? colors.onPrimary : colors.onSurface;
    final muted = feature ? colors.onPrimary : colors.onSurfaceVariant;
    final chipColor = feature
        ? colors.onPrimary
        : (timeboxCategoryColor(categories, schedule.activityCategoryId) ?? muted);
    final categoryName = timeboxCategoryName(categories, schedule.activityCategoryId);
    final range =
        '${cubit.formatTime(execution.plannedStartAt)}–${cubit.formatTime(execution.plannedEndAt)}';
    final recurringSuffix =
        schedule.isRecurring ? ' · ${l10n.activityRecurringWeekly}' : '';

    return Material(
      color: feature ? colors.primary : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: feature ? colors.primary : colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(feature ? 20 : 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Row(children: [
                  Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                          color: chipColor,
                          borderRadius: BorderRadius.circular(AppRadius.status - 2))),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                        '${categoryName == null ? '' : '$categoryName · '}${l10n.activityTypeTimebox}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600, color: chipColor)),
                  ),
                ]),
              ),
              const SizedBox(width: 8),
              Text(timeboxStatusLabel(execution, l10n),
                  style: TextStyle(fontSize: 11, color: muted)),
            ]),
            SizedBox(height: feature ? 11 : 7),
            Text(schedule.judul,
                style: TextStyle(
                    fontSize: feature ? 21 : 15,
                    height: feature ? 1.25 : null,
                    letterSpacing: feature ? -0.4 : null,
                    fontWeight: FontWeight.w600,
                    color: onSurface)),
            SizedBox(height: feature ? 8 : 5),
            Text('$range$recurringSuffix', style: TextStyle(fontSize: 12, color: muted)),
          ]),
        ),
      ),
    );
  }
}

/// Compact grid-cell chip for `_WeekGrid` (indigo, per design/screens/home.md).
class TimeboxGridChip extends StatelessWidget {
  const TimeboxGridChip({
    super.key,
    required this.occurrence,
    required this.cubit,
    required this.onTap,
  });

  final TimeboxOccurrence occurrence;
  final TimeboxCubit cubit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Material(
        color: colors.primary,
        borderRadius: BorderRadius.circular(AppRadius.denseCell),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Text(
                '${cubit.formatTime(occurrence.execution.plannedStartAt)}\n${occurrence.schedule.judul}',
                style: TextStyle(fontSize: 10, color: colors.onPrimary)),
          ),
        ),
      ),
    );
  }
}

Widget _metaLine(BuildContext context, String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            width: 90,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
        Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
      ]),
    );

/// Detail sheet for one occurrence: plan/actual, start/complete/skip
/// (FR-3.6, 3.12), reschedule (FR-3.7), and template-level actions
/// (deactivate FR-3.12, duplicate FR-3.11).
Future<void> showTimeboxOccurrenceDetail(
  BuildContext context, {
  required TimeboxOccurrence occurrence,
  required TimeboxCubit cubit,
  required List<ActivityCategoryRow> categories,
  required AppLocalizations l10n,
}) {
  final theme = Theme.of(context);
  final execution = occurrence.execution;
  final schedule = occurrence.schedule;
  final isPending = execution.status == TimeboxExecutionStatus.pending;
  final started = execution.actualStartAt != null;
  String hm(DateTime? i) => i == null ? '' : cubit.formatTime(i);
  final planText = '${hm(execution.plannedStartAt)}–${hm(execution.plannedEndAt)}';
  final actualText =
      execution.actualStartAt == null ? l10n.timeboxNotStarted : hm(execution.actualStartAt);

  Future<void> run(Future<void> Function() action) async {
    try {
      await action();
    } on TimeboxCommandException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
      return;
    }
    if (context.mounted) Navigator.pop(context);
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.timeboxDetailTitle,
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(schedule.judul, style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.md),
            _metaLine(context, l10n.activityFieldCategory,
                timeboxCategoryName(categories, schedule.activityCategoryId) ?? '—'),
            _metaLine(context, l10n.tugasFilterStatus, timeboxStatusLabel(execution, l10n)),
            _metaLine(context, l10n.timeboxPlan, planText),
            _metaLine(context, l10n.timeboxActual, actualText),
            const SizedBox(height: AppSpacing.md),
            Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: [
              if (isPending && !started)
                FilledButton.icon(
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: Text(l10n.timeboxStart),
                  onPressed: () => run(() => cubit.start(execution.id)),
                ),
              if (isPending)
                FilledButton.icon(
                  icon: const Icon(Icons.check, size: 18),
                  label: Text(l10n.timeboxComplete),
                  onPressed: () => run(() => cubit.complete(execution.id)),
                ),
              if (isPending)
                OutlinedButton(
                  onPressed: () => run(() => cubit.skip(execution.id)),
                  child: Text(l10n.timeboxSkip),
                ),
              if (isPending)
                OutlinedButton(
                  onPressed: () async {
                    final target = await pickTimeboxRescheduleTarget(sheetContext,
                        execution: execution, cubit: cubit, l10n: l10n);
                    if (target == null) return;
                    await run(() => cubit.reschedule(
                        sourceExecutionId: execution.id, targetStart: target));
                  },
                  child: Text(l10n.timeboxRescheduleAction),
                ),
            ]),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),
            Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: [
              TextButton.icon(
                icon: Icon(schedule.isActive ? Icons.pause_circle_outline : Icons.play_circle_outline, size: 18),
                label: Text(schedule.isActive
                    ? l10n.timeboxDeactivateTemplate
                    : l10n.timeboxReactivateTemplate),
                onPressed: () async {
                  await cubit.setScheduleActive(schedule.id, !schedule.isActive);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.copy_outlined, size: 18),
                label: Text(l10n.timeboxDuplicateAction),
                onPressed: () async {
                  Navigator.pop(sheetContext);
                  await showTimeboxDuplicateDialog(context,
                      schedule: schedule, cubit: cubit, l10n: l10n);
                },
              ),
            ]),
          ],
        ),
      ),
    ),
  );
}

/// FR-3.7 reschedule target picker: date then time-of-day, resolved to an
/// Instant through [cubit] so this widget never touches `tz.Location`
/// directly (the resolution applies the same DST policy as materialization).
Future<DateTime?> pickTimeboxRescheduleTarget(
  BuildContext context, {
  required TimeboxExecutionRow execution,
  required TimeboxCubit cubit,
  required AppLocalizations l10n,
}) async {
  final initialDate = execution.plannedStartAt.toLocal();
  final date = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime.now().subtract(const Duration(days: 365)),
    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
  );
  if (date == null || !context.mounted) return null;
  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initialDate),
  );
  if (time == null) return null;
  return cubit.resolveLocalInstant(
      LocalDate(date.year, date.month, date.day), time.hour, time.minute);
}

/// FR-3.7 "Missed Block Review": a grouped list of still-pending occurrences
/// whose planned end already passed, each with the three PRD outcomes.
Future<void> showMissedTimeboxReview(
  BuildContext context, {
  required List<TimeboxOccurrence> missed,
  required TimeboxCubit cubit,
  required AppLocalizations l10n,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.timeboxReviewTitle, style: Theme.of(sheetContext).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 420),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: missed.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, i) => _missedRow(context, missed[i], cubit, l10n),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _missedRow(
    BuildContext context, TimeboxOccurrence occurrence, TimeboxCubit cubit, AppLocalizations l10n) {
  final execution = occurrence.execution;
  Future<void> run(Future<void> Function() action) async {
    try {
      await action();
    } on TimeboxCommandException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(occurrence.schedule.judul, style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 2),
      Text(
          '${cubit.formatTime(execution.plannedStartAt)}–${cubit.formatTime(execution.plannedEndAt)}',
          style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: AppSpacing.sm),
      Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: [
        OutlinedButton(
          onPressed: () => run(() => cubit.markMissed(execution.id)),
          child: Text(l10n.timeboxMarkMissedAction),
        ),
        OutlinedButton(
          onPressed: () async {
            final target = await pickTimeboxRescheduleTarget(context,
                execution: execution, cubit: cubit, l10n: l10n);
            if (target == null) return;
            await run(() =>
                cubit.reschedule(sourceExecutionId: execution.id, targetStart: target));
          },
          child: Text(l10n.timeboxRescheduleAction),
        ),
        TextButton(
          onPressed: () => cubit.dismissMissedPromptForToday(execution.id),
          child: Text(l10n.timeboxStillValidAction),
        ),
      ]),
    ]),
  );
}

/// FR-3.11: duplicate a template to another weekday (recurring) or another
/// explicit date (ad-hoc).
Future<void> showTimeboxDuplicateDialog(
  BuildContext context, {
  required TimeboxScheduleRow schedule,
  required TimeboxCubit cubit,
  required AppLocalizations l10n,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.timeboxDuplicateTitle),
      content: schedule.isRecurring
          ? _DuplicateDaysPicker(schedule: schedule, cubit: cubit, l10n: l10n)
          : _DuplicateDatePicker(schedule: schedule, cubit: cubit, l10n: l10n),
    ),
  );
}

class _DuplicateDaysPicker extends StatefulWidget {
  const _DuplicateDaysPicker({required this.schedule, required this.cubit, required this.l10n});
  final TimeboxScheduleRow schedule;
  final TimeboxCubit cubit;
  final AppLocalizations l10n;

  @override
  State<_DuplicateDaysPicker> createState() => _DuplicateDaysPickerState();
}

class _DuplicateDaysPickerState extends State<_DuplicateDaysPicker> {
  final Set<int> _days = {};

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(widget.l10n.timeboxDuplicatePickDay),
      const SizedBox(height: AppSpacing.sm),
      Wrap(
        spacing: AppSpacing.sm,
        children: List.generate(7, (i) {
          final day = i + 1;
          if (day == widget.schedule.hari) return const SizedBox.shrink();
          final selected = _days.contains(day);
          return FilterChip(
            label: Text(_weekdayShort(context, day)),
            selected: selected,
            onSelected: (v) => setState(() => v ? _days.add(day) : _days.remove(day)),
          );
        }),
      ),
      const SizedBox(height: AppSpacing.md),
      FilledButton(
        onPressed: _days.isEmpty
            ? null
            : () async {
                for (final day in _days) {
                  await widget.cubit.duplicateToDay(widget.schedule, newHari: day);
                }
                if (context.mounted) Navigator.pop(context);
              },
        child: Text(widget.l10n.actionContinue),
      ),
    ]);
  }

  /// Locale-aware Mon..Sun abbreviation (same approach as
  /// `add_activity_sheet.dart._weekdayShortLabels`).
  String _weekdayShort(BuildContext context, int weekday) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.E(locale).format(DateTime(2024, 1, weekday));
  }
}

class _DuplicateDatePicker extends StatelessWidget {
  const _DuplicateDatePicker({required this.schedule, required this.cubit, required this.l10n});
  final TimeboxScheduleRow schedule;
  final TimeboxCubit cubit;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(l10n.timeboxDuplicatePickDate),
      const SizedBox(height: AppSpacing.md),
      FilledButton(
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now().subtract(const Duration(days: 1)),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (picked == null) return;
          await cubit.duplicateToDay(schedule,
              newDate: LocalDate(picked.year, picked.month, picked.day));
          if (context.mounted) Navigator.pop(context);
        },
        child: Text(l10n.actionContinue),
      ),
    ]);
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
