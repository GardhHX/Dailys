import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/form_dialog.dart';
import '../../application/activity_providers.dart';

const _weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _customKategoriValue = '__custom__';

/// Form tambah/edit activity — FR-1.1, FR-1.2, FR-1.3, FR-1.4, FR-1.12.
/// Dipanggil lewat [showActivityFormSheet]. Tampil sebagai [AppFormDialog]
/// (modal terpusat) — DIREVISI 23 Agu 2026 dari bottom sheet, lihat catatan
/// di `form_dialog.dart`. Field & copy 1:1 dgn screenshot "Add activity"
/// yang dikirim user: dropdown kategori (bukan chip), toggle bergaya radio
/// utk all-day/recurring (bukan Switch), field waktu kotak+ikon jam.
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
        const SnackBar(content: Text('Set start & end time, or mark as all-day.')),
      );
      return;
    }
    if (!_isAllDay) {
      final start = _combineDate(_startTime)!;
      final end = _combineDate(_endTime)!;
      if (!end.isAfter(start)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End time must be after start time.')),
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
    return AppFormDialog(
      title: _isEditing ? 'Edit activity' : 'Add activity',
      saveLabel: 'Save activity',
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
              decoration: const InputDecoration(hintText: 'e.g. Read chapter 4'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              autofocus: !_isEditing,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Category', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            _buildKategoriDropdown(),
            const SizedBox(height: AppSpacing.sm),
            RadioToggleRow(
              label: 'All day / no specific time',
              value: _isAllDay,
              onChanged: (v) => setState(() {
                _isAllDay = v;
                _overlapWarning = [];
              }),
            ),
            if (!_isAllDay) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildTimePickers(),
            ],
            if (_overlapWarning.isNotEmpty) _buildOverlapWarning(),
            RadioToggleRow(
              label: 'Recurring',
              value: _isRecurring,
              onChanged: (v) => setState(() => _isRecurring = v),
            ),
            if (_isRecurring) _buildRecurringPicker(),
            const SizedBox(height: AppSpacing.md),
            Text('Notes', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            TextFormField(
              controller: _catatanController,
              decoration: const InputDecoration(hintText: 'Optional'),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKategoriDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _isCustomKategori ? _customKategoriValue : _kategori,
          items: [
            for (final k in AppColors.kategoriDefault.keys) DropdownMenuItem(value: k, child: Text(k)),
            const DropdownMenuItem(value: _customKategoriValue, child: Text('Custom')),
          ],
          onChanged: (v) => setState(() {
            _isCustomKategori = v == _customKategoriValue;
            _kategori = _isCustomKategori ? null : v;
          }),
        ),
        if (_isCustomKategori)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: TextFormField(
              controller: _customKategoriController,
              decoration: const InputDecoration(hintText: 'Custom category name'),
              validator: (v) =>
                  _isCustomKategori && (v == null || v.trim().isEmpty) ? 'Category name is required' : null,
            ),
          ),
      ],
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

  Widget _buildOverlapWarning() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Text(
          'Conflicts with: ${_overlapWarning.map((a) => a.judul).join(', ')}',
          style: TextStyle(color: AppColors.warning.withValues(alpha: 1)),
        ),
      ),
    );
  }

  Widget _buildRecurringPicker() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Column(
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
                ? 'End date (optional)'
                : 'Ends: ${_recurringEndDate!.toLocal().toString().split(' ').first}'),
          ),
        ],
      ),
    );
  }
}

Future<void> showActivityFormSheet(
  BuildContext context, {
  ActivityData? editing,
  required DateTime initialDate,
}) {
  return showDialog(
    context: context,
    builder: (_) => ActivityFormSheet(editing: editing, initialDate: initialDate),
  );
}
