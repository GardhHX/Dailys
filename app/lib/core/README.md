# core

Modul lintas-fitur yang menegakkan kontrak. Tidak boleh bergantung pada `features/`.

- `time/` - Instant (UTC) vs Local date, sumber monotonic, dan konversi
  Local<->Instant dengan **DST clamp eksplisit** (schema Section 2 dan 23.1). Jangan
  memakai default resolver tz (umumnya geser-sepanjang-gap); pakai clamp ke instant
  valid pertama setelah gap, dan kemunculan pertama untuk waktu ambigu.
- `ids/` - UUIDv4 (offline) dan UUIDv5 deterministik dengan namespace URL standar
  serta canonical name (schema "Deterministic IDs"). Golden vector jadi contract test.
- `db/` - AppDatabase Drift, tabel M1 (global columns mixin), DAO, dan migration v1
  dengan integrity check plus backup-sebelum-migration (OPERATIONS Section 3).
- `recurrence/` - rolling materializer occurrence (schema Section 2, rumus horizon).
- `projections/` - completion rate dan overlap (schema 14.1), wajib cocok fixture.
- `di/` - registrasi get_it.

Aturan sync (outbox/journal) sengaja tidak ada di M1; boundary repository disiapkan
agar M2 menambahkannya di sini tanpa menyentuh UI.
