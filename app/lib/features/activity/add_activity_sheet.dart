import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme/tokens.dart';
import '../../core/db/database.dart';
import '../../core/time/local_date.dart';
import '../../l10n/app_localizations.dart';
import '../timebox/timebox_cubit.dart';
import 'activity_home_cubit.dart';

/// Opens the "Tambah Activity" form (design/screens/home.md "Tambah Activity/
/// Timebox melalui modal"). Activity may be created without a time; a
/// recurring series creates an `ActivityRecurrence` template (Activity) or a
/// `TimeboxSchedule` (Timebox, FR-3.1) instead of a single occurrence, and
/// triggers the relevant materializer immediately.
///
/// [timeboxCubit] is required to actually submit a Timebox block; when null
/// the Timebox segment is still shown (so the modal stays the single
/// "Tambah Activity/Timebox" entry point design/screens/home.md calls for)
/// but submission is disabled with an explanatory error, rather than
/// silently no-oping. [initialDate]/[initialStartTime] prefill from a
/// grid-cell quick-add (FR-3.15); [tugasOptions] backs the optional Tugas
/// link (FR-3.5) for a Timebox block.
Future<void> showAddActivitySheet(
  BuildContext context, {
  required ActivityHomeCubit cubit,
  TimeboxCubit? timeboxCubit,
  List<TugasRow> tugasOptions = const [],
  LocalDate? initialDate,
  TimeOfDay? initialStartTime,
  bool startAsTimebox = false,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: _AddActivitySheet(
              cubit: cubit,
              timeboxCubit: timeboxCubit,
              tugasOptions: tugasOptions,
              initialDate: initialDate,
              initialStartTime: initialStartTime,
              startAsTimebox: startAsTimebox,
            ))),
  );
}

class _AddActivitySheet extends StatefulWidget {
  const _AddActivitySheet({
    required this.cubit,
    required this.timeboxCubit,
    required this.tugasOptions,
    required this.initialDate,
    required this.initialStartTime,
    required this.startAsTimebox,
  });

  final ActivityHomeCubit cubit;
  final TimeboxCubit? timeboxCubit;
  final List<TugasRow> tugasOptions;
  final LocalDate? initialDate;
  final TimeOfDay? initialStartTime;
  final bool startAsTimebox;

  @override
  State<_AddActivitySheet> createState() => _AddActivitySheetState();
}

class _AddActivitySheetState extends State<_AddActivitySheet> {
  final _judulController = TextEditingController();
  String? _categoryId;
  late bool _isTimebox = widget.startAsTimebox;
  bool _isAllDay = false;
  late TimeOfDay? _startTime = widget.initialStartTime;
  TimeOfDay? _endTime;
  bool _isRecurring = false;
  final Set<int> _recurringDays = {};
  String? _linkedTugasId;
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
                // A Timebox block always has a concrete time range (schema
                // 10); Activity may be all-day/flexible.
                if (_isTimebox) _isAllDay = false;
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
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.activityRecurringSwitch),
              value: _isRecurring,
              onChanged: (v) => setState(() => _isRecurring = v),
            ),
            if (_isRecurring) ...[
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
            if (_isTimebox) ...[
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String?>(
                initialValue: _linkedTugasId,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.timeboxLinkTugas),
                items: [
                  DropdownMenuItem(value: null, child: Text(l10n.timeboxLinkNone)),
                  ...widget.tugasOptions.map((t) => DropdownMenuItem(
                      value: t.id, child: Text(t.judul, overflow: TextOverflow.ellipsis))),
                ],
                onChanged: (v) => setState(() => _linkedTugasId = v),
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
    final today = widget.initialDate ?? widget.cubit.state.date;

    if (_isTimebox) {
      await _submitTimebox(l10n, judul, today);
      return;
    }

    DateTime? startInstant;
    DateTime? endInstant;
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

  /// TimeboxSchedule stores `start_time`/`end_time` as **Local time**, not an
  /// Instant (schema 10) — unlike the Activity branch above, so this never
  /// touches the device's own timezone; the materializer resolves the actual
  /// Instant per occurrence using the user's configured timezone.
  Future<void> _submitTimebox(
      AppLocalizations l10n, String judul, LocalDate today) async {
    final timeboxCubit = widget.timeboxCubit;
    if (timeboxCubit == null) {
      setState(() => _error = l10n.timeboxUnavailable);
      return;
    }
    if (_startTime == null || _endTime == null) {
      setState(() => _error = l10n.timeboxNeedsTime);
      return;
    }
    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
    if (endMinutes <= startMinutes) {
      setState(() => _error = l10n.activityEndAfterStart);
      return;
    }

    if (_isRecurring) {
      if (_recurringDays.isEmpty) {
        setState(() => _error = l10n.activityRecurringDaysRequired);
        return;
      }
      await timeboxCubit.createRecurringBlock(
        judul: judul,
        activityCategoryId: _categoryId!,
        days: _recurringDays,
        startTime: _formatTod(_startTime!),
        endTime: _formatTod(_endTime!),
        tugasId: _linkedTugasId,
      );
    } else {
      await timeboxCubit.createAdHocBlock(
        judul: judul,
        activityCategoryId: _categoryId!,
        date: today,
        startTime: _formatTod(_startTime!),
        endTime: _formatTod(_endTime!),
        tugasId: _linkedTugasId,
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
