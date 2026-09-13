# contract tests

Test yang mengunci nilai normatif lintas-platform. Nilai diambil persis dari
kontrak dan wajib identik dengan implementasi Node.js kelak.

Aktif untuk M1:

- `uuid_v5_test` - golden vector schema "Deterministic IDs" (termasuk contoh
  `habit-log ... 2026-09-03 -> d4eef7e7-655b-5e0d-9157-89f85d2b78de`) dan
  kanonikalisasi name occurrence recurring Activity.
- `activity_category_seed_test` - enam seed UUIDv5 deterministik per user
  (schema 6).
- `dst_resolution_test` - schema 23.1: `America/New_York` 2026, clamp maju DST
  (`2026-03-08` 02:30 -> `2026-03-08T07:00:00Z`) dan ambigu mundur DST
  (`2026-11-01` 01:30 -> `2026-11-01T05:30:00Z`, kemunculan pertama EDT).
- `timezone_recompute_test` - schema 23.2 (fixture Asia/Jakarta ->
  America/Los_Angeles pada Instant `2026-06-15T02:00:00Z`): batas "hari ini"
  direkomputasi dari timezone yang berlaku, sementara `occurrence_date` dan
  Instant yang sudah dimaterialisasi tidak ditulis ulang. Proyeksi statistik
  Pomodoro (M3) dan streak (M4) di luar cakupan test ini.
- `completion_rate_test` dan `overlap_test` - fixture schema 14.1.

Disimpan sebagai skip berlabel milestone (jangan hapus):

- `streak_test` (schema 11.3) - golden table lengkap sudah disalin; aktifkan
  begitu Habit/HabitSchedule/HabitLog ada (M4).
- `ledger_test` (schema 14.1) - formula saldo/agregasi sudah dikutip; belum
  ada contoh angka resmi di kontrak, tambahkan bersama fixture M4 nanti.
- `conflict_roundtrip_test` (schema 23.3) - round-trip tiga langkah lengkap
  sudah disalin; aktifkan begitu Sync/SyncChange ada (M2).
