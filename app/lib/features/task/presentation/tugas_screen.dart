import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/database.dart';
import '../../../shared/widgets/screen_header.dart';
import '../application/tugas_providers.dart';
import 'widgets/tugas_form_sheet.dart';
import 'widgets/tugas_status_column.dart';

/// Tugas List — 3 kolom kanban SEJAJAR (Due Tugas / Progress / Done),
/// masing-masing 1fr, persis `grid-template-columns:repeat(3,1fr)` di file
/// desain Claude Design. Sebelumnya "Due Tugas" memenuhi kolom kiri penuh
/// sementara Progress & Done ditumpuk di kanan — itu tidak ada di desain,
/// diperbaiki 23 Agu 2026 atas permintaan user (FR-6.7, FR-6.13).
/// **Filter chip prioritas & mata kuliah (FR-6.10) sengaja TIDAK dipasang**
/// meski ada di file desain — dihapus ulang atas permintaan eksplisit user
/// 22 Agu 2026 (setelah sempat dikembalikan di sesi sebelumnya karena
/// desain menunjukkannya). Ini penyimpangan sadar dari file desain, bukan
/// asumsi AI — lihat catatan di `PLAN.md` & `DESIGN.md` Section 6.
class TugasScreen extends ConsumerStatefulWidget {
  const TugasScreen({super.key});

  @override
  ConsumerState<TugasScreen> createState() => _TugasScreenState();
}

class _TugasScreenState extends ConsumerState<TugasScreen> {
  @override
  Widget build(BuildContext context) {
    final tugasAsync = ref.watch(tugasListProvider);
    final mataKuliahAsync = ref.watch(mataKuliahListProvider);

    return Scaffold(
      body: Column(
        children: [
          ScreenHeader(
            eyebrow: 'TUGAS',
            title: 'Coursework',
            subtitle: 'Deadlines, priority and progress by mata kuliah',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  // Override minimumSize — theme default width infinite
                  // crash kalau dipakai langsung di Row, lihat catatan yang
                  // sama di home_screen.dart.
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                  ),
                  onPressed: () => context.push('/tugas/matakuliah'),
                  icon: const Icon(Icons.school_outlined, size: 18),
                  label: const Text('Mata Kuliah'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
                  onPressed: () => showTugasFormSheet(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Tugas'),
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody(context, mataKuliahAsync, tugasAsync)),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncValue<List<MataKuliahData>> mataKuliahAsync,
    AsyncValue<List<TugasData>> tugasAsync,
  ) {
    return mataKuliahAsync.when(
      data: (mataKuliahList) {
        final mataKuliahById = {for (final mk in mataKuliahList) mk.id: mk};

        return tugasAsync.when(
          data: (list) {
            final sorted = [...list]
              ..sort((a, b) => a.deadline.compareTo(b.deadline));

            void onTap(TugasData t) => context.push('/tugas/${t.id}');

            // Kolom didefinisikan sebagai data (label, key status) supaya
            // ketiganya dibangun lewat 1 loop — menjamin lebar & jarak
            // ketiga kolom benar-benar identik seperti grid di desain,
            // alih-alih 3 blok widget terpisah yang gampang melenceng.
            const columns = [
              ('Due Tugas', 'belum'),
              ('Progress', 'progress'),
              ('Done', 'selesai'),
            ];

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 48),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final (label, status) in columns) ...[
                    if (status != columns.first.$2) const SizedBox(width: 20),
                    Expanded(
                      child: TugasStatusColumn(
                        title: label,
                        status: status,
                        items: sorted.where((t) => t.status == status).toList(),
                        mataKuliahById: mataKuliahById,
                        onTapTugas: onTap,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Failed to load: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load: $e')),
    );
  }
}
