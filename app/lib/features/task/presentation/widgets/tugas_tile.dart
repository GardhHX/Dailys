import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/tugas_providers.dart';
import 'tugas_format.dart';

/// Tile ringkas untuk kolom Due/Progress/Done — status diubah lewat menu
/// titik tiga (bukan lewat drag antar kolom, supaya tetap simpel).
class TugasTile extends ConsumerWidget {
  const TugasTile({super.key, required this.tugas, required this.mataKuliah, required this.onTap});

  final TugasData tugas;
  final MataKuliahData? mataKuliah;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overdue = isOverdue(tugas.deadline, tugas.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      color: overdue ? AppColors.danger.withValues(alpha: 0.08) : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 32,
                color: mataKuliah == null ? AppColors.primary : AppColors.hexToColor(mataKuliah!.warna),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(tugas.judul, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(
                      countdownLabel(tugas.deadline),
                      style: TextStyle(
                        fontSize: 11,
                        color: overdue ? AppColors.danger : Theme.of(context).colorScheme.outline,
                        fontWeight: overdue ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: prioritasColors[tugas.prioritas] ?? AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 18),
                onSelected: (s) => ref.read(tugasRepositoryProvider).updateStatus(tugas.id, s),
                itemBuilder: (_) => statusLabels.entries
                    .map((e) => PopupMenuItem(value: e.key, child: Text(e.value)))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
