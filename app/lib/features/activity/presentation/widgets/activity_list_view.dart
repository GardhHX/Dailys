import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_radius.dart';
import '../../application/activity_providers.dart';
import '../../data/activity_repository.dart';
import 'activity_tile.dart';

// Label kolom "Not started/Done/Skipped" — teks persis dari file desain
// Claude Design (bukan terjemahan Indonesia lagi), field `status` di
// database tetap pakai key Indonesia sesuai schema.md, cuma label
// tampilannya yang disamakan dengan sumber desain.
const _sections = [
  ('belum_mulai', 'Not started'),
  ('selesai', 'Done'),
  ('dilewati', 'Skipped'),
];

/// 3 kolom vertikal (kanban-style) berdasarkan status — selalu tampil
/// walau kosong. Mendukung drag-and-drop kartu antar kolom untuk ubah
/// status (DESIGN.md v2 Section 6) — ini interaksi berbeda dari
/// "drag-and-drop reschedule di timeline" yang PRD sengaja taruh di luar
/// scope v1 (itu soal ubah waktu di timeline, ini cuma ubah status).
class ActivityListView extends ConsumerWidget {
  const ActivityListView({super.key, required this.occurrences, required this.onTapOccurrence});

  final List<ActivityOccurrence> occurrences;
  final ValueChanged<ActivityOccurrence> onTapOccurrence;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overlapping = overlappingOccurrenceKeys(occurrences);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (status, label) in _sections) ...[
            Expanded(child: _buildColumn(context, ref, status, label, overlapping)),
            if (status != _sections.last.$1) const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildColumn(
    BuildContext context,
    WidgetRef ref,
    String status,
    String label,
    Set<String> overlapping,
  ) {
    // Status lain di luar 3 kolom ini (mis. "berjalan" dari data lama)
    // dikelompokkan ke "Belum Mulai" supaya tidak hilang dari tampilan.
    final items = status == 'belum_mulai'
        ? occurrences.where((o) => !_sections.any((s) => s.$1 == o.data.status) || o.data.status == status).toList()
        : occurrences.where((o) => o.data.status == status).toList();

    return DragTarget<ActivityOccurrence>(
      onWillAcceptWithDetails: (details) => details.data.data.status != status,
      onAcceptWithDetails: (details) => _changeStatus(ref, details.data, status),
      builder: (context, candidateData, rejectedData) {
        final isDropTarget = candidateData.isNotEmpty;
        final scheme = Theme.of(context).colorScheme;
        return Container(
          decoration: BoxDecoration(
            color: isDropTarget ? scheme.primaryContainer : null,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: isDropTarget ? Border.all(color: scheme.primary) : null,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text('${items.length}', style: Theme.of(context).textTheme.labelSmall),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          'Empty',
                          style: TextStyle(color: Theme.of(context).colorScheme.outline),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        children: [
                          for (final o in items)
                            Draggable<ActivityOccurrence>(
                              data: o,
                              feedback: Material(
                                color: Colors.transparent,
                                child: SizedBox(
                                  width: 260,
                                  child: Opacity(
                                    opacity: 0.9,
                                    child: ActivityTile(
                                      occurrence: o,
                                      onTap: () {},
                                      onStatusChanged: (_) {},
                                      isOverlapping: overlapping.contains(o.occurrenceKey),
                                    ),
                                  ),
                                ),
                              ),
                              childWhenDragging: const SizedBox(height: 0),
                              child: ActivityTile(
                                occurrence: o,
                                onTap: () => onTapOccurrence(o),
                                isOverlapping: overlapping.contains(o.occurrenceKey),
                                onStatusChanged: (newStatus) => _changeStatus(ref, o, newStatus),
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _changeStatus(WidgetRef ref, ActivityOccurrence o, String newStatus) async {
    final repo = ref.read(activityRepositoryProvider);
    if (o.isVirtual) {
      await repo.materializeOccurrence(o, status: newStatus);
    } else {
      await repo.updateStatus(o.data.id, newStatus);
    }
  }
}
