import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../application/activity_providers.dart';

const _weekdayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

/// Modal bottom sheet tambah/edit activity — FR-1.1, FR-1.2, FR-1.3, FR-1.4,
/// FR-1.12. Dipanggil lewat [showActivityFormSheet].
class ActivityFormSheet extends ConsumerStatefulWidget {
  const ActivityFormSheet({super.key, this.editing, required this.initialDate});

  final ActivityData? editing;
  final DateTime initialDate;

  @override
  ConsumerState<ActivityFormSheet> createState() => _ActivityFormSheetState();
}

class _ActivityFormSheetState extends ConsumerState<ActivityFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judulController;
  late final TextEditingController _catatanController;
  late final TextEditingController _customKategoriController;

  String? _kategori;
  bool _isCustomKategori = false;
  bool _isAllDay = false;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isRecurring = false;
  final Set<int> _recurringDays = {};
  DateTime? _recurringEndDate;

  List<ActivityData> _overlapWarning = [];
  bool _saving = false;

  bool get _isEditing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _judulController = TextEditingController(text: e?.judul ?? '');
    _catatanController = TextEditingController(text: e?.catatan ?? '');
    _customKategoriController = TextEditingController();

    if (e != null) {
      _isCustomKategori = !AppColors.kategoriDefault.containsKey(e.kategori);
      _kategori = _isCustomKategori ? null : e.kategori;
      if (_isCustomKategori) _customKategoriController.text = e.kategori;
      _isAllDay = e.isAllDay;
      _startTime = e.startTime == null ? null : TimeOfDay.fromDateTime(e.startTime!);
      _endTime = e.endTime == null ? null : TimeOfDay.fromDateTime(e.endTime!);
      _isRecurring = e.isRecurring;
      _recurringEndDate = e.recurringEndDate;
      if (e.recurringDays != null) {
        final days = e.recurringDays!.replaceAll(RegExp(r'[\[\]\s]'), '').split(',').where((s) => s.isNotEmpty);
        _recurringDays.addAll(days.map(int.parse));
      }
    } else {
      _kategori = AppColors.kategoriDefault.keys.first;
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _catatanController.dispose();
    _customKategoriController.dispose();
    super.dispose();
  }

  String get _effectiveKategori =>
      _isCustomKategori ? _customKategoriController.text.trim() : (_kategori ?? '');

  DateTime? _combineDate(TimeOfDay? time) {
    if (time == null) return null;
    final d = widget.initialDate;
    return DateTime(d.year, d.month, d.day, time.hour, time.minute);
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
    await _refreshOverlapWarning();
  }

  Future<void> _refreshOverlapWarning() async {
    if (_isAllDay || _startTime == null || _endTime == null) {
      setState(() => _overlapWarning = []);
      return;
    }
    final start = _combineDate(_startTime)!;
    final end = _combineDate(_endTime)!;
    if (!end.isAfter(start)) return;
    final overlaps = await ref.read(activityRepositoryProvider).checkOverlap(
          date: widget.initialDate,
          start: start,
          end: end,
          excludeId: widget.editing?.id,
        );
    if (mounted) setState(() => _overlapWarning = overlaps);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isAllDay && (_startTime == null || _endTime == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi jam mulai & selesai, atau tandai all-day.')),
      );
      return;
    }
    if (!_isAllDay) {
      final start = _combineDate(_startTime)!;
      final end = _combineDate(_endTime)!;
      if (!end.isAfter(start)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jam selesai harus setelah jam mulai.')),
        );
        return;
      }
    }

    setState(() => _saving = true);
    final repo = ref.read(activityRepositoryProvider);
    final kategori = _effectiveKategori;
    // All-day activity tetap butuh `start_time` (jam 00:00) supaya query
    // "activity pada tanggal X" bisa menemukannya — bukan null (lihat
    // ActivityDao.watchByDate).
    final d = widget.initialDate;
    final start = _isAllDay ? DateTime(d.year, d.month, d.day) : _combineDate(_startTime);
    final end = _isAllDay ? null : _combineDate(_endTime);
    final catatan = _catatanController.text.trim();

    try {
      if (_isEditing) {
        await repo.updateActivity(
          widget.editing!.id,
          judul: _judulController.text.trim(),
          kategori: kategori,
          startTime: start,
          endTime: end,
          isAllDay: _isAllDay,
          isRecurring: _isRecurring,
          recurringDays: _isRecurring ? (_recurringDays.toList()..sort()) : null,
          recurringEndDate: _recurringEndDate,
          catatan: catatan.isEmpty ? null : catatan,
        );
      } else {
        await repo.createActivity(
          judul: _judulController.text.trim(),
          kategori: kategori,
          startTime: start,
          endTime: end,
          isAllDay: _isAllDay,
          isRecurring: _isRecurring,
          recurringDays: _isRecurring ? (_recurringDays.toList()..sort()) : null,
          recurringEndDate: _recurringEndDate,
          catatan: catatan.isEmpty ? null : catatan,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              Text(_isEditing ? 'Edit Activity' : 'Tambah Activity', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
                autofocus: !_isEditing,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildKategoriPicker(),
              const SizedBox(height: AppSpacing.md),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Sepanjang hari (all-day)'),
                value: _isAllDay,
                onChanged: (v) => setState(() {
                  _isAllDay = v;
                  _overlapWarning = [];
                }),
              ),
              if (!_isAllDay) _buildTimePickers(),
              if (_overlapWarning.isNotEmpty) _buildOverlapWarning(),
              const SizedBox(height: AppSpacing.sm),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Ulangi (recurring)'),
                value: _isRecurring,
                onChanged: (v) => setState(() => _isRecurring = v),
              ),
              if (_isRecurring) _buildRecurringPicker(),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _catatanController,
                decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
                maxLines: 2,
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

  Widget _buildKategoriPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            for (final k in AppColors.kategoriDefault.keys)
              ChoiceChip(
                label: Text(k),
                selected: !_isCustomKategori && _kategori == k,
                onSelected: (_) => setState(() {
                  _isCustomKategori = false;
                  _kategori = k;
                }),
              ),
            ChoiceChip(
              label: const Text('Custom'),
              selected: _isCustomKategori,
              onSelected: (_) => setState(() => _isCustomKategori = true),
            ),
          ],
        ),
        if (_isCustomKategori)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: TextFormField(
              controller: _customKategoriController,
              decoration: const InputDecoration(labelText: 'Nama kategori custom'),
              validator: (v) =>
                  _isCustomKategori && (v == null || v.trim().isEmpty) ? 'Kategori wajib diisi' : null,
            ),
          ),
      ],
    );
  }

  Widget _buildTimePickers() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _pickTime(isStart: true),
            child: Text(_startTime == null ? 'Jam mulai' : _startTime!.format(context)),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _pickTime(isStart: false),
            child: Text(_endTime == null ? 'Jam selesai' : _endTime!.format(context)),
          ),
        ),
      ],
    );
  }

  Widget _buildOverlapWarning() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Text(
          'Bentrok dengan: ${_overlapWarning.map((a) => a.judul).join(', ')}',
          style: TextStyle(color: AppColors.warning.withValues(alpha: 1)),
        ),
      ),
    );
  }

  Widget _buildRecurringPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.xs,
          children: [
            for (var i = 0; i < 7; i++)
              FilterChip(
                label: Text(_weekdayLabels[i]),
                selected: _recurringDays.contains(i + 1),
                onSelected: (sel) => setState(() {
                  if (sel) {
                    _recurringDays.add(i + 1);
                  } else {
                    _recurringDays.remove(i + 1);
                  }
                }),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _recurringEndDate ?? widget.initialDate.add(const Duration(days: 30)),
              firstDate: widget.initialDate,
              lastDate: DateTime(2100),
            );
            if (picked != null) setState(() => _recurringEndDate = picked);
          },
          child: Text(_recurringEndDate == null
              ? 'Tanggal berakhir (opsional)'
              : 'Berakhir: ${_recurringEndDate!.toLocal().toString().split(' ').first}'),
        ),
      ],
    );
  }
}

Future<void> showActivityFormSheet(
  BuildContext context, {
  ActivityData? editing,
  required DateTime initialDate,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => ActivityFormSheet(editing: editing, initialDate: initialDate),
  );
}
