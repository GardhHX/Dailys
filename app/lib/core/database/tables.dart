import 'package:drift/drift.dart';

/// Kolom konvensi global (schema.md): id, created_at, updated_at,
/// is_deleted, deleted_at — dipakai di semua tabel via mixin ini.
mixin SyncColumns on Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  BoolColumn get isDeleted =>
      boolean().named('is_deleted').withDefault(const Constant(false))();
  DateTimeColumn get deletedAt =>
      dateTime().named('deleted_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// `user_id` dipisah dari [SyncColumns] karena 2 tabel anak (TugasChecklist,
/// HabitLog) sengaja tidak punya `user_id` sendiri — ownership ikut parent
/// (lihat catatan di schema.md).
mixin UserOwned on Table {
  TextColumn get userId => text().named('user_id')();
}

class MataKuliah extends Table with SyncColumns, UserOwned {
  TextColumn get nama => text()();
  TextColumn get dosen => text().nullable()();
  IntColumn get sks => integer().nullable()();
  TextColumn get semester => text().nullable()();
  TextColumn get warna => text()();
}

class Tugas extends Table with SyncColumns, UserOwned {
  TextColumn get mataKuliahId => text().named('mata_kuliah_id').nullable()();
  TextColumn get judul => text()();
  TextColumn get deskripsi => text().nullable()();
  DateTimeColumn get deadline => dateTime()();
  TextColumn get prioritas => text()();
  IntColumn get estimasiMenit => integer().named('estimasi_menit').nullable()();
  TextColumn get status => text()();
  TextColumn get reminderOffsets =>
      text().named('reminder_offsets').withDefault(const Constant('[7,3,1,0]'))();
}

class TugasChecklist extends Table with SyncColumns {
  TextColumn get tugasId => text().named('tugas_id')();
  TextColumn get judul => text()();
  BoolColumn get isDone =>
      boolean().named('is_done').withDefault(const Constant(false))();
  IntColumn get urutan => integer()();
}

class Activity extends Table with SyncColumns, UserOwned {
  TextColumn get judul => text()();
  TextColumn get kategori => text()();
  DateTimeColumn get startTime => dateTime().named('start_time').nullable()();
  DateTimeColumn get endTime => dateTime().named('end_time').nullable()();
  BoolColumn get isAllDay =>
      boolean().named('is_all_day').withDefault(const Constant(false))();
  TextColumn get status => text()();
  BoolColumn get isRecurring =>
      boolean().named('is_recurring').withDefault(const Constant(false))();
  TextColumn get recurringDays => text().named('recurring_days').nullable()();
  DateTimeColumn get recurringEndDate =>
      dateTime().named('recurring_end_date').nullable()();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  TextColumn get sourceId => text().named('source_id').nullable()();
  TextColumn get catatan => text().nullable()();
}

class PomodoroSession extends Table with SyncColumns, UserOwned {
  TextColumn get tugasId => text().named('tugas_id').nullable()();
  TextColumn get habitId => text().named('habit_id').nullable()();
  DateTimeColumn get startTime => dateTime().named('start_time')();
  DateTimeColumn get endTime => dateTime().named('end_time').nullable()();
  IntColumn get durasiMenit => integer().named('durasi_menit')();
  TextColumn get jenis => text()();
  TextColumn get status => text()();
}

class TimeboxSchedule extends Table with SyncColumns, UserOwned {
  TextColumn get tugasId => text().named('tugas_id').nullable()();
  TextColumn get habitId => text().named('habit_id').nullable()();
  TextColumn get judul => text()();
  TextColumn get kategori => text()();
  // Disimpan sebagai "HH:mm" karena Drift/SQLite tidak punya tipe TIME native.
  TextColumn get startTime => text().named('start_time')();
  TextColumn get endTime => text().named('end_time')();
  TextColumn get hari => text().nullable()();
  DateTimeColumn get tanggalSpesifik =>
      dateTime().named('tanggal_spesifik').nullable()();
  BoolColumn get isRecurring => boolean().named('is_recurring')();
  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();
}

class Habit extends Table with SyncColumns, UserOwned {
  TextColumn get nama => text()();
  TextColumn get targetHari => text().named('target_hari')();
  TextColumn get warna => text()();
  TextColumn get icon => text().nullable()();
  IntColumn get longestStreak =>
      integer().named('longest_streak').withDefault(const Constant(0))();
  IntColumn get maxIzinPerPeriode =>
      integer().named('max_izin_per_periode').withDefault(const Constant(1))();
  BoolColumn get isArchived =>
      boolean().named('is_archived').withDefault(const Constant(false))();
  IntColumn get urutan => integer()();
}

class HabitLog extends Table with SyncColumns {
  TextColumn get habitId => text().named('habit_id')();
  DateTimeColumn get tanggal => dateTime()();
  TextColumn get status => text()();
  TextColumn get catatan => text().nullable()();
}

class Akun extends Table with SyncColumns, UserOwned {
  TextColumn get nama => text()();
  TextColumn get tipe => text()();
  // Integer (Rupiah utuh, tanpa sen) — bukan real(), supaya tidak ada
  // rounding error float yang terakumulasi di saldo (FR-4.6).
  IntColumn get saldo => integer().withDefault(const Constant(0))();
}

class CategoryKeuangan extends Table with SyncColumns, UserOwned {
  TextColumn get nama => text()();
  TextColumn get tipe => text()();
  TextColumn get icon => text().nullable()();
}

class Transaksi extends Table with SyncColumns, UserOwned {
  TextColumn get akunId => text().named('akun_id')();
  TextColumn get akunTujuanId => text().named('akun_tujuan_id').nullable()();
  TextColumn get categoryId => text().named('category_id').nullable()();
  IntColumn get jumlah => integer()();
  TextColumn get tipe => text()();
  DateTimeColumn get tanggal => dateTime()();
  TextColumn get catatan => text().nullable()();
}
