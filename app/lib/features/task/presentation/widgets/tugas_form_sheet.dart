import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../application/tugas_providers.dart';
import 'tugas_format.dart';

/// Modal bottom sheet tambah/edit tugas — FR-6.1, FR-6.2, FR-6.4.
class TugasFormSheet extends ConsumerStatefulWidget {
  const TugasFormSheet({super.key, this.editing});

  final TugasData? editing;

  @override
  ConsumerState<TugasFormSheet> createState() => _TugasFormSheetState();
}

class _TugasFormSheetState extends ConsumerState<TugasFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judulController;
  late final TextEditingController _deskripsiController;
  late final TextEditingController _estimasiController;
  late final TextEditingController _reminderController;

  String? _mataKuliahId;
  DateTime? _deadline;
  String _prioritas = 'medium';
  bool _saving = false;

  bool get _isEditing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _judulController = TextEditingController(text: e?.judul ?? '');
    _deskripsiController = TextEditingController(text: e?.deskripsi ?? '');
    _estimasiController = TextEditingController(text: e?.estimasiMenit?.toString() ?? '');
    _reminderController = TextEditingController(
      text: e == null ? '7,3,1,0' : decodeReminderOffsets(e.reminderOffsets).join(','),
    );
    _mataKuliahId = e?.mataKuliahId;
    _deadline = e?.deadline;
    _prioritas = e?.prioritas ?? 'medium';
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _estimasiController.dispose();
    _reminderController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: _deadline == null ? const TimeOfDay(hour: 23, minute: 59) : TimeOfDay.fromDateTime(_deadline!),
    );
    if (time == null) return;
    setState(() => _deadline = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih deadline dulu.')));
      return;
    }

    setState(() => _saving = true);
    final repo = ref.read(tugasRepositoryProvider);
    final deskripsi = _deskripsiController.text.trim();
    final estimasi = int.tryParse(_estimasiController.text.trim());
    final reminderOffsets = _reminderController.text
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .toList();

    try {
      if (_isEditing) {
        await repo.updateTugas(
          widget.editing!.id,
          judul: _judulController.text.trim(),
          mataKuliahId: _mataKuliahId,
          deskripsi: deskripsi,
          deadline: _deadline,
          prioritas: _prioritas,
          estimasiMenit: estimasi,
          reminderOffsets: reminderOffsets,
        );
      } else {
        await repo.createTugas(
          judul: _judulController.text.trim(),
          mataKuliahId: _mataKuliahId,
          deskripsi: deskripsi.isEmpty ? null : deskripsi,
          deadline: _deadline!,
          prioritas: _prioritas,
          estimasiMenit: estimasi,
          reminderOffsets: reminderOffsets.isEmpty ? null : reminderOffsets,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mataKuliahAsync = ref.watch(mataKuliahListProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_isEditing ? 'Edit Tugas' : 'Tambah Tugas', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
                autofocus: !_isEditing,
              ),
              const SizedBox(height: AppSpacing.md),
              mataKuliahAsync.when(
                data: (list) => DropdownButtonFormField<String?>(
                  initialValue: _mataKuliahId,
                  decoration: const InputDecoration(labelText: 'Mata Kuliah (opsional)'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tidak ada')),
                    for (final mk in list) DropdownMenuItem(value: mk.id, child: Text(mk.nama)),
                  ],
                  onChanged: (v) => setState(() => _mataKuliahId = v),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Gagal memuat mata kuliah: $e'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(labelText: 'Deskripsi (opsional)'),
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(
                onPressed: _pickDeadline,
                child: Text(_deadline == null ? 'Pilih deadline' : formatDate(_deadline!)),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Prioritas', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'low', label: Text('Low')),
                  ButtonSegment(value: 'medium', label: Text('Medium')),
                  ButtonSegment(value: 'high', label: Text('High')),
                ],
                selected: {_prioritas},
                onSelectionChanged: (s) => setState(() => _prioritas = s.first),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _estimasiController,
                decoration: const InputDecoration(labelText: 'Estimasi pengerjaan (menit, opsional)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _reminderController,
                decoration: const InputDecoration(
                  labelText: 'Reminder (H- berapa saja, pisahkan koma)',
                  hintText: '7,3,1,0',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Simpan'),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showTugasFormSheet(BuildContext context, {TugasData? editing}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => TugasFormSheet(editing: editing),
  );
}
