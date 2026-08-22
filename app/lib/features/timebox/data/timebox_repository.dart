import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/database/daos/timebox_dao.dart';
import '../../../core/database/database.dart';

const _uuid = Uuid();

/// Urutan `hari` sesuai `Hari` enum di `schema.prisma` (Senin sebagai hari
/// pertama minggu, konsisten dengan `DateTime.weekday` Dart: 1=Senin).
const kHariUrutan = ['senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu', 'minggu'];

String hariFromWeekday(int weekday) => kHariUrutan[weekday - 1];

int weekdayFromHari(String hari) => kHariUrutan.indexOf(hari) + 1;

/// 1 block yang tampil di Weekly Grid untuk 1 minggu spesifik ([weekStart]).
/// Untuk block recurring, [weekday] berasal dari field `hari` (tampil tiap
/// minggu selama aktif). Untuk block ad-hoc, [weekday] dihitung dari
/// `tanggal_spesifik` — cuma tampil kalau tanggal itu jatuh di minggu yang
/// sedang dilihat.
class TimeboxBlockOccurrence {
  const TimeboxBlockOccurrence({required this.data, required this.weekday});

  final TimeboxScheduleData data;
  final int weekday; // 1 = Senin .. 7 = Minggu

  (int, int) get startMinutes => _parseHm(data.startTime);
  (int, int) get endMinutes => _parseHm(data.endTime);

  static (int, int) _parseHm(String hm) {
    final parts = hm.split(':');
    return (int.parse(parts[0]), int.parse(parts[1]));
  }
}

/// Layer di antara UI dan [TimeboxDao] — nampung business rule (proyeksi
/// blok ke 1 minggu spesifik, cek bentrok, duplikasi ke hari lain).
class TimeboxRepository {
  TimeboxRepository(this._dao);

  final TimeboxDao _dao;

  Stream<List<TimeboxScheduleData>> watchAll() => _dao.watchAll();

  /// FR-3.3 — proyeksi semua block (template mingguan + ad-hoc) yang tampil
  /// pada minggu yang diawali [weekStart] (harus tanggal hari Senin).
  Stream<List<TimeboxBlockOccurrence>> watchForWeek(DateTime weekStart) {
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final end = start.add(const Duration(days: 7));

    return _dao.watchAll().map((all) {
      final result = <TimeboxBlockOccurrence>[];
      for (final b in all) {
        if (b.isRecurring) {
          if (!b.isActive || b.hari == null) continue;
          result.add(TimeboxBlockOccurrence(data: b, weekday: weekdayFromHari(b.hari!)));
        } else if (b.tanggalSpesifik != null) {
          final d = b.tanggalSpesifik!;
          final dOnly = DateTime(d.year, d.month, d.day);
          if (!dOnly.isBefore(start) && dOnly.isBefore(end)) {
            result.add(TimeboxBlockOccurrence(data: b, weekday: dOnly.weekday));
          }
        }
      }
      return result;
    });
  }

  /// FR-3.9 — cek bentrok jadwal terhadap block lain yang tampil di hari
  /// (weekday) yang sama pada minggu yang sama.
  Future<List<TimeboxScheduleData>> checkBentrok({
    required DateTime weekStart,
    required int weekday,
    required String startTime,
    required String endTime,
    String? excludeId,
  }) async {
    final occurrences = await watchForWeek(weekStart).first;
    final startMin = _toMinutes(startTime);
    final endMin = _toMinutes(endTime);

    return occurrences
        .where((o) => o.weekday == weekday && o.data.id != excludeId)
        .where((o) {
          final oStart = _toMinutes(o.data.startTime);
          final oEnd = _toMinutes(o.data.endTime);
          return oStart < endMin && oEnd > startMin;
        })
        .map((o) => o.data)
        .toList();
  }

  Future<String> createBlock({
    String? tugasId,
    String? habitId,
    required String judul,
    required String kategori,
    required String startTime,
    required String endTime,
    required bool isRecurring,
    String? hari,
    DateTime? tanggalSpesifik,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _dao.insertBlock(TimeboxScheduleCompanion.insert(
      id: id,
      userId: kLocalUserId,
      judul: judul,
      kategori: kategori,
      startTime: startTime,
      endTime: endTime,
      isRecurring: isRecurring,
      tugasId: Value(tugasId),
      habitId: Value(habitId),
      hari: Value(hari),
      tanggalSpesifik: Value(tanggalSpesifik),
      createdAt: now,
      updatedAt: now,
    ));
    return id;
  }

  Future<void> updateBlock(
    String id, {
    Object? tugasId = _unset,
    Object? habitId = _unset,
    String? judul,
    String? kategori,
    String? startTime,
    String? endTime,
    bool? isRecurring,
    Object? hari = _unset,
    Object? tanggalSpesifik = _unset,
  }) {
    return _dao.updateBlock(
      id,
      TimeboxScheduleCompanion(
        tugasId: identical(tugasId, _unset) ? const Value.absent() : Value(tugasId as String?),
        habitId: identical(habitId, _unset) ? const Value.absent() : Value(habitId as String?),
        judul: judul == null ? const Value.absent() : Value(judul),
        kategori: kategori == null ? const Value.absent() : Value(kategori),
        startTime: startTime == null ? const Value.absent() : Value(startTime),
        endTime: endTime == null ? const Value.absent() : Value(endTime),
        isRecurring: isRecurring == null ? const Value.absent() : Value(isRecurring),
        hari: identical(hari, _unset) ? const Value.absent() : Value(hari as String?),
        tanggalSpesifik: identical(tanggalSpesifik, _unset)
            ? const Value.absent()
            : Value(tanggalSpesifik as DateTime?),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// FR-3.12 — nonaktifkan sementara 1 slot template tanpa hapus permanen.
  Future<void> toggleActive(String id, bool isActive) => _dao.updateBlock(
        id,
        TimeboxScheduleCompanion(isActive: Value(isActive), updatedAt: Value(DateTime.now())),
      );

  /// FR-3.11 — duplikasi 1 block template ke hari lain (salinan baru,
  /// independen dari block asal).
  Future<String> duplicateToDay(String id, String targetHari) async {
    final source = await _dao.getById(id);
    if (source == null) throw StateError('Block tidak ditemukan');
    return createBlock(
      tugasId: source.tugasId,
      habitId: source.habitId,
      judul: source.judul,
      kategori: source.kategori,
      startTime: source.startTime,
      endTime: source.endTime,
      isRecurring: source.isRecurring,
      hari: targetHari,
    );
  }

  Future<void> deleteBlock(String id) => _dao.softDelete(id);

  int _toMinutes(String hm) {
    final parts = hm.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}

const _unset = Object();
