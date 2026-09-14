import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../app/theme/tokens.dart';
import '../../core/db/database.dart';
import '../../core/db/tables/enums.dart';
import '../../l10n/app_localizations.dart';
import 'add_edit_tugas_sheet.dart';
import '../shell/tugas_shell.dart';
import 'package:timezone/timezone.dart' as tz;
import 'tugas_detail_cubit.dart';
import 'tugas_list_cubit.dart';
import 'tugas_labels.dart';
import 'domain/task_reminder.dart';

/// Tugas detail route (design/screens/tugas.md: "Detail sebagai route dengan
/// tombol kembali"): title/deadline, description, checklist, status/priority/
/// estimate/course, and edit/archive/delete actions.
class TugasDetailScreen extends StatefulWidget {
  const TugasDetailScreen({
    super.key,
    required this.db,
    required this.tugasId,
    required this.listCubit,
    required this.deviceId,
  });

  final AppDatabase db;
  final String tugasId;
  final TugasListCubit listCubit;
  final String deviceId;

  @override
  State<TugasDetailScreen> createState() => _TugasDetailScreenState();
}

class _TugasDetailScreenState extends State<TugasDetailScreen> {
  late final TugasDetailCubit _cubit =
      TugasDetailCubit(db: widget.db, tugasId: widget.tugasId);

  @override
  void dispose() {
    _cubit.close();
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
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (t == null) {
          // Deleted while open; leave the route.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.of(context).maybePop();
          });
          return const Scaffold(body: SizedBox.shrink());
        }
        final archived = t.archivedAt != null;
        final colors = Theme.of(context).colorScheme;
        final content =
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (t.deskripsi != null && t.deskripsi!.isNotEmpty) ...[
            Text(t.deskripsi!),
            const SizedBox(height: 24)
          ],
          _ChecklistSection(cubit: _cubit, state: state, l10n: l10n),
        ]);
        final metadata = Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: colors.surface,
                border: Border.all(color: colors.outlineVariant),
                borderRadius: BorderRadius.circular(9)),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.tugasFilterStatus,
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Text(tugasStatusLabel(t.status, l10n),
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 12),
                  _StatusActions(cubit: _cubit, status: t.status, l10n: l10n),
                  const SizedBox(height: 20),
                  Text(l10n.tugasFieldPriority,
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Text(tugasPriorityLabel(t.prioritas, l10n)),
                  if (t.estimasiMenit != null) ...[
                    const SizedBox(height: 20),
                    Text(l10n.tugasFieldEstimate,
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Text(l10n.tugasEstimate(t.estimasiMenit!))
                  ],
                  const SizedBox(height: 20),
                  Text(l10n.tugasFieldCourse,
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Text(state.course?.nama ?? l10n.tugasNoCourse),
                  const SizedBox(height: 20),
                  Text(l10n.tugasRemindersTitle,
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  if (t.reminders.isEmpty) Text(l10n.tugasRemindersEmpty),
                  for (final reminder in TaskReminder.fromJsonList(t.reminders))
                    Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(switch (reminder) {
                          CalendarDayReminder r => l10n.tugasReminderCalendar(
                              r.daysBefore, r.localTime.substring(0, 5)),
                          RelativeMinutesReminder r =>
                            l10n.tugasReminderRelative(r.minutesBefore),
                        })),
                  if (archived) ...[
                    const SizedBox(height: 20),
                    Text(l10n.tugasArchivedBadge)
                  ],
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                      onPressed: () => showAddEditTugasSheet(context,
                          cubit: widget.listCubit, existing: t),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: Text(l10n.tugasEditTitle)),
                  const SizedBox(height: 8),
                  OutlinedButton(
                      onPressed: () => _cubit.setArchived(!archived),
                      child: Text(
                          archived ? l10n.tugasUnarchive : l10n.tugasArchive)),
                  const SizedBox(height: 8),
                  TextButton(
                      style:
                          TextButton.styleFrom(foregroundColor: colors.error),
                      onPressed: () => _confirmDelete(context, l10n),
                      child: Text(l10n.tugasDelete)),
                ]));
        return TugasShell(
            db: widget.db,
            userId: t.userId,
            deviceId: widget.deviceId,
            child: LayoutBuilder(builder: (context, constraints) {
              final mobile = MediaQuery.sizeOf(context).width <= 680;
              return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: mobile ? 16 : 38, vertical: mobile ? 22 : 32),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.chevron_left),
                                label: Text(l10n.actionBack))),
                        const SizedBox(height: 12),
                        Text(t.judul,
                            style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 8),
                        Text(
                            DateFormat.yMMMEd(locale).add_Hm().format(
                                tz.TZDateTime.from(t.deadline,
                                    widget.listCubit.state.location)),
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 24),
                        if (constraints.maxWidth > 736)
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: content),
                                const SizedBox(width: 30),
                                SizedBox(width: 240, child: metadata)
                              ])
                        else ...[content, const SizedBox(height: 26), metadata],
                      ]));
            }));
      },
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, AppLocalizations l10n) async {
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
  const _StatusActions(
      {required this.cubit, required this.status, required this.l10n});
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
  const _ChecklistSection(
      {required this.cubit, required this.state, required this.l10n});
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
        Text(l10n.tugasChecklistTitle,
            style: Theme.of(context).textTheme.titleMedium),
        // All-done prompt offers a status change; never auto-changes (schema/
        // design: "Semua checklist selesai menawarkan perubahan status").
        if (state.allChecklistDone &&
            state.tugas?.status != TugasStatus.selesai)
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.tugasChecklistAllDone),
                  TextButton(
                    onPressed: () =>
                        widget.cubit.setStatus(TugasStatus.selesai),
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
            onChanged: (v) =>
                widget.cubit.setChecklistDone(item.id, v ?? false),
            title: Text(item.judul),
            secondary: IconButton(
              icon: const Icon(Icons.close),
              tooltip: l10n.tugasDelete,
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
                tooltip: l10n.tugasChecklistAdd,
                icon: const Icon(Icons.add),
                onPressed: _add),
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
