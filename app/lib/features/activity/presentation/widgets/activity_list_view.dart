import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_radius.dart';
import '../../application/activity_providers.dart';
import '../../data/activity_repository.dart';
import 'activity_tile.dart';

const _sections = [
  ('belum_mulai', 'Belum Mulai'),
  ('selesai', 'Selesai'),
  ('dilewati', 'Dilewati'),
];

/// 3 kolom vertikal (kanban-style) berdasarkan status — selalu tampil
/// walau kosong, supaya user tetap lihat strukturnya.
class ActivityListView extends ConsumerWidget {
  const ActivityListView({super.key, required this.occurrences, required this.onTapOccurrence});

  final List<ActivityOccurrence> occurrences;
  final ValueChanged<ActivityOccurrence> onTapOccurrence;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (status, label) in _sections) ...[
            Expanded(child: _buildColumn(context, ref, status, label)),
            if (status != _sections.last.$1) const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildColumn(BuildContext context, WidgetRef ref, String status, String label) {
    // Status lain di luar 3 kolom ini (mis. "berjalan" dari data lama)
    // dikelompokkan ke "Belum Mulai" supaya tidak hilang dari tampilan.
    final items = status == 'belum_mulai'
        ? occurrences.where((o) => !_sections.any((s) => s.$1 == o.data.status) || o.data.status == status).toList()
        : occurrences.where((o) => o.data.status == status).toList();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: Text(
              '$label (${items.length})',
              style: Theme.of(context).textTheme.labelLarge,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      'Kosong',
                      style: TextStyle(color: Theme.of(context).colorScheme.outline),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    children: [
                      for (final o in items)
                        ActivityTile(
                          occurrence: o,
                          onTap: () => onTapOccurrence(o),
                          onStatusChanged: (newStatus) async {
                            final repo = ref.read(activityRepositoryProvider);
                            if (o.isVirtual) {
                              await repo.materializeOccurrence(o, status: newStatus);
                            } else {
                              await repo.updateStatus(o.data.id, newStatus);
                            }
                          },
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
