import 'package:flutter/material.dart';
import '../../app/theme/design_form.dart';
import 'package:intl/intl.dart';

import '../../app/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import 'activity_home_cubit.dart';
import '../../core/db/database.dart';
import '../../core/time/local_date.dart';
import 'package:timezone/timezone.dart' as tz;

/// Opens the "Tambah Activity" form (design/screens/home.md "Tambah Activity/
/// Timebox melalui modal"). Activity may be created without a time; a
/// recurring series creates an `ActivityRecurrence` template instead of a
/// single occurrence and triggers the materializer immediately.
Future<void> showAddActivitySheet(BuildContext context,
    {required ActivityHomeCubit cubit,
    ActivityRow? existing,
    LocalDate? date,
    TimeOfDay? initialTime}) {
  return showDialog<void>(
    context: context,
    builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: _AddActivitySheet(
                cubit: cubit,
                existing: existing,
                date: date,
                initialTime: initialTime))),
  );
}

class _AddActivitySheet extends StatefulWidget {
  const _AddActivitySheet(
      {required this.cubit, this.existing, this.date, this.initialTime});
  final ActivityHomeCubit cubit;
  final ActivityRow? existing;
  final LocalDate? date;
  final TimeOfDay? initialTime;

  @override
  State<_AddActivitySheet> createState() => _AddActivitySheetState();
}

