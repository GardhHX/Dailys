import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import 'activity_home_cubit.dart';

/// Opens the "Tambah Activity" form (design/screens/home.md "Tambah Activity/
/// Timebox melalui modal"). Activity may be created without a time; a
/// recurring series creates an `ActivityRecurrence` template instead of a
/// single occurrence and triggers the materializer immediately.
Future<void> showAddActivitySheet(BuildContext context,
    {required ActivityHomeCubit cubit}) {
  return showDialog<void>(
    context: context,
    builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: _AddActivitySheet(cubit: cubit))),
  );
}

class _AddActivitySheet extends StatefulWidget {
  const _AddActivitySheet({required this.cubit});
  final ActivityHomeCubit cubit;

  @override
  State<_AddActivitySheet> createState() => _AddActivitySheetState();
}

class _AddActivitySheetState extends State<_AddActivitySheet> {
  final _judulController = TextEditingController();
  String? _categoryId;
  bool _isTimebox = false;
  bool _isAllDay = false;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isRecurring = false;
  final Set<int> _recurringDays = {};
  String? _error;

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

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Expanded(
                  child: Text(l10n.activityAddTitle,
                      style: Theme.of(context).textTheme.titleLarge)),
              IconButton(
                  tooltip: l10n.closeDialog,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close))
            ]),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.activityTypeLabel,
                style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                    value: false, label: Text(l10n.activityTypeActivity)),
                ButtonSegment(
                    value: true, label: Text(l10n.activityTypeTimebox)),
              ],
              selected: {_isTimebox},
              onSelectionChanged: (v) => setState(() {
                _isTimebox = v.first;
                if (_isTimebox) {
                  _isAllDay = false;
                  _isRecurring = false;
                }
              }),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _judulController,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.activityFieldTitle),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _categoryId,
              isExpanded: true,
              decoration:
                  InputDecoration(labelText: l10n.activityFieldCategory),
              items: categories
                  .map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.nama, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (v) => setState(() => _categoryId = v),
            ),
            if (!_isTimebox)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.activityAllDaySwitch),
                value: _isAllDay,
                onChanged: (v) => setState(() => _isAllDay = v),
              ),
            if (!_isAllDay) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.activityStartTimeLabel),
                trailing: Text(_startTime?.format(context) ?? '--:--'),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _startTime ?? TimeOfDay.now(),
                  );
                  if (picked != null) setState(() => _startTime = picked);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.activityEndTimeLabel),
                trailing: Text(_endTime?.format(context) ?? '--:--'),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _endTime ?? TimeOfDay.now(),
                  );
                  if (picked != null) setState(() => _endTime = picked);
                },
              ),
            ],
            if (!_isTimebox)
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
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(onPressed: _submit, child: Text(l10n.activitySave)),
          ],
        ),
      ),
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
    final today = widget.cubit.state.date;
    if (!_isAllDay && _startTime != null) {
      final local = DateTime(today.year, today.month, today.day,
          _startTime!.hour, _startTime!.minute);
      startInstant = local.toUtc();
    }
    if (!_isAllDay && _endTime != null) {
      final local = DateTime(
          today.year, today.month, today.day, _endTime!.hour, _endTime!.minute);
      endInstant = local.toUtc();
    }
    if (startInstant != null &&
        endInstant != null &&
        !endInstant.isAfter(startInstant)) {
      setState(() => _error = l10n.activityEndAfterStart);
      return;
    }

    if (_isTimebox) {
      if (startInstant == null || endInstant == null) {
        setState(() => _error = l10n.timeboxNeedsTime);
        return;
      }
      await widget.cubit.createTimeboxOccurrence(
        judul: judul,
        activityCategoryId: _categoryId!,
        startTime: startInstant,
        endTime: endInstant,
      );
      if (mounted) Navigator.of(context).pop();
      return;
    }

    if (_isRecurring) {
      if (_recurringDays.isEmpty) {
        setState(() => _error = l10n.activityRecurringDaysRequired);
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
        judul: judul,
        activityCategoryId: _categoryId!,
        isAllDay: _isAllDay,
        startTime: startInstant,
        endTime: endInstant,
      );
    }

    if (mounted) Navigator.of(context).pop();
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
