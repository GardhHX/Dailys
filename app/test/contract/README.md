# contract tests

Test yang mengunci nilai normatif lintas-platform. Nilai diambil persis dari
kontrak dan wajib identik dengan implementasi Node.js di kemudian hari.

Aktif untuk M1:

- `uuid_v5_test` - golden vector schema "Deterministic IDs" (termasuk contoh
  `habit-log ... 2026-09-03 -> d4eef7e7-655b-5e0d-9157-89f85d2b78de`) dan
  kanonikalisasi name occurrence recurring Activity.
- `dst_resolution_test` - schema 23.1: `America/New_York` 2026, clamp maju DST
  (`2026-03-08` 02:30 -> `2026-03-08T07:00:00Z`) dan ambigu mundur DST
  (`2026-11-01` 01:30 -> `2026-11-01T05:30:00Z`, kemunculan pertama EDT).
- `completion_rate_test` dan `overlap_test` - fixture schema 14.1.

Disimpan sebagai skip berlabel milestone (jangan hapus):

- `timezone_recompute_test` (schema 23.2) - aktifkan saat statistik/bucket hadir.
- `streak_test` (schema 11.3) - Habit, M4.
- `ledger_test` (schema 14.1) - Keuangan, M4.
- `conflict_roundtrip_test` (schema 23.3) - sync, M2.
