import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_kategori_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../application/timebox_providers.dart';
import '../../data/timebox_repository.dart';
import 'timebox_form_sheet.dart';

const _hourHeight = 56.0;
const _startHour = 6;
const _endHour = 23;
const _hariLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

IconData _iconFor(String kategori) => kategoriIcon(kategori);

/// Grid mingguan Timebox (Senin-Minggu x jam) — FR-3.3. Block recurring
/// (template) tampil tiap minggu; block ad-hoc cuma tampil di minggu yang
/// tanggalnya cocok (lihat [TimeboxRepository.watchForWeek]).
class TimeboxWeeklyGridView extends ConsumerWidget {
  const TimeboxWeeklyGridView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekStart = ref.watch(selectedWeekStartProvider);
    final occurrencesAsync = ref.watch(timeboxForWeekProvider);

    return Column(
      children: [
        _buildWeekNav(context, ref, weekStart),
        _buildLegend(context),
        Expanded(
          child: occurrencesAsync.when(
            data: (occurrences) => _buildGrid(context, ref, weekStart, occurrences),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Failed to load: $e')),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekNav(BuildContext context, WidgetRef ref, DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => ref.read(selectedWeekStartProvider.notifier).state =
                weekStart.subtract(const Duration(days: 7)),
          ),
          Text(
            '${_fmt(weekStart)} - ${_fmt(weekEnd)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => ref.read(selectedWeekStartProvider.notifier).state =
                weekStart.add(const Duration(days: 7)),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}';

  Widget _buildLegend(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        children: [
          for (final k in AppColors.kategoriDefault.keys)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_iconFor(k), size: 14, color: AppColors.kategoriColor(k)),
                const SizedBox(width: 4),
                Text(k, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    WidgetRef ref,
    DateTime weekStart,
    List<TimeboxBlockOccurrence> occurrences,
  ) {
    final hourCount = _endHour - _startHour;
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeColumn(context, hourCount),
          for (var weekday = 1; weekday <= 7; weekday++)
            Expanded(
              child: _buildDayColumn(
                context,
                ref,
                weekStart,
                weekday,
                hourCount,
                occurrences.where((o) => o.weekday == weekday).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeColumn(BuildContext context, int hourCount) {
    return SizedBox(
      width: 48,
      child: Column(
        children: [
          const SizedBox(height: 32), // sejajar dengan header hari
          for (var h = 0; h < hourCount; h++)
            SizedBox(
              height: _hourHeight,
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '${(_startHour + h).toString().padLeft(2, '0')}:00',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDayColumn(
    BuildContext context,
    WidgetRef ref,
    DateTime weekStart,
    int weekday,
    int hourCount,
    List<TimeboxBlockOccurrence> dayOccurrences,
  ) {
    return Column(
      children: [
        SizedBox(
          height: 32,
          child: Center(
            child: Text(_hariLabels[weekday - 1], style: Theme.of(context).textTheme.labelLarge),
          ),
        ),
        GestureDetector(
          onTap: () => showTimeboxFormSheet(context, weekStart: weekStart, initialWeekday: weekday),
          child: Container(
            height: _hourHeight * hourCount,
            decoration: BoxDecoration(border: Border.all(color: Theme.of(context).dividerColor, width: 0.5)),
            child: Stack(
              children: [
                for (final o in dayOccurrences) _buildBlock(context, ref, weekStart, o),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBlock(BuildContext context, WidgetRef ref, DateTime weekStart, TimeboxBlockOccurrence o) {
    final (startH, startM) = o.startMinutes;
    final (endH, endM) = o.endMinutes;
    final top = ((startH - _startHour) + startM / 60) * _hourHeight;
    final height = (((endH * 60 + endM) - (startH * 60 + startM)) / 60) * _hourHeight;
    final color = AppColors.kategoriColor(o.data.kategori);

    return Positioned(
      top: top.clamp(0, double.infinity),
      left: 2,
      right: 2,
      height: height.clamp(20, double.infinity),
      child: GestureDetector(
        onTap: () => showTimeboxFormSheet(context, editing: o.data, weekStart: weekStart),
        onLongPress: o.data.isRecurring ? () => _showBlockActions(context, ref, o.data) : null,
        child: Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: o.data.isActive ? 0.18 : 0.06),
            border: Border.all(
              color: color,
              style: o.data.isRecurring ? BorderStyle.solid : BorderStyle.none,
            ),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_iconFor(o.data.kategori), size: 12, color: color),
                  if (o.data.isRecurring) ...[
                    const SizedBox(width: 2),
                    Icon(Icons.repeat, size: 11, color: color),
                  ],
                  const Spacer(),
                  InkWell(
                    onTap: () => _confirmDelete(context, ref, o.data),
                    child: Icon(Icons.close, size: 12, color: color),
                  ),
                ],
              ),
              Flexible(
                child: Text(
                  o.data.judul,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Aksi khusus block recurring — duplikasi ke hari lain (FR-3.11) &
  /// nonaktifkan sementara (FR-3.12).
  Future<void> _showBlockActions(BuildContext context, WidgetRef ref, TimeboxScheduleData data) async {
    await showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy_outlined),
              title: const Text('Duplicate to another day'),
              onTap: () async {
                Navigator.pop(sheetContext);
                final targetWeekday = await showDialog<int>(
                  context: context,
                  builder: (dialogContext) => SimpleDialog(
                    title: const Text('Duplicate to day'),
                    children: [
                      for (var i = 0; i < 7; i++)
                        SimpleDialogOption(
                          onPressed: () => Navigator.pop(dialogContext, i + 1),
                          child: Text(_hariLabels[i]),
                        ),
                    ],
                  ),
                );
                if (targetWeekday != null) {
                  await ref.read(timeboxRepositoryProvider).duplicateToDay(
                        data.id,
                        hariFromWeekday(targetWeekday),
                      );
                }
              },
            ),
            ListTile(
              leading: Icon(data.isActive ? Icons.pause_circle_outline : Icons.play_circle_outline),
              title: Text(data.isActive ? 'Deactivate temporarily' : 'Reactivate'),
              onTap: () async {
                Navigator.pop(sheetContext);
                await ref.read(timeboxRepositoryProvider).toggleActive(data.id, !data.isActive);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, TimeboxScheduleData data) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete block?'),
        content: Text('"${data.judul}" will be deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            // Override minimumSize — theme default width infinite berisiko
            // di dalam AlertDialog.actions (OverflowBar), lihat catatan yang
            // sama di home_screen.dart.
            style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(timeboxRepositoryProvider).deleteBlock(data.id);
    }
  }
}
