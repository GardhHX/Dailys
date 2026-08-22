import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/form_dialog.dart';
import '../../application/tugas_providers.dart';
import 'tugas_format.dart';

const _prioritasLabels = {'low': 'Low', 'medium': 'Medium', 'high': 'High'};

/// Form tambah/edit tugas — FR-6.1, FR-6.2, FR-6.4. Tampil sebagai
/// [AppFormDialog] (modal terpusat) — DIREVISI 23 Agu 2026 dari bottom
/// sheet, konsisten dengan `ActivityFormSheet` (lihat `form_dialog.dart`).
/// Field Deadline & Priority 1:1 dgn screenshot "Add tugas" yang dikirim
/// user (2 kolom: "Deadline (days from today)" berupa angka + dropdown
/// Priority) — **deviasi dari implementasi lama** yang pakai date+time
/// picker penuh. Konsekuensinya: jam deadline jadi implisit 23:59, tidak
/// bisa dipilih user lagi persis jam berapa. Kalau ini dirasa kurang
/// (misal butuh deadline jam 14:00), perlu didiskusikan lagi — bukan
/// penyimpangan diam-diam, sengaja dicatat di sini.
///
/// **23 Agu 2026 — field "Estimated time (minutes)" (bagian dari FR-6.1)
/// dihapus dari UI** atas permintaan eksplisit user, mengikuti screenshot
/// "Add tugas" yang tidak menunjukkan field tsb. Kolom `estimasi_menit` di
/// `schema.md` & `TugasRepository` TIDAK dihapus (tetap nullable, tetap
/// dipakai `weeklyWorkload()` yang UI-nya sendiri sudah dilepas di Phase 2)
/// — cuma tidak ada lagi cara mengisinya lewat form ini untuk tugas baru.
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
  late final TextEditingController _reminderController;
  late final TextEditingController _deadlineDaysController;

  String? _mataKuliahId;
  String _prioritas = 'medium';
  bool _saving = false;

  bool get _isEditing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _judulController = TextEditingController(text: e?.judul ?? '');
    _deskripsiController = TextEditingController(text: e?.deskripsi ?? '');
    // Kosong by default untuk tugas baru — placeholder "7,3,1,0" di field
    // menunjukkan nilai default yang dipakai kalau dikosongkan (lihat
    // `_save`), bukan lagi nilai ter-prefill yang harus dihapus manual.
    _reminderController = TextEditingController(
      text: e == null ? '' : decodeReminderOffsets(e.reminderOffsets).join(','),
    );
    final daysFromNow = e == null ? 3 : e.deadline.difference(DateTime.now()).inDays;
    _deadlineDaysController = TextEditingController(text: daysFromNow.clamp(0, 999).toString());
    _mataKuliahId = e?.mataKuliahId;
    _prioritas = e?.prioritas ?? 'medium';
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _reminderController.dispose();
    _deadlineDaysController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final days = int.tryParse(_deadlineDaysController.text.trim());
    if (days == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid number of days.')),
      );
      return;
    }
    final now = DateTime.now();
    final deadline = DateTime(now.year, now.month, now.day, 23, 59).add(Duration(days: days));

    setState(() => _saving = true);
    final repo = ref.read(tugasRepositoryProvider);
    final deskripsi = _deskripsiController.text.trim();
    final reminderOffsets = _reminderController.text
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .toList();
    // Kosong → null, supaya DB pakai default kolom `[7,3,1,0]` (create)
    // atau biarkan nilai lama tidak berubah (update, lewat sentinel
    // `Value.absent()` di repository) — bukan menyimpan array kosong.
    final resolvedReminderOffsets = reminderOffsets.isEmpty ? null : reminderOffsets;

    try {
      if (_isEditing) {
        await repo.updateTugas(
          widget.editing!.id,
          judul: _judulController.text.trim(),
          mataKuliahId: _mataKuliahId,
          deskripsi: deskripsi,
          deadline: deadline,
          prioritas: _prioritas,
          reminderOffsets: resolvedReminderOffsets,
        );
      } else {
        await repo.createTugas(
          judul: _judulController.text.trim(),
          mataKuliahId: _mataKuliahId,
          deskripsi: deskripsi.isEmpty ? null : deskripsi,
          deadline: deadline,
          prioritas: _prioritas,
          reminderOffsets: resolvedReminderOffsets,
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

    return AppFormDialog(
      title: _isEditing ? 'Edit tugas' : 'Add tugas',
      saveLabel: 'Save tugas',
      saving: _saving,
      onCancel: () => Navigator.of(context).pop(),
      onSave: _save,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            TextFormField(
              controller: _judulController,
              decoration: const InputDecoration(hintText: 'e.g. Reading response'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              autofocus: !_isEditing,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Mata Kuliah', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            mataKuliahAsync.when(
              data: (list) => DropdownButtonFormField<String?>(
                initialValue: _mataKuliahId,
                items: [
                  const DropdownMenuItem(value: null, child: Text('None')),
                  for (final mk in list) DropdownMenuItem(value: mk.id, child: Text(mk.nama)),
                ],
                onChanged: (v) => setState(() => _mataKuliahId = v),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Failed to load mata kuliah: $e'),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Deadline (days from today)', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _deadlineDaysController,
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || int.tryParse(v.trim()) == null) ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Priority', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        initialValue: _prioritas,
                        items: [
                          for (final p in _prioritasLabels.entries)
                            DropdownMenuItem(value: p.key, child: Text(p.value)),
                        ],
                        onChanged: (v) => setState(() => _prioritas = v ?? 'medium'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Description', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            TextFormField(
              controller: _deskripsiController,
              decoration: const InputDecoration(hintText: 'Optional'),
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Reminders (days before, comma-separated)', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            TextFormField(
              controller: _reminderController,
              decoration: const InputDecoration(hintText: '7,3,1,0'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showTugasFormSheet(BuildContext context, {TugasData? editing}) {
  return showDialog(
    context: context,
    builder: (_) => TugasFormSheet(editing: editing),
  );
}
