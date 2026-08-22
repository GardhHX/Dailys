import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/activity_providers.dart';
import '../data/activity_repository.dart';
import 'widgets/activity_form_sheet.dart';
import 'widgets/activity_list_view.dart';
import 'widgets/activity_timeline_view.dart';

/// Today View — Daily Activity Log (FR-1.1 s/d FR-1.14). Timebox digabung
/// di sini nanti pada Phase 3 (PRD Section 7).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final viewMode = ref.watch(activityViewModeProvider);
    final activitiesAsync = ref.watch(activitiesForSelectedDateProvider);
    final completionAsync = ref.watch(completionRateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'complete_all') {
                await ref.read(activityRepositoryProvider).bulkComplete(selectedDate);
              } else if (value == 'reschedule_all') {
                final target = await showDatePicker(
                  context: context,
                  initialDate: selectedDate.add(const Duration(days: 1)),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (target != null) {
                  await ref.read(activityRepositoryProvider).bulkReschedule(selectedDate, target);
                }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'complete_all', child: Text('Tandai semua selesai')),
              PopupMenuItem(value: 'reschedule_all', child: Text('Reschedule semua ke hari lain')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(context, ref, selectedDate, completionAsync.valueOrNull, viewMode),
          Expanded(
            child: activitiesAsync.when(
              data: (occurrences) {
                return viewMode == ActivityViewMode.list
                    ? ActivityListView(
                        occurrences: occurrences,
                        onTapOccurrence: (o) => _openEditor(context, ref, o, selectedDate),
                      )
                    : ActivityTimelineView(
                        occurrences: occurrences,
                        onTapOccurrence: (o) => _openEditor(context, ref, o, selectedDate),
                      );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Gagal memuat: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showActivityFormSheet(context, initialDate: selectedDate),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Edit occurrence yang virtual berarti "lepas dari template" — dibuatkan
  /// row asli dulu (materialize) untuk hari itu saja, baru form edit dibuka
  /// untuk row barunya. Hari-hari lain tetap ikut template asli.
  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref,
    ActivityOccurrence occurrence,
    DateTime selectedDate,
  ) async {
    var target = occurrence.data;
    if (occurrence.isVirtual) {
      final repo = ref.read(activityRepositoryProvider);
      final newId = await repo.materializeOccurrence(occurrence);
      final materialized = await repo.getById(newId);
      if (materialized == null) return;
      target = materialized;
    }
    if (!context.mounted) return;
    await showActivityFormSheet(context, editing: target, initialDate: selectedDate);
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
    CompletionRate? completion,
    ActivityViewMode viewMode,
  ) {
    final rate = completion?.rate ?? 0.0;
    final completed = completion?.completed ?? 0;
    final total = completion?.total ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => ref.read(selectedDateProvider.notifier).state =
                    selectedDate.subtract(const Duration(days: 1)),
              ),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) ref.read(selectedDateProvider.notifier).state = picked;
                },
                child: Text(
                  _formatDate(selectedDate),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => ref.read(selectedDateProvider.notifier).state =
                    selectedDate.add(const Duration(days: 1)),
              ),
              const Spacer(),
              SegmentedButton<ActivityViewMode>(
                segments: const [
                  ButtonSegment(value: ActivityViewMode.list, icon: Icon(Icons.view_list)),
                  ButtonSegment(value: ActivityViewMode.timeline, icon: Icon(Icons.view_timeline)),
                ],
                selected: {viewMode},
                onSelectionChanged: (s) => ref.read(activityViewModeProvider.notifier).state = s.first,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(child: LinearProgressIndicator(value: rate)),
              const SizedBox(width: 8),
              Text('$completed/$total selesai'),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