class _AddActivitySheetState extends State<_AddActivitySheet> {
  late final TextEditingController _judulController;
  String? _categoryId;
  final bool _isTimebox = false;
  bool _saving = false;
  bool _isAllDay = false;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isRecurring = false;
  final Set<int> _recurringDays = {};
  String? _error;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _judulController = TextEditingController(text: existing?.judul ?? '');
    _categoryId = widget.cubit.state.categories
            .any((c) => c.id == existing?.activityCategoryId)
        ? existing?.activityCategoryId
        : null;
    _isAllDay = existing?.isAllDay ?? false;
    final location = tz.getLocation(widget.cubit.timezone);
    _startTime = existing?.startTime == null
        ? widget.initialTime
        : TimeOfDay.fromDateTime(
            tz.TZDateTime.from(existing!.startTime!, location));
    _endTime = existing?.endTime == null
        ? null
        : TimeOfDay.fromDateTime(
            tz.TZDateTime.from(existing!.endTime!, location));
    if (widget.initialTime != null) {
      _endTime = TimeOfDay(
          hour: (widget.initialTime!.hour + 1).clamp(0, 23),
          minute: widget.initialTime!.minute);
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = widget.cubit.state.categories;
    final weekdayLabels = _weekdayShortLabels(context);

    return DesignModal(
      title: widget.existing == null
          ? l10n.activityAddTitle
          : l10n.homeEditActivity,
      saveLabel: l10n.activitySave,
      titleSize: 19,
      busy: _saving,
      onSave: _submit,
      children: [
        Text(l10n.activityTypeLabel,
            style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<bool>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: false, label: Text(l10n.activityTypeActivity)),
            ButtonSegment(
                value: true,
                enabled: false,
                label: Text(l10n.activityTypeTimebox)),
          ],
          selected: {_isTimebox},
          onSelectionChanged: (_) {},
        ),
        const SizedBox(height: 6),
        Text(l10n.homeTimeboxIntegrationGap,
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: AppSpacing.md),
        DesignField(
            label: l10n.activityFieldTitle,
            child: TextField(
              style:
                  Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
              controller: _judulController,
              onSubmitted: (_) => _submit(),
              autofocus: true,
              decoration: const InputDecoration(),
            )),
        const SizedBox(height: AppSpacing.md),
        DesignField(
            label: l10n.activityFieldCategory,
            child: DropdownButtonFormField<String>(
              style:
                  Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
              initialValue: _categoryId,
              isExpanded: true,
              decoration: const InputDecoration(),
              items: categories
                  .map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.nama, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (v) => setState(() => _categoryId = v),
            )),
        if (!_isTimebox)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.activityAllDaySwitch),
            value: _isAllDay,
            onChanged: (v) => setState(() => _isAllDay = v),
          ),
        if (!_isAllDay) ...[
          Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                Text(l10n.activityStartTimeLabel),
                TextButton(
                    onPressed: () async {
                      final now = tz.TZDateTime.now(
                          tz.getLocation(widget.cubit.timezone));
                      final picked = await showTimePicker(
                          context: context,
                          initialTime:
                              _startTime ?? TimeOfDay.fromDateTime(now));
                      if (picked != null && mounted) {
                        setState(() => _startTime = picked);
                      }
                    },
                    child: Text(_startTime?.format(context) ?? '--:--')),
              ]),
          Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                Text(l10n.activityEndTimeLabel),
                TextButton(
                    onPressed: () async {
                      final now = tz.TZDateTime.now(
                          tz.getLocation(widget.cubit.timezone));
                      final picked = await showTimePicker(
                          context: context,
                          initialTime: _endTime ?? TimeOfDay.fromDateTime(now));
                      if (picked != null && mounted) {
                        setState(() => _endTime = picked);
                      }
                    },
                    child: Text(_endTime?.format(context) ?? '--:--')),
              ]),
          if (_startTime != null || _endTime != null)
            TextButton(
                onPressed: () => setState(() {
                      _startTime = null;
                      _endTime = null;
                    }),
                child: Text(l10n.homeClearTime)),
        ],
        if (!_isTimebox && widget.existing == null)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.activityRecurringSwitch),
            value: _isRecurring,
            onChanged: (v) => setState(() => _isRecurring = v),
          ),
        if (_isRecurring && !_isTimebox) ...[
          Text(l10n.activityRecurringDaysLabel,
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: List.generate(7, (i) {
              final weekday = i + 1;
              final selected = _recurringDays.contains(weekday);
              return FilterChip(
                label: Text(weekdayLabels[i]),
                selected: selected,
                onSelected: (v) => setState(() {
                  if (v) {
                    _recurringDays.add(weekday);
                  } else {
                    _recurringDays.remove(weekday);
                  }
                }),
              );
            }),
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(_error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
      ],
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final judul = _judulController.text.trim();
    if (judul.isEmpty) {
      setState(() => _error = l10n.activityTitleRequired);
      return;
    }
    if (_categoryId == null) {
      setState(() => _error = l10n.activityCategoryRequired);
      return;
    }
    DateTime? startInstant;
    DateTime? endInstant;
    final today = widget.date ??
        (widget.existing == null
            ? widget.cubit.state.date
            : LocalDate.parse(widget.existing!.occurrenceDate));
    if (!_isAllDay && _startTime != null) {
      startInstant =
          widget.cubit.localTime(today, _startTime!.hour, _startTime!.minute);
    }
    if (!_isAllDay && _endTime != null) {
      endInstant =
          widget.cubit.localTime(today, _endTime!.hour, _endTime!.minute);
    }
    if (endInstant != null &&
        (startInstant == null || !endInstant.isAfter(startInstant))) {
      setState(() => _error = l10n.activityEndAfterStart);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (widget.existing != null) {
        await widget.cubit.editManualActivity(
            existing: widget.existing!,
            judul: judul,
            activityCategoryId: _categoryId!,
            isAllDay: _isAllDay,
            startTime: startInstant,
            endTime: endInstant);
      } else if (_isRecurring) {
        if (_recurringDays.isEmpty) {
          setState(() {
            _error = l10n.activityRecurringDaysRequired;
            _saving = false;
          });
          return;
        }
        await widget.cubit.createRecurringSeries(
          judul: judul,
          activityCategoryId: _categoryId!,
          recurringDays: _recurringDays.toList()..sort(),
          startsOn: today,
          isAllDay: _isAllDay,
          startTime:
              _isAllDay || _startTime == null ? null : _formatTod(_startTime!),
          endTime: _isAllDay || _endTime == null ? null : _formatTod(_endTime!),
        );
      } else {
        await widget.cubit.createManualActivity(
          date: today,
          judul: judul,
          activityCategoryId: _categoryId!,
          isAllDay: _isAllDay,
          startTime: startInstant,
          endTime: endInstant,
        );
      }

      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _error = l10n.homeSaveFailed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _formatTod(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  /// Locale-aware Mon..Sun abbreviations, driven by `intl` rather than a
  /// hand-rolled id/en array (NFR-7: resources are the source of truth, not
  /// strings baked into feature code).
  List<String> _weekdayShortLabels(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final fmt = DateFormat.E(locale);
    // 2024-01-01 was a Monday; iterating from there covers ISO weekdays 1..7.
    return List.generate(7, (i) => fmt.format(DateTime(2024, 1, 1 + i)));
  }
}
