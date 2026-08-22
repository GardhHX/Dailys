import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/theme/app_colors.dart';
import '../application/tugas_providers.dart';
import 'widgets/tugas_format.dart';
import 'widgets/tugas_form_sheet.dart';

/// Tugas Detail — sub-checklist (FR-6.14), catatan (FR-6.15), status manual
/// (FR-6.13).
class TugasDetailScreen extends ConsumerStatefulWidget {
  const TugasDetailScreen({super.key, required this.tugasId});

  final String tugasId;

  @override
  ConsumerState<TugasDetailScreen> createState() => _TugasDetailScreenState();
}

class _TugasDetailScreenState extends ConsumerState<TugasDetailScreen> {
  final _newItemController = TextEditingController();

  @override
  void dispose() {
    _newItemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tugasAsync = ref.watch(tugasListProvider);
    final checklistAsync = ref.watch(checklistProvider(widget.tugasId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tugas detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              final tugas = tugasAsync.valueOrNull?.where((t) => t.id == widget.tugasId).firstOrNull;
              if (tugas != null) showTugasFormSheet(context, editing: tugas);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: tugasAsync.when(
        data: (list) {
          final tugas = list.where((t) => t.id == widget.tugasId).firstOrNull;
          if (tugas == null) return const Center(child: Text('Tugas not found (it may have been deleted).'));
          return _buildBody(context, tugas, checklistAsync);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
      ),
    );
  }

  Widget _buildBody(BuildContext context, TugasData tugas, AsyncValue<List<TugasChecklistData>> checklistAsync) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(tugas.judul, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          '${formatDate(tugas.deadline)} • ${countdownLabel(tugas.deadline)}',
          style: TextStyle(color: isOverdue(tugas.deadline, tugas.status) ? AppColors.danger : null),
        ),
        const SizedBox(height: 16),
        Text('Status', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        SegmentedButton<String>(
          segments: statusLabels.entries.map((e) => ButtonSegment(value: e.key, label: Text(e.value))).toList(),
          selected: {tugas.status},
          onSelectionChanged: (s) => ref.read(tugasRepositoryProvider).updateStatus(tugas.id, s.first),
        ),
        if (tugas.deskripsi != null && tugas.deskripsi!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Notes', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(tugas.deskripsi!),
        ],
        const SizedBox(height: 24),
        Text('Checklist', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        checklistAsync.when(
          data: (items) => Column(
            children: [
              for (final item in items)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    item.judul,
                    style: item.isDone ? const TextStyle(decoration: TextDecoration.lineThrough) : null,
                  ),
                  value: item.isDone,
                  onChanged: (v) => ref.read(tugasRepositoryProvider).toggleChecklistItem(item.id, v ?? false),
                  secondary: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => ref.read(tugasRepositoryProvider).deleteChecklistItem(item.id),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newItemController,
                      decoration: const InputDecoration(hintText: 'Add checklist item'),
                      onSubmitted: (_) => _addChecklistItem(items.length),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.add), onPressed: () => _addChecklistItem(items.length)),
                ],
              ),
            ],
          ),
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Failed to load checklist: $e'),
        ),
      ],
    );
  }

  void _addChecklistItem(int currentCount) {
    final text = _newItemController.text.trim();
    if (text.isEmpty) return;
    ref.read(tugasRepositoryProvider).addChecklistItem(widget.tugasId, text, currentCount);
    _newItemController.clear();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete tugas?'),
        content: const Text('This tugas will be removed from the list.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(tugasRepositoryProvider).deleteTugas(widget.tugasId);
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}
