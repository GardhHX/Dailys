import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/form_dialog.dart';
import '../../../task/application/tugas_providers.dart';
import '../../application/timebox_providers.dart';
import '../../data/timebox_repository.dart';

const _hariLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// Form tambah/edit Timebox block — FR-3.1, FR-3.2, FR-3.5. Tampil sebagai
/// [AppFormDialog] (modal terpusat) — DIREVISI 23 Agu 2026 dari bottom
/// sheet, konsisten dgn `ActivityFormSheet`/`TugasFormSheet`.
///
/// Catatan cakupan: keterkaitan ke Habit (FR-3.5) belum diekspos di form ini
/// karena fitur Habit (Phase 5) belum punya data layer — kolom `habit_id`
/// sudah ada di skema & repository, tinggal disambungkan begitu Habit DAO
/// dibuat. Keterkaitan ke Tugas sudah aktif.
class TimeboxFormSheet extends ConsumerStatefulWidget {
  const TimeboxFormSheet({super.key, this.editing, required this.weekStart, this.initialWeekday});

  final TimeboxScheduleData? editing;
  final DateTime weekStart;
  final int? initialWeekday;

  @override
  ConsumerState<TimeboxFormSheet> createState() => _TimeboxFormSheetState();
}

class _TimeboxFormSheetState extends ConsumerState<TimeboxFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judulController;

  String _kategori = AppColors.kategoriDefault.keys.first;
  bool _isRecurring = true;
  int _weekday = 1;
  DateTime? _tanggalSpesifik;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _tugasId;

  List<TimeboxScheduleData> _bentrokWarning = [];
  bool _saving = false;

  bool get _isEditing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _judulController = TextEditingController(text: e?.judul ?? '');

    if (e != null) {
      _kategori = e.kategori;
      _isRecurring = e.isRecurring;
      _weekday = e.hari != null ? weekdayFromHari(e.hari!) : (widget.initialWeekday ?? 1);
      _tanggalSpesifik = e.tanggalSpesifik;
      _startTime = _parseTime(e.startTime);
      _endTime = _parseTime(e.endTime);
      _tugasId = e.tugasId;
    } else {
      _weekday = widget.initialWeekday ?? 1;
      _tanggalSpesifik = widget.weekStart.add(Duration(days: _weekday - 1));
    }
  }

  TimeOfDay _parseTime(String hm) {
    final parts = hm.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _judulController.dispose();
    super.dispose();
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: (isStart ? _startTime : _endTime) ?? TimeOfDay.now(),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
    await _refreshBentrokWarning();
  }

  Future<void> _refreshBentrokWarning() async {
    if (_startTime == null || _endTime == null) {
      setState(() => _bentrokWarning = []);
      return;
    }
    final overlaps = await ref.read(timeboxRepositoryProvider).checkBentrok(
          weekStart: widget.weekStart,
          weekday: _weekday,
          startTime: _formatTime(_startTime!),
          endTime: _formatTime(_endTime!),
          excludeId: widget.editing?.id,
        );
    if (mounted) setState(() => _bentrokWarning = overlaps);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Set start & end time.')),
      );
      return;
    }
    final startStr = _formatTime(_startTime!);
    final endStr = _formatTime(_endTime!);
    if (_toMinutes(endStr) <= _toMinutes(startStr)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time.')),
      );
      return;
    }

    setState(() => _saving = true);
    final repo = ref.read(timeboxRepositoryProvider);
    final judul = _judulController.text.trim();

    try {
      if (_isEditing) {
        await repo.updateBlock(
          widget.editing!.id,
          judul: judul,
          kategori: _kategori,
          startTime: startStr,
          endTime: endStr,
          isRecurring: _isRecurring,
          hari: _isRecurring ? hariFromWeekday(_weekday) : null,
          tanggalSpesifik: _isRecurring ? null : _tanggalSpesifik,
          tugasId: _tugasId,
        );
      } else {
        await repo.createBlock(
          judul: judul,
          kategori: _kategori,
          startTime: startStr,
          endTime: endStr,
          isRecurring: _isRecurring,
          hari: _isRecurring ? hariFromWeekday(_weekday) : null,
          tanggalSpesifik: _isRecurring ? null : _tanggalSpesifik,
          tugasId: _tugasId,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  int _toMinutes(String hm) {
    final parts = hm.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  @override
  Widget build(BuildContext context) {
    final tugasAsync = ref.watch(tugasListProvider);

    return AppFormDialog(
      title: _isEditing ? 'Edit block' : 'Add block',
      saveLabel: 'Save block',
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
              decoration: const InputDecoration(hintText: 'e.g. Deep work block'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              autofocus: !_isEditing,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Category', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            _buildKategoriPicker(),
            const SizedBox(height: AppSpacing.md),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Weekly template')),
                ButtonSegment(value: false, label: Text('Ad-hoc (1 date)')),
              ],
              selected: {_isRecurring},
              onSelectionChanged: (s) => setState(() {
                _isRecurring = s.first;
                _bentrokWarning = [];
              }),
            ),
            const SizedBox(height: AppSpacing.md),
            _isRecurring ? _buildHariPicker() : _buildTanggalPicker(),
            const SizedBox(height: AppSpacing.md),
            _buildTimePickers(),
            if (_bentrokWarning.isNotEmpty) _buildBentrokWarning(),
            const SizedBox(height: AppSpacing.md),
            Text('Link to Tugas', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            tugasAsync.when(
              data: (list) => DropdownButtonFormField<String?>(
                initialValue: _tugasId,
                items: [
                  const DropdownMenuItem(value: null, child: Text('None')),
                  for (final t in list) DropdownMenuItem(value: t.id, child: Text(t.judul)),
                ],
                onChanged: (v) => setState(() => _tugasId = v),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Failed to load tugas: $e'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKategoriPicker() {
    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        for (final k in AppColors.kategoriDefault.keys)
          ChoiceChip(
            label: Text(k),
            selected: _kategori == k,
            onSelected: (_) => setState(() => _kategori = k),
          ),
      ],
    );
  }

  Widget _buildHariPicker() {
    return Wrap(
      spacing: AppSpacing.xs,
      children: [
        for (var i = 0; i < 7; i++)
          ChoiceChip(
            label: Text(_hariLabels[i]),
            selected: _weekday == i + 1,
            onSelected: (_) async {
              setState(() => _weekday = i + 1);
              await _refreshBentrokWarning();
            },
          ),
      ],
    );
  }

  Widget _buildTanggalPicker() {
    return OutlinedButton(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _tanggalSpesifik ?? widget.weekStart,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked == null) return;
        setState(() {
          _tanggalSpesifik = picked;
          _weekday = picked.weekday;
        });
        await _refreshBentrokWarning();
      },
      child: Text(_tanggalSpesifik == null
          ? 'Pick date'
          : _tanggalSpesifik!.toLocal().toString().split(' ').first),
    );
  }

  Widget _buildTimePickers() {
    return Row(
      children: [
        Expanded(
          child: TimeFieldBox(
            label: 'Start',
            value: _startTime == null ? '--:--' : _startTime!.format(context),
            onTap: () => _pickTime(isStart: true),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: TimeFieldBox(
            label: 'End',
            value: _endTime == null ? '--:--' : _endTime!.format(context),
            onTap: () => _pickTime(isStart: false),
          ),
        ),
      ],
    );
  }

  Widget _buildBentrokWarning() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Text(
          'Conflicts with: ${_bentrokWarning.map((b) => b.judul).join(', ')}',
          style: TextStyle(color: AppColors.warning.withValues(alpha: 1)),
        ),
      ),
    );
  }
}

Future<void> showTimeboxFormSheet(
  BuildContext context, {
  TimeboxScheduleData? editing,
  required DateTime weekStart,
  int? initialWeekday,
}) {
  return showDialog(
    context: context,
    builder: (_) => TimeboxFormSheet(editing: editing, weekStart: weekStart, initialWeekday: initialWeekday),
  );
}
