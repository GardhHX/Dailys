import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/activity_repository.dart';

// FR-1.5 sebenarnya define 4 status (+ "berjalan"), tapi atas permintaan
// user opsi ini dikurangi jadi 3 di UI. Field `status` di database tetap
// mendukung 'berjalan' (data lama/dari backend tidak hilang, cuma tidak
// ditawarkan lagi sebagai pilihan baru).
const _statusLabels = {
  'belum_mulai': 'Belum mulai',
  'berjalan': 'Berjalan',
  'selesai': 'Selesai',
  'dilewati': 'Dilewati',
};

const _statusCycle = ['belum_mulai', 'selesai', 'dilewati'];

class ActivityTile extends StatelessWidget {
  const ActivityTile({
    super.key,
    required this.occurrence,
    required this.onTap,
    required this.onStatusChanged,
  });

  final ActivityOccurrence occurrence;
  final VoidCallback onTap;
  final ValueChanged<String> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final activity = occurrence.data;
    final color = AppColors.kategoriColor(activity.kategori);
    final isDone = activity.status == 'selesai';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: Container(width: 4, height: 40, color: color),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                activity.judul,
                style: isDone ? const TextStyle(decoration: TextDecoration.lineThrough) : null,
              ),
            ),
            if (occurrence.isVirtual) ...[
              const SizedBox(width: 4),
              const Icon(Icons.repeat, size: 14),
            ],
          ],
        ),
        subtitle: Text([
          activity.kategori,
          if (!activity.isAllDay && activity.startTime != null)
            TimeOfDay.fromDateTime(activity.startTime!).format(context) +
                (activity.endTime != null ? ' - ${TimeOfDay.fromDateTime(activity.endTime!).format(context)}' : ''),
          if (activity.isAllDay) 'Sepanjang hari',
        ].join(' • ')),
        trailing: PopupMenuButton<String>(
          initialValue: activity.status,
          onSelected: onStatusChanged,
          itemBuilder: (_) => _statusCycle
              .map((s) => PopupMenuItem(value: s, child: Text(_statusLabels[s]!)))
              .toList(),
          child: Chip(label: Text(_statusLabels[activity.status] ?? activity.status)),
        ),
      ),
    );
  }
}
