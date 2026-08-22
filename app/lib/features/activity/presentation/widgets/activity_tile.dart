import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_kategori_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../data/activity_repository.dart';

// FR-1.5 sebenarnya define 4 status (+ "berjalan"), tapi atas permintaan
// user opsi ini dikurangi jadi 3 di UI. Field `status` di database tetap
// mendukung 'berjalan' (data lama/dari backend tidak hilang, cuma tidak
// ditawarkan lagi sebagai pilihan baru).
// Label disamakan dengan label kolom kanban ("Not started/Done/Skipped",
// lihat activity_list_view.dart) supaya konsisten — bukan terjemahan
// PRD FR-1.5 (yang tetap Indonesia di dokumen), murni penyesuaian teks UI.
const _statusLabels = {
  'belum_mulai': 'Not started',
  'berjalan': 'Ongoing',
  'selesai': 'Done',
  'dilewati': 'Skipped',
};

const _statusCycle = ['belum_mulai', 'selesai', 'dilewati'];

/// Ikon status trailing per kolom — DESIGN.md v2 (○ belum mulai, ✓ selesai,
/// ✕ dilewati), menggantikan chip berlabel supaya lebih ringkas & konsisten
/// dengan file desain.
const _statusIcons = {
  'belum_mulai': Icons.radio_button_unchecked,
  'berjalan': Icons.radio_button_unchecked,
  'selesai': Icons.check_circle,
  'dilewati': Icons.cancel,
};

class ActivityTile extends StatelessWidget {
  const ActivityTile({
    super.key,
    required this.occurrence,
    required this.onTap,
    required this.onStatusChanged,
    this.isOverlapping = false,
  });

  final ActivityOccurrence occurrence;
  final VoidCallback onTap;
  final ValueChanged<String> onStatusChanged;
  final bool isOverlapping;

  @override
  Widget build(BuildContext context) {
    final activity = occurrence.data;
    final isDone = activity.status == 'selesai';
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        // Kartu bentrok TIDAK mengubah warna fill — file desain cuma
        // menambah border: `border: overlapIds.has(a.id) ? '1px solid
        // var(--color-accent-300)' : '1px solid transparent'`. Sempat salah
        // di-fill `primaryContainer` (23 Agu 2026) sehingga kartunya jadi
        // blok merah penuh di dark mode; dikembalikan ke border saja.
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: isOverlapping
            ? Border.all(color: AppColors.primaryContainerBorderOf(scheme.brightness))
            : null,
        // Shadow tipis dikonfirmasi 23 Agu 2026 lewat getComputedStyle()
        // pada kanban tile di file desain (stat card di Home sebaliknya
        // TIDAK punya shadow — jangan disamakan).
        boxShadow: const [
          BoxShadow(color: Color(0x242D2B2B), offset: Offset(0, 1), blurRadius: 2),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(kategoriIcon(activity.kategori), size: 13, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        // Label kategori DIREVISI 23 Agu 2026 — computed
                        // style-nya 14px/w500, bukan gaya eyebrow
                        // `labelSmall` (11px). Lihat `app_theme.dart`.
                        Text(
                          activity.kategori,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        if (occurrence.isVirtual) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.repeat, size: 12, color: scheme.onSurfaceVariant),
                        ],
                        if (isOverlapping) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 13,
                            color: AppColors.warningOf(scheme.brightness),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Judul kartu DIREVISI 23 Agu 2026 — computed weight-nya
                    // 800, bukan 600.
                    Text(
                      activity.judul,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            decoration: isDone ? TextDecoration.lineThrough : null,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Label waktu DIREVISI 23 Agu 2026 — computed size-nya
                    // 11px (bukan 13px `bodySmall`), warna muted.
                    if (!activity.isAllDay && activity.startTime != null)
                      Text(
                        TimeOfDay.fromDateTime(activity.startTime!).format(context) +
                            (activity.endTime != null
                                ? ' - ${TimeOfDay.fromDateTime(activity.endTime!).format(context)}'
                                : ''),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: scheme.onSurfaceVariant,
                            ),
                      )
                    else if (activity.isAllDay)
                      Text(
                        'All day',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                initialValue: activity.status,
                onSelected: onStatusChanged,
                itemBuilder: (_) => _statusCycle
                    .map((s) => PopupMenuItem(value: s, child: Text(_statusLabels[s]!)))
                    .toList(),
                child: Icon(
                  _statusIcons[activity.status] ?? Icons.radio_button_unchecked,
                  size: 20,
                  color: activity.status == 'belum_mulai' ? scheme.outline : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
