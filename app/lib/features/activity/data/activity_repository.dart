import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/database/daos/activity_dao.dart';
import '../../../core/database/database.dart';

const _uuid = Uuid();

class CompletionRate {
  const CompletionRate({required this.completed, required this.total});

  final int completed;
  final int total;

  double get rate => total == 0 ? 0 : completed / total;
}

/// 1 baris yang ditampilkan di Today View untuk 1 tanggal tertentu.
///
/// Kalau [isVirtual] true, [data] bukan row asli di database — ia hasil
/// proyeksi dari recurring template (row yang [data.isRecurring] true) ke
/// tanggal target ([occurrenceDate]), dibuat on-the-fly tiap kali di-query,
/// TIDAK disimpan. Begitu status/edit disentuh, baru dimaterialize jadi row
/// baru yang independen (lihat [ActivityRepository.materializeOccurrence]) —
/// mirip pola "exception" pada recurring event di Google Calendar.
class ActivityOccurrence {
  const ActivityOccurrence({required this.data, required this.occurrenceDate, required this.isVirtual});

  final ActivityData data;
  final DateTime occurrenceDate;
  final bool isVirtual;

  /// Untuk occurrence virtual, ini id dari recurring template asalnya.
  String get templateId => data.id;

  /// Key unik per kemunculan (bukan cuma per template) — dipakai untuk
  /// menandai occurrence mana saja yang bentrok jadwalnya di 1 hari yang
  /// sama tanpa keliru menyamakan 2 kemunculan berbeda dari 1 template.
  String get occurrenceKey => '$templateId-${occurrenceDate.toIso8601String()}';
}

/// FR-1.8 — hitung set [ActivityOccurrence.occurrenceKey] yang jadwalnya
/// bentrok dengan occurrence lain di [occurrences] (dipakai untuk banner
/// konflik & highlight kartu di Today View, bukan cuma validasi form).
Set<String> overlappingOccurrenceKeys(List<ActivityOccurrence> occurrences) {
  final timed = occurrences
      .where((o) => !o.data.isAllDay && o.data.startTime != null && o.data.endTime != null)
      .toList();
  final result = <String>{};
  for (var i = 0; i < timed.length; i++) {
    for (var j = i + 1; j < timed.length; j++) {
      final a = timed[i];
      final b = timed[j];
      if (a.data.startTime!.isBefore(b.data.endTime!) && b.data.startTime!.isBefore(a.data.endTime!)) {
        result.add(a.occurrenceKey);
        result.add(b.occurrenceKey);
      }
    }
  }
  return result;
}

/// Layer di antara UI dan [ActivityDao] — nampung business rule yang bukan
/// query mentah (overlap check, completion rate, generate id/timestamp).
class ActivityRepository {
  ActivityRepository(this._dao);

  final ActivityDao _dao;

  Future<ActivityData?> getById(String id) => _dao.getById(id);

  /// Today View — gabungan activity asli di tanggal [date] + proyeksi
  /// kemunculan recurring activity yang jatuh di hari itu (FR-1.4).
  Stream<List<ActivityOccurrence>> watchOccurrencesForDate(DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);

