import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/tugas_providers.dart';
import 'widgets/tugas_form_sheet.dart';
import 'widgets/tugas_status_column.dart';

/// Tugas List — layout 3 kolom by status: Due Tugas (belum) di kiri,
/// Progress & Done ditumpuk di kanan. Status diubah langsung per-tile
/// (bukan lewat filter) — FR-6.7, FR-6.10, FR-6.13.
class TugasScreen extends ConsumerWidget {
  const TugasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tugasAsync = ref.watch(tugasListProvider);
    final mataKuliahAsync = ref.watch(mataKuliahListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tugas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.school_outlined),
            tooltip: 'Mata Kuliah',
            onPressed: () => context.push('/tugas/matakuliah'),
          ),
        ],
      ),
      body: mataKuliahAsync.when(
        data: (mataKuliahList) {
          final mataKuliahById = {for (final mk in mataKuliahList) mk.id: mk};

          return Column(
            children: [
              Expanded(
                child: tugasAsync.when(
                  data: (list) {
                    final sorted = [...list]..sort((a, b) => a.deadline.compareTo(b.deadline));
                    final belum = sorted.where((t) => t.status == 'belum').toList();
                    final progress = sorted.where((t) => t.status == 'progress').toList();
                    final selesai = sorted.where((t) => t.status == 'selesai').toList();

                    void onTap(t) => context.push('/tugas/${t.id}');

                    return Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: TugasStatusColumn(
                              title: 'Due Tugas',
                              items: belum,
                              mataKuliahById: mataKuliahById,
                              onTapTugas: onTap,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: TugasStatusColumn(
                                    title: 'Progress',
                                    items: progress,
                                    mataKuliahById: mataKuliahById,
                                    onTapTugas: onTap,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: TugasStatusColumn(
                                    title: 'Done',
                                    items: selesai,
                                    mataKuliahById: mataKuliahById,
                                    onTapTugas: onTap,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Gagal memuat: $e')),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTugasFormSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
