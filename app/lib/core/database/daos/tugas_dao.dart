import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';

part 'tugas_dao.g.dart';

@DriftAccessor(tables: [MataKuliah, Tugas, TugasChecklist])
class TugasDao extends DatabaseAccessor<AppDatabase> with _$TugasDaoMixin {
  TugasDao(super.db);

  // ---- Mata Kuliah — FR-6.5 ----

  Stream<List<MataKuliahData>> watchMataKuliah() {
    return (select(mataKuliah)
          ..where((m) => m.isDeleted.equals(false))
          ..orderBy([(m) => OrderingTerm(expression: m.nama)]))
        .watch();
  }

  Future<MataKuliahData?> getMataKuliahById(String id) =>
      (select(mataKuliah)..where((m) => m.id.equals(id))).getSingleOrNull();

  Future<void> insertMataKuliah(MataKuliahCompanion entry) => into(mataKuliah).insert(entry);

  Future<void> updateMataKuliah(String id, MataKuliahCompanion entry) =>
      (update(mataKuliah)..where((m) => m.id.equals(id))).write(entry);

  Future<void> softDeleteMataKuliah(String id) =>
      (update(mataKuliah)..where((m) => m.id.equals(id))).write(
        MataKuliahCompanion(
          isDeleted: const Value(true),
          deletedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );

  // ---- Tugas — FR-6.1 s/d FR-6.18 ----

  Stream<List<TugasData>> watchTugas() {
    return (select(tugas)..where((t) => t.isDeleted.equals(false))).watch();
  }

  Future<TugasData?> getTugasById(String id) =>
      (select(tugas)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> insertTugas(TugasCompanion entry) => into(tugas).insert(entry);

  Future<void> updateTugas(String id, TugasCompanion entry) =>
      (update(tugas)..where((t) => t.id.equals(id))).write(entry);

  /// Soft delete — jangan pernah hard delete (CLAUDE.md Section 4).
  /// Riwayat tugas selesai tetap ada karena cuma diarsipkan lewat status,
  /// bukan dihapus (FR-6.17) — ini khusus untuk hapus manual oleh user.
  Future<void> softDeleteTugas(String id) => (update(tugas)..where((t) => t.id.equals(id))).write(
        TugasCompanion(
          isDeleted: const Value(true),
          deletedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );

  // ---- Checklist — FR-6.14 ----

  Stream<List<TugasChecklistData>> watchChecklist(String tugasId) {
    return (select(tugasChecklist)
          ..where((c) => c.tugasId.equals(tugasId) & c.isDeleted.equals(false))
          ..orderBy([(c) => OrderingTerm(expression: c.urutan)]))
        .watch();
  }

  Future<void> insertChecklistItem(TugasChecklistCompanion entry) => into(tugasChecklist).insert(entry);

  Future<void> updateChecklistItem(String id, TugasChecklistCompanion entry) =>
      (update(tugasChecklist)..where((c) => c.id.equals(id))).write(entry);

  Future<void> softDeleteChecklistItem(String id) =>
      (update(tugasChecklist)..where((c) => c.id.equals(id))).write(
        TugasChecklistCompanion(
          isDeleted: const Value(true),
          deletedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );
}
