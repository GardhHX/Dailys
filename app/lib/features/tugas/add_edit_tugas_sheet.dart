import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme/tokens.dart';
import '../../core/db/database.dart';
import '../../core/db/tables/enums.dart';
import '../../l10n/app_localizations.dart';
import 'tugas_list_cubit.dart';

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
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _AddEditTugasSheet(cubit: cubit, existing: existing),
  );
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
    final now = DateTime.now();
    _deadlineLocal =
        e?.deadline.toLocal() ?? DateTime(now.year, now.month, now.day + 1, 23, 59);
  }

  @override
  void dispose() {
    _judul.dispose();
    _deskripsi.dispose();
    _estimasi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final courses = widget.cubit.state.courses;

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
            Text(
              _isEdit ? l10n.tugasEditTitle : l10n.tugasAddTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _judul,
              decoration: InputDecoration(labelText: l10n.tugasFieldJudul),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String?>(
              initialValue: _courseId,
              decoration: InputDecoration(labelText: l10n.tugasFieldCourse),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.tugasNoCourse)),
                for (final c in courses)
                  DropdownMenuItem(value: c.id, child: Text(c.nama)),
              ],
              onChanged: (v) => setState(() => _courseId = v),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<TugasPrioritas>(
              initialValue: _prioritas,
              decoration: InputDecoration(labelText: l10n.tugasFieldPriority),
              items: [
                for (final p in TugasPrioritas.values)
                  DropdownMenuItem(value: p, child: Text(_priorityLabel(p, l10n))),
              ],
              onChanged: (v) => setState(() => _prioritas = v ?? _prioritas),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.tugasFieldDeadlineDate),
              trailing: Text(DateFormat.yMMMEd(locale).format(_deadlineLocal)),
              onTap: _pickDate,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.tugasFieldDeadlineTime),
              trailing: Text(TimeOfDay.fromDateTime(_deadlineLocal).format(context)),
              onTap: _pickTime,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _deskripsi,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(labelText: l10n.tugasFieldDescription),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _estimasi,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.tugasFieldEstimate),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(onPressed: _submit, child: Text(l10n.tugasSave)),
          ],
        ),
      ),
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
      setState(() => _deadlineLocal = DateTime(_deadlineLocal.year,
          _deadlineLocal.month, _deadlineLocal.day, picked.hour, picked.minute));
    }
  }

  Future<void> _submit() async {
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
    final deskripsi = _deskripsi.text.trim().isEmpty ? null : _deskripsi.text.trim();
    final deadline = _deadlineLocal.toUtc();

    if (_isEdit) {
      await widget.cubit.editTugas(
        id: widget.existing!.id,
        judul: judul,
        deadline: deadline,
        prioritas: _prioritas,
        deskripsi: deskripsi,
        mataKuliahId: _courseId,
        estimasiMenit: estimasi,
      );
    } else {
      await widget.cubit.createTugas(
        judul: judul,
        deadline: deadline,
        prioritas: _prioritas,
        deskripsi: deskripsi,
        mataKuliahId: _courseId,
        estimasiMenit: estimasi,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  String _priorityLabel(TugasPrioritas p, AppLocalizations l10n) => switch (p) {
        TugasPrioritas.low => l10n.tugasPriorityLow,
        TugasPrioritas.medium => l10n.tugasPriorityMedium,
        TugasPrioritas.high => l10n.tugasPriorityHigh,
      };
}