    return _dao.watchAll().map((all) {
      final result = <ActivityOccurrence>[];

      for (final a in all) {
        // Recurring activity: `recurring_days` adalah satu-satunya acuan
        // hari tampil — tanggal awal input TIDAK otomatis jadi hari
        // kemunculan kalau hari itu bukan salah satu yang dipilih user.
        if (a.isRecurring && a.recurringDays != null && a.startTime != null) {
          final days = _decodeDays(a.recurringDays!);
          if (!days.contains(date.weekday)) continue;

          final templateStartDate = _dateOnly(a.startTime!);
          if (dayStart.isBefore(templateStartDate)) continue;
          if (a.recurringEndDate != null && dayStart.isAfter(_dateOnly(a.recurringEndDate!))) continue;

          if (_isSameDate(a.startTime!, dayStart)) {
            result.add(ActivityOccurrence(data: a, occurrenceDate: dayStart, isVirtual: false));
          } else {
            final occStart = DateTime(date.year, date.month, date.day, a.startTime!.hour, a.startTime!.minute);
            final occEnd = a.endTime == null ? null : occStart.add(a.endTime!.difference(a.startTime!));
            result.add(ActivityOccurrence(
              data: a.copyWith(startTime: Value(occStart), endTime: Value(occEnd)),
              occurrenceDate: dayStart,
              isVirtual: true,
            ));
          }
          continue;
        }

        final isOwnDay = a.startTime != null && _isSameDate(a.startTime!, dayStart);
        if (isOwnDay) {
          result.add(ActivityOccurrence(data: a, occurrenceDate: dayStart, isVirtual: false));
        }
      }

      result.sort((x, y) => (x.data.startTime ?? dayStart).compareTo(y.data.startTime ?? dayStart));
      return result;
    });
  }

  /// Ubah 1 kemunculan recurring activity jadi row asli (independen dari
  /// template), supaya perubahan status/edit hari itu saja tidak
  /// memengaruhi hari-hari lain. Dipanggil otomatis saat occurrence virtual
  /// disentuh (lihat UI).
  Future<String> materializeOccurrence(ActivityOccurrence occurrence, {String? status}) {
    final t = occurrence.data;
    return createActivity(
      judul: t.judul,
      kategori: t.kategori,
      startTime: t.startTime,
      endTime: t.endTime,
      catatan: t.catatan,
      source: 'manual',
      sourceId: occurrence.templateId,
    ).then((id) async {
      if (status != null) await updateStatus(id, status);
      return id;
    });
  }

  /// FR-1.8 — dipanggil sebelum simpan untuk kasih warning non-blocking.
  /// Dicek terhadap occurrence yang benar-benar tampil di [date] (termasuk
  /// proyeksi recurring), bukan `start_time` mentah di database — kalau
  /// tidak, recurring activity akan "bentrok" di hari manapun walau
  /// harusnya cuma tampil di hari yang dipilih.
  Future<List<ActivityData>> checkOverlap({
    required DateTime date,
    required DateTime start,
    required DateTime end,
    String? excludeId,
  }) async {
    final occurrences = await watchOccurrencesForDate(date).first;
    return occurrences
        .where((o) => o.templateId != excludeId)
        .where((o) => !o.data.isAllDay && o.data.startTime != null && o.data.endTime != null)
        .where((o) => o.data.startTime!.isBefore(end) && o.data.endTime!.isAfter(start))
        .map((o) => o.data)
        .toList();
  }

  Future<String> createActivity({
    required String judul,
    required String kategori,
    DateTime? startTime,
    DateTime? endTime,
    bool isAllDay = false,
    bool isRecurring = false,
    List<int>? recurringDays,
    DateTime? recurringEndDate,
    String source = 'manual',
    String? sourceId,
    String? catatan,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _dao.insertActivity(ActivityCompanion.insert(
      id: id,
      userId: kLocalUserId,
      judul: judul,
      kategori: kategori,
      status: 'belum_mulai',
      startTime: Value(startTime),
      endTime: Value(endTime),
      isAllDay: Value(isAllDay),
      isRecurring: Value(isRecurring),
      recurringDays: Value(recurringDays == null ? null : _encodeDays(recurringDays)),
      recurringEndDate: Value(recurringEndDate),
      source: Value(source),
      sourceId: Value(sourceId),
      catatan: Value(catatan),
      createdAt: now,
      updatedAt: now,
    ));
    return id;
  }

  Future<void> updateActivity(
    String id, {
    String? judul,
    String? kategori,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAllDay,
    String? status,
    bool? isRecurring,
    List<int>? recurringDays,
    DateTime? recurringEndDate,
    String? catatan,
  }) {
    return _dao.updateActivity(
      id,
      ActivityCompanion(
        judul: judul == null ? const Value.absent() : Value(judul),
        kategori: kategori == null ? const Value.absent() : Value(kategori),
        startTime: startTime == null ? const Value.absent() : Value(startTime),
        endTime: endTime == null ? const Value.absent() : Value(endTime),
        isAllDay: isAllDay == null ? const Value.absent() : Value(isAllDay),
        status: status == null ? const Value.absent() : Value(status),
        isRecurring: isRecurring == null ? const Value.absent() : Value(isRecurring),
        recurringDays: recurringDays == null ? const Value.absent() : Value(_encodeDays(recurringDays)),
        recurringEndDate: recurringEndDate == null ? const Value.absent() : Value(recurringEndDate),
        catatan: catatan == null ? const Value.absent() : Value(catatan),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateStatus(String id, String status) =>
      _dao.updateActivity(id, ActivityCompanion(status: Value(status), updatedAt: Value(DateTime.now())));

  Future<void> deleteActivity(String id) => _dao.softDelete(id);

  Future<int> bulkComplete(DateTime date) => _dao.bulkComplete(date);

  Future<void> bulkReschedule(DateTime fromDate, DateTime toDate) => _dao.bulkReschedule(fromDate, toDate);

  /// FR-1.13 — persentase selesai vs direncanakan pada 1 hari, termasuk
  /// kemunculan recurring activity (occurrence virtual dihitung belum
  /// selesai, karena statusnya memang belum ada sampai disentuh).
  Future<CompletionRate> completionRateForDate(DateTime date) {
    return watchOccurrencesForDate(date).first.then((occurrences) {
      final completed = occurrences.where((o) => o.data.status == 'selesai').length;
      return CompletionRate(completed: completed, total: occurrences.length);
    });
  }

  String _encodeDays(List<int> days) => '[${days.join(',')}]';

  List<int> _decodeDays(String encoded) => encoded
      .replaceAll(RegExp(r'[\[\]\s]'), '')
      .split(',')
      .where((s) => s.isNotEmpty)
      .map(int.parse)
      .toList();

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isSameDate(DateTime a, DateTime b) => _dateOnly(a) == _dateOnly(b);
}
