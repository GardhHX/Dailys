import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../app/theme/tokens.dart';
import '../../core/db/database.dart';
import '../../core/db/tables/enums.dart';
import '../../l10n/app_localizations.dart';
import 'add_edit_tugas_sheet.dart';
import 'tugas_detail_cubit.dart';
import 'tugas_list_cubit.dart';
import 'tugas_labels.dart';

/// Tugas detail route (design/screens/tugas.md: "Detail sebagai route dengan
/// tombol kembali"): title/deadline, description, checklist, status/priority/
/// estimate/course, and edit/archive/delete actions.
///
/// Opened both from the Tugas tab and from Home's Next Deadline panel
/// (design/screens/home.md: "Panel deadline membuka detail contoh"), so it
/// owns a private [TugasListCubit] for the edit sheet's course list rather
/// than depending on the Tugas tab's instance.
class TugasDetailScreen extends StatefulWidget {
  const TugasDetailScreen({
    super.key,
    required this.db,
    required this.userId,
    required this.location,
    required this.tugasId,
  });

  final AppDatabase db;
  final String userId;
  final tz.Location location;
  final String tugasId;

  @override
  State<TugasDetailScreen> createState() => _TugasDetailScreenState();
}

class _TugasDetailScreenState extends State<TugasDetailScreen> {
  late final TugasDetailCubit _cubit =
      TugasDetailCubit(db: widget.db, tugasId: widget.tugasId);
  late final TugasListCubit _editCubit = TugasListCubit(
    db: widget.db,
    userId: widget.userId,
    location: widget.location,
  );

  @override
  void dispose() {
    _cubit.close();
    _editCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    return BlocBuilder<TugasDetailCubit, TugasDetailState>(
      bloc: _cubit,
      builder: (context, state) {
        final t = state.tugas;
        if (state.loading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (t == null) {
          // Deleted while open; leave the route.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.of(context).maybePop();
          });
          return const Scaffold(body: SizedBox.shrink());
        }
        final archived = t.archivedAt != null;
        return Scaffold(
          appBar: AppBar(
            title: Text(t.judul, overflow: TextOverflow.ellipsis),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () =>
                    showAddEditTugasSheet(context, cubit: _editCubit, existing: t),
              ),
              IconButton(
                icon: Icon(archived ? Icons.unarchive_outlined : Icons.archive_outlined),
                tooltip: archived ? l10n.tugasUnarchive : l10n.tugasArchive,
                onPressed: () => _cubit.setArchived(!archived),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.tugasDelete,
                onPressed: () => _confirmDelete(context, l10n),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(
                '${l10n.tugasDeadlineLabel}: '
                '${DateFormat.yMMMEd(locale).add_jm().format(t.deadline.toLocal())}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  Chip(label: Text(tugasStatusLabel(t.status, l10n))),
                  Chip(label: Text(tugasPriorityLabel(t.prioritas, l10n))),
                  if (t.estimasiMenit != null)
                    Chip(label: Text(l10n.tugasEstimate(t.estimasiMenit!))),
                  Chip(label: Text(state.course?.nama ?? l10n.tugasNoCourse)),
                  if (archived) Chip(label: Text(l10n.tugasArchivedBadge)),
                ],
              ),
              if (t.deskripsi != null && t.deskripsi!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(t.deskripsi!),
              ],
              const SizedBox(height: AppSpacing.lg),
              _StatusActions(cubit: _cubit, status: t.status, l10n: l10n),
              const Divider(height: AppSpacing.xxl),
              _ChecklistSection(cubit: _cubit, state: state, l10n: l10n),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, AppLocalizations l10n) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.tugasDeleteConfirmTitle),
        content: Text(l10n.tugasDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.tugasDelete),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _cubit.deleteTugas();
      if (context.mounted) Navigator.of(context).maybePop();
    }
  }
}

class _StatusActions extends StatelessWidget {
  const _StatusActions({required this.cubit, required this.status, required this.l10n});
  final TugasDetailCubit cubit;
  final TugasStatus status;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        if (status != TugasStatus.progress)
          OutlinedButton(
            onPressed: () => cubit.setStatus(TugasStatus.progress),
            child: Text(l10n.tugasMarkProgress),
          ),
        if (status != TugasStatus.selesai)
          FilledButton(
            onPressed: () => cubit.setStatus(TugasStatus.selesai),
            child: Text(l10n.tugasMarkDone),
          ),
        if (status == TugasStatus.selesai)
          OutlinedButton(
            onPressed: () => cubit.setStatus(TugasStatus.belum),
            child: Text(l10n.tugasReopen),
          ),
      ],
    );
  }
}

class _ChecklistSection extends StatefulWidget {
  const _ChecklistSection({required this.cubit, required this.state, required this.l10n});
  final TugasDetailCubit cubit;
  final TugasDetailState state;
  final AppLocalizations l10n;

  @override
  State<_ChecklistSection> createState() => _ChecklistSectionState();
}

class _ChecklistSectionState extends State<_ChecklistSection> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final state = widget.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.tugasChecklistTitle, style: Theme.of(context).textTheme.titleMedium),
        // All-done prompt offers a status change; never auto-changes (schema/
        // design: "Semua checklist selesai menawarkan perubahan status").
        if (state.allChecklistDone && state.tugas?.status != TugasStatus.selesai)
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(child: Text(l10n.tugasChecklistAllDone)),
                  TextButton(
                    onPressed: () => widget.cubit.setStatus(TugasStatus.selesai),
                    child: Text(l10n.tugasChecklistMarkComplete),
                  ),
                ],
              ),
            ),
          ),
        for (final item in state.checklist)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: item.isDone,
            onChanged: (v) => widget.cubit.setChecklistDone(item.id, v ?? false),
            title: Text(item.judul),
            secondary: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => widget.cubit.deleteChecklistItem(item.id),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(hintText: l10n.tugasChecklistHint),
                onSubmitted: (_) => _add(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: l10n.tugasChecklistAdd,
              onPressed: _add,
            ),
          ],
        ),
      ],
    );
  }

  void _add() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.cubit.addChecklistItem(text);
    _controller.clear();
  }
}
