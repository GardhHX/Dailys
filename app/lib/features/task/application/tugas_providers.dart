import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../activity/application/activity_providers.dart' show databaseProvider;
import '../data/tugas_repository.dart';

final tugasRepositoryProvider = Provider<TugasRepository>((ref) {
  return TugasRepository(ref.watch(databaseProvider).tugasDao);
});

final mataKuliahListProvider = StreamProvider<List<MataKuliahData>>((ref) {
  return ref.watch(tugasRepositoryProvider).watchMataKuliah();
});

final tugasListProvider = StreamProvider<List<TugasData>>((ref) {
  return ref.watch(tugasRepositoryProvider).watchTugas();
});

final checklistProvider = StreamProvider.family<List<TugasChecklistData>, String>((ref, tugasId) {
  return ref.watch(tugasRepositoryProvider).watchChecklist(tugasId);
});

// Provider untuk Weekly Workload (FR-6.12) sengaja belum ada — UI-nya
// dilepas dulu atas permintaan user, tapi TugasRepository.weeklyWorkload()
// & endpoint backend /tugas/workload-mingguan tetap ada kalau mau
// dipasang lagi nanti (lihat PLAN.md Phase 2).
