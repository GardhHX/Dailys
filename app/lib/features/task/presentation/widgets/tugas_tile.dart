import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../application/tugas_providers.dart';
import 'tugas_format.dart';

/// Tile ringkas untuk kolom Due/Progress/Done — dot warna Mata Kuliah,
/// badge prioritas, countdown, dan progress checklist, mengikuti layout
/// kartu Tugas di file desain Claude Design (DESIGN.md v2).
class TugasTile extends ConsumerWidget {
  const TugasTile({super.key, required this.tugas, required this.mataKuliah, required this.onTap});

  final TugasData tugas;
  final MataKuliahData? mataKuliah;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overdue = isOverdue(tugas.deadline, tugas.status);
    final scheme = Theme.of(context).colorScheme;
    // Teks/ikon countdown overdue — kartunya berlatar normal (bukan fill
    // aksen), jadi `primary` sudah cukup kontras di kedua tema.
    const accent = AppColors.primary;
    final checklistAsync = ref.watch(checklistProvider(tugas.id));
    final checklist = checklistAsync.valueOrNull ?? const [];

    return Container(
      // Tanpa margin — jarak antar kartu (gap 10) diatur kolomnya, sesuai
      // `display:flex;gap:10` pada drop zone di file desain.
      decoration: BoxDecoration(
        // Sama seperti kartu bentrok di Home: highlight overdue cuma
        // BORDER, fill kartu tidak berubah — `cardStyle` di file desain
        // hanya menukar `border: 1px solid transparent` jadi
        // `1px solid var(--color-accent-300)` saat overdue.
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: overdue
            ? Border.all(color: AppColors.primaryContainerBorderOf(scheme.brightness))
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: mataKuliah == null ? scheme.outline : AppColors.hexToColor(mataKuliah!.warna),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      mataKuliah?.nama ?? '—',
                      style: Theme.of(context).textTheme.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _PriorityBadge(prioritas: tugas.prioritas),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.more_vert, size: 16),
                    onSelected: (s) => ref.read(tugasRepositoryProvider).updateStatus(tugas.id, s),
                    itemBuilder: (_) => statusLabels.entries
                        .map((e) => PopupMenuItem(value: e.key, child: Text(e.value)))
                        .toList(),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                tugas.judul,
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 12, color: overdue ? accent : scheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    countdownLabel(tugas.deadline),
                    style: TextStyle(
                      fontSize: 11,
                      color: overdue ? accent : scheme.onSurfaceVariant,
                      fontWeight: overdue ? FontWeight.bold : null,
                    ),
                  ),
                  if (checklist.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text('·', style: TextStyle(color: scheme.onSurfaceVariant)),
                    const SizedBox(width: 8),
                    Icon(Icons.checklist_rounded, size: 12, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      '${checklist.where((c) => c.isDone).length}/${checklist.length}',
                      style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Badge prioritas — 1 gaya (fill primary_container + teks primary) untuk
/// ketiga level, dibedakan lewat teks label saja (DESIGN.md v2 Section 2.4).
class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.prioritas});

  final String prioritas;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        prioritasLabels[prioritas] ?? prioritas,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.accentOnPrimaryContainerOf(scheme.brightness),
        ),
      ),
    );
  }
}
