import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/theme/app_radius.dart';
import '../../application/tugas_providers.dart';
import 'tugas_tile.dart';

/// Kolom kanban Tugas — 1 dari 3 kolom sejajar (grid 3 x 1fr di file
/// desain). Struktur mengikuti file desain persis: judul kolom rata KIRI
/// + tag jumlah, lalu "drop zone" berlatar tipis (padding 10, gap 10,
/// radius 14, minHeight 80) berisi kartu tugas. Tinggi kolom mengikuti
/// isi (bukan panel full-height dengan scroll sendiri) — scroll terjadi
/// di level halaman, sesuai `display:grid` di desain.
class TugasStatusColumn extends ConsumerWidget {
  const TugasStatusColumn({
    super.key,
    required this.title,
    required this.status,
    required this.items,
    required this.mataKuliahById,
    required this.onTapTugas,
  });

  final String title;
  final String status;
  final List<TugasData> items;
  final Map<String, MataKuliahData> mataKuliahById;
  final ValueChanged<TugasData> onTapTugas;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontSize: 15),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.md * 0.75),
                ),
                child: Text(
                  '${items.length}',
                  style: const TextStyle(fontSize: 11, letterSpacing: 0.22),
                ),
              ),
            ],
          ),
        ),
        DragTarget<TugasData>(
          onWillAcceptWithDetails: (details) => details.data.status != status,
          onAcceptWithDetails: (details) => ref
              .read(tugasRepositoryProvider)
              .updateStatus(details.data.id, status),
          builder: (context, candidateData, rejectedData) {
            final isDropTarget = candidateData.isNotEmpty;
            return Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 80),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                // Desain pakai `--color-neutral-100` (abu sangat tipis) untuk
                // track kolom. Di sini dipakai overlay alpha dari `onSurface`
                // supaya trek tetap terlihat lebih redup dari kartu di KEDUA
                // tema — hex tetap dari desain akan menyatu dengan kartu di
                // mode gelap.
                color: isDropTarget
                    ? scheme.primaryContainer
                    : scheme.onSurface.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: isDropTarget
                    ? Border.all(color: scheme.primary, width: 2)
                    : null,
              ),
              child: items.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        'Drop a tugas here.',
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        for (var i = 0; i < items.length; i++) ...[
                          if (i > 0) const SizedBox(height: 10),
                          _draggableTile(items[i]),
                        ],
                      ],
                    ),
            );
          },
        ),
      ],
    );
  }

  Widget _draggableTile(TugasData t) {
    final tile = TugasTile(
      tugas: t,
      mataKuliah: mataKuliahById[t.mataKuliahId],
      onTap: () => onTapTugas(t),
    );
    return Draggable<TugasData>(
      data: t,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 260,
          child: Opacity(opacity: 0.9, child: tile),
        ),
      ),
      childWhenDragging: const SizedBox.shrink(),
      child: tile,
    );
  }
}
