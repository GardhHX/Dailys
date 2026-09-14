import 'package:flutter/material.dart';
import '../../app/theme/design_form.dart';
import 'package:intl/intl.dart';

import '../../app/theme/tokens.dart';
import '../../core/db/database.dart';
import '../../core/db/tables/enums.dart';
import '../../l10n/app_localizations.dart';
import 'tugas_list_cubit.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../core/time/tz_resolver.dart';

/// Add/edit Tugas modal (design/screens/tugas.md: "Add/edit adalah modal:
/// judul, course, priority, deadline tanggal/jam, deskripsi, estimasi
/// opsional"). On create the default reminder set is applied (schema 5); this
/// form does not expose the typed reminder editor yet (design gap note), so
/// editing preserves the task's existing reminders.
Future<void> showAddEditTugasSheet(
  BuildContext context, {
  required TugasListCubit cubit,
  TugasRow? existing,
}) {
  return showDialog<void>(
      context: context,
      builder: (_) => Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 660),
              child: _AddEditTugasSheet(cubit: cubit, existing: existing))));
}

class _AddEditTugasSheet extends StatefulWidget {
  const _AddEditTugasSheet({required this.cubit, this.existing});
  final TugasListCubit cubit;
  final TugasRow? existing;

  @override
  State<_AddEditTugasSheet> createState() => _AddEditTugasSheetState();
}

