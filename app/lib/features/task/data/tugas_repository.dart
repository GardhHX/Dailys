import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/database/daos/tugas_dao.dart';
import '../../../core/database/database.dart';

const _uuid = Uuid();

/// Sentinel supaya `updateTugas` bisa bedakan "field tidak dikirim" (jangan
/// diubah) vs "field dikirim sebagai null" (misal user pilih "Tidak ada"
/// di dropdown Mata Kuliah untuk clear pilihan) — kalau cuma pakai `T?`
/// biasa, kedua kondisi itu sama-sama `null` dan tidak bisa dibedakan.
const _unset = Object();

/// Total tugas & estimasi jam pada 1 rentang minggu — FR-6.12.
class WeeklyWorkload {
  const WeeklyWorkload({required this.weekStart, required this.totalTugas, required this.totalEstimasiMenit});

  final DateTime weekStart;
  final int totalTugas;
  final int totalEstimasiMenit;
}

/// Layer di antara UI dan [TugasDao] — nampung business rule (generate
/// id/timestamp, hitung workload mingguan).
class TugasRepository {
  TugasRepository(this._dao);

  final TugasDao _dao;

  // ---- Mata Kuliah ----

  Stream<List<MataKuliahData>> watchMataKuliah() => _dao.watchMataKuliah();

  Future<String> createMataKuliah({
    required String nama,
    String? dosen,
    int? sks,
    String? semester,
    required String warna,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _dao.insertMataKuliah(MataKuliahCompanion.insert(
      id: id,
      userId: kLocalUserId,
      nama: nama,
      warna: warna,
      dosen: Value(dosen),
      sks: Value(sks),
      semester: Value(semester),
      createdAt: now,
      updatedAt: now,
    ));
    return id;
  }

  Future<void> updateMataKuliah(
    String id, {
    String? nama,
    String? dosen,
    int? sks,
    String? semester,
    String? warna,
  }) {
    return _dao.updateMataKuliah(
      id,
      MataKuliahCompanion(
        nama: nama == null ? const Value.absent() : Value(nama),
        dosen: dosen == null ? const Value.absent() : Value(dosen),
        sks: sks == null ? const Value.absent() : Value(sks),
        semester: semester == null ? const Value.absent() : Value(semester),
        warna: warna == null ? const Value.absent() : Value(warna),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteMataKuliah(String id) => _dao.softDeleteMataKuliah(id);

  // ---- Tugas ----

  Stream<List<TugasData>> watchTugas() => _dao.watchTugas();

  Future<TugasData?> getTugasById(String id) => _dao.getTugasById(id);

  Future<String> createTugas({
    required String judul,
    String? mataKuliahId,
    String? deskripsi,
    required DateTime deadline,
    required String prioritas,
    int? estimasiMenit,
    List<int>? reminderOffsets,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _dao.insertTugas(TugasCompanion.insert(
      id: id,
      userId: kLocalUserId,
      judul: judul,
      deadline: deadline,
      prioritas: prioritas,
      status: 'belum',
      mataKuliahId: Value(mataKuliahId),
      deskripsi: Value(deskripsi),
      estimasiMenit: Value(estimasiMenit),
      reminderOffsets: reminderOffsets == null
          ? const Value.absent()
          : Value('[${reminderOffsets.join(',')}]'),
      createdAt: now,
      updatedAt: now,
    ));
    return id;
  }

  Future<void> updateTugas(
    String id, {
    String? judul,
    Object? mataKuliahId = _unset,
    String? deskripsi,
    DateTime? deadline,
    String? prioritas,
    String? status,
    Object? estimasiMenit = _unset,
    List<int>? reminderOffsets,
  }) {
    return _dao.updateTugas(
      id,
      TugasCompanion(
        judul: judul == null ? const Value.absent() : Value(judul),
        mataKuliahId: identical(mataKuliahId, _unset) ? const Value.absent() : Value(mataKuliahId as String?),
        deskripsi: deskripsi == null ? const Value.absent() : Value(deskripsi),
        deadline: deadline == null ? const Value.absent() : Value(deadline),
        prioritas: prioritas == null ? const Value.absent() : Value(prioritas),
        status: status == null ? const Value.absent() : Value(status),
        estimasiMenit: identical(estimasiMenit, _unset) ? const Value.absent() : Value(estimasiMenit as int?),
        reminderOffsets:
            reminderOffsets == null ? const Value.absent() : Value('[${reminderOffsets.join(',')}]'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateStatus(String id, String status) =>
      _dao.updateTugas(id, TugasCompanion(status: Value(status), updatedAt: Value(DateTime.now())));

  Future<void> deleteTugas(String id) => _dao.softDeleteTugas(id);

  // ---- Checklist ----

  Stream<List<TugasChecklistData>> watchChecklist(String tugasId) => _dao.watchChecklist(tugasId);

  Future<void> addChecklistItem(String tugasId, String judul, int urutan) {
    final now = DateTime.now();
    return _dao.insertChecklistItem(TugasChecklistCompanion.insert(
      id: _uuid.v4(),
      tugasId: tugasId,
      judul: judul,
      urutan: urutan,
      createdAt: now,
      updatedAt: now,
    ));
  }

  Future<void> toggleChecklistItem(String id, bool isDone) => _dao.updateChecklistItem(
        id,
        TugasChecklistCompanion(isDone: Value(isDone), updatedAt: Value(DateTime.now())),
      );

  Future<void> deleteChecklistItem(String id) => _dao.softDeleteChecklistItem(id);

  // ---- Weekly Workload — FR-6.12 ----

  /// Total tugas & estimasi menit per minggu, untuk [weekCount] minggu mulai
  /// dari minggu berjalan (Senin sebagai awal minggu).
  Future<List<WeeklyWorkload>> weeklyWorkload({DateTime? from, int weekCount = 6}) async {
    final today = from ?? DateTime.now();
    final mondayThisWeek = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: today.weekday - 1));

    final allTugas = await _dao.watchTugas().first;
    final result = <WeeklyWorkload>[];

    for (var i = 0; i < weekCount; i++) {
      final weekStart = mondayThisWeek.add(Duration(days: 7 * i));
      final weekEnd = weekStart.add(const Duration(days: 7));
      final inWeek = allTugas.where((t) => !t.deadline.isBefore(weekStart) && t.deadline.isBefore(weekEnd));

      result.add(WeeklyWorkload(
        weekStart: weekStart,
        totalTugas: inWeek.length,
        totalEstimasiMenit: inWeek.fold(0, (sum, t) => sum + (t.estimasiMenit ?? 0)),
      ));
    }
    return result;
  }
}