class _AddEditTugasSheetState extends State<_AddEditTugasSheet> {
  late final TextEditingController _judul;
  late final TextEditingController _deskripsi;
  late final TextEditingController _estimasi;
  String? _courseId;
  late TugasPrioritas _prioritas;
  late DateTime _deadlineLocal; // local wall-clock the user edits
  String? _error;
  bool _saving = false;
  bool _loadingChecklist = false;
  bool _checklistEnabled = false;
  final _checklist = <(String?, TextEditingController)>[];

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _judul = TextEditingController(text: e?.judul ?? '');
    _deskripsi = TextEditingController(text: e?.deskripsi ?? '');
    _estimasi = TextEditingController(text: e?.estimasiMenit?.toString() ?? '');
    _courseId = e?.mataKuliahId;
    _prioritas = e?.prioritas ?? TugasPrioritas.medium;
    final now = tz.TZDateTime.now(widget.cubit.state.location);
    _deadlineLocal = e == null
        ? DateTime(now.year, now.month, now.day + 1, 23, 59)
        : tz.TZDateTime.from(e.deadline, widget.cubit.state.location);
    if (e != null) _loadChecklist();
  }

  Future<void> _loadChecklist() async {
    setState(() => _loadingChecklist = true);
    try {
      final rows = await widget.cubit.loadChecklist(widget.existing!.id);
      if (!mounted) return;
      setState(() {
        for (final item in _checklist) {
          item.$2.dispose();
        }
        _checklist.clear();
        _checklist.addAll(
            rows.map((r) => (r.id, TextEditingController(text: r.judul))));
        _checklistEnabled = rows.isNotEmpty;
        _loadingChecklist = false;
        _error = null;
      });
    } catch (_) {
      if (mounted) {
        setState(() =>
            _error = AppLocalizations.of(context)!.tugasChecklistReadFailed);
      }
    }
  }

  @override
  void dispose() {
    _judul.dispose();
    _deskripsi.dispose();
    _estimasi.dispose();
    for (final item in _checklist) {
      item.$2.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final courses = widget.cubit.state.courses;

    return DesignModal(
      title: _isEdit ? l10n.tugasEditTitle : l10n.tugasAddTitle,
      saveLabel: l10n.tugasSave,
      titleSize: 20,
      busy: _saving,
      onSave: _loadingChecklist ? null : _submit,
      children: [
        DesignField(
            label: l10n.tugasFieldJudul,
            child: TextField(
              style:
                  Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
              controller: _judul,
              onSubmitted: (_) => _submit(),
              autofocus: true,
              decoration: const InputDecoration(),
            )),
        const SizedBox(height: AppSpacing.md),
        DesignField(
            label: l10n.tugasFieldCourse,
            child: DropdownButtonFormField<String?>(
              style:
                  Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
              initialValue: _courseId,
              isExpanded: true,
              decoration: const InputDecoration(),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.tugasNoCourse)),
                for (final c in courses)
                  DropdownMenuItem(
                      value: c.id,
                      child: Text(c.nama, overflow: TextOverflow.ellipsis)),
              ],
              onChanged: (v) => setState(() => _courseId = v),
            )),
        const SizedBox(height: AppSpacing.md),
        DesignField(
            label: l10n.tugasFieldPriority,
            child: DropdownButtonFormField<TugasPrioritas>(
              style:
                  Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
              initialValue: _prioritas,
              decoration: const InputDecoration(),
              items: [
                for (final p in TugasPrioritas.values)
                  DropdownMenuItem(
                      value: p, child: Text(_priorityLabel(p, l10n))),
              ],
              onChanged: (v) => setState(() => _prioritas = v ?? _prioritas),
            )),
        const SizedBox(height: 12),
        Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(l10n.tugasFieldDeadlineDate),
              TextButton(
                  onPressed: _pickDate,
                  child: Text(DateFormat.yMMMEd(locale).format(_deadlineLocal)))
            ]),
        Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(l10n.tugasFieldDeadlineTime),
              TextButton(
                  onPressed: _pickTime,
                  child: Text(
                      TimeOfDay.fromDateTime(_deadlineLocal).format(context)))
            ]),
        const SizedBox(height: AppSpacing.sm),
        DesignField(
            label: l10n.tugasFieldDescription,
            child: TextField(
              style:
                  Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
              controller: _deskripsi,
              minLines: 1,
              maxLines: 4,
              decoration: const InputDecoration(),
            )),
        const SizedBox(height: AppSpacing.md),
        DesignField(
            label: l10n.tugasFieldEstimate,
            child: TextField(
              style:
                  Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
              controller: _estimasi,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(),
            )),
        const SizedBox(height: 16),
        if (_loadingChecklist && _error == null)
          Text(l10n.tugasChecklistLoading),
        if (!_loadingChecklist) ...[
          CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.tugasUseChecklist),
              value: _checklistEnabled,
              onChanged: _saving
                  ? null
                  : (v) => setState(() => _checklistEnabled = v!)),
          if (_checklistEnabled) ...[
            for (var i = 0; i < _checklist.length; i++)
              Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: DesignField(
                                label: l10n.tugasChecklistHint,
                                child: TextField(
                                    controller: _checklist[i].$2,
                                    style: const TextStyle(fontSize: 16)))),
                        IconButton(
                            tooltip: l10n.tugasChecklistRemove,
                            onPressed: _saving
                                ? null
                                : () => setState(() {
                                      final removed = _checklist.removeAt(i);
                                      WidgetsBinding.instance
                                          .addPostFrameCallback(
                                              (_) => removed.$2.dispose());
                                    }),
                            icon: const Icon(Icons.close)),
                      ])),
            Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                    onPressed: _saving
                        ? null
                        : () => setState(() =>
                            _checklist.add((null, TextEditingController()))),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.tugasChecklistAdd))),
          ],
        ],
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(_error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
          if (_loadingChecklist)
            TextButton(
                onPressed: _loadChecklist, child: Text(l10n.actionRetry)),
        ],
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadlineLocal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _deadlineLocal = DateTime(picked.year, picked.month,
          picked.day, _deadlineLocal.hour, _deadlineLocal.minute));
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_deadlineLocal),
    );
    if (picked != null) {
      setState(() => _deadlineLocal = DateTime(
          _deadlineLocal.year,
          _deadlineLocal.month,
          _deadlineLocal.day,
          picked.hour,
          picked.minute));
    }
  }

  Future<void> _submit() async {
    if (_saving || _loadingChecklist) return;
    final l10n = AppLocalizations.of(context)!;
    final judul = _judul.text.trim();
    if (judul.isEmpty) {
      setState(() => _error = l10n.tugasTitleRequired);
      return;
    }
    int? estimasi;
    final estText = _estimasi.text.trim();
    if (estText.isNotEmpty) {
      estimasi = int.tryParse(estText);
      if (estimasi == null || estimasi <= 0) {
        setState(() => _error = l10n.tugasEstimatePositive);
        return;
      }
    }
    final deskripsi =
        _deskripsi.text.trim().isEmpty ? null : _deskripsi.text.trim();
    final checklist = _checklistEnabled
        ? _checklist
            .map((item) =>
                ChecklistDraft(id: item.$1, title: item.$2.text.trim()))
            .toList()
        : <ChecklistDraft>[];
    if (checklist.any((item) => item.title.isEmpty)) {
      setState(() => _error = l10n.tugasChecklistTitleRequired);
      return;
    }
    final deadline = TzResolver.localToUtc(
        widget.cubit.state.location,
        _deadlineLocal.year,
        _deadlineLocal.month,
        _deadlineLocal.day,
        _deadlineLocal.hour,
        _deadlineLocal.minute);

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (_isEdit) {
        await widget.cubit.editTugas(
          id: widget.existing!.id,
          judul: judul,
          deadline: deadline,
          prioritas: _prioritas,
          deskripsi: deskripsi,
          mataKuliahId: _courseId,
          estimasiMenit: estimasi,
          checklist: checklist,
        );
      } else {
        await widget.cubit.createTugas(
          judul: judul,
          deadline: deadline,
          prioritas: _prioritas,
          deskripsi: deskripsi,
          mataKuliahId: _courseId,
          estimasiMenit: estimasi,
          checklist: checklist,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _error = l10n.tugasSaveFailed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _priorityLabel(TugasPrioritas p, AppLocalizations l10n) => switch (p) {
        TugasPrioritas.low => l10n.tugasPriorityLow,
        TugasPrioritas.medium => l10n.tugasPriorityMedium,
        TugasPrioritas.high => l10n.tugasPriorityHigh,
      };
}
