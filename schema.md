# Dailys Database Schema

**Versi:** 1.0 target contract  
**Status implementasi:** belum diimplementasikan; schema awal dan migration belum dibuat  
**Terakhir diperbarui:** 6 September 2026  
**Terkait:** `README.md`, `PRD-Aplikasi-Produktivitas-Mahasiswa.md`, `API-SPEC.md`, `openapi.yaml`, `ERD.md`, `OPERATIONS.md`

Dokumen ini mendefinisikan model data logis target v1.0. Belum ada implementasi
Prisma atau Drift. Database baru mengikuti schema awal; bagian 22 membedakan
inialisasi baru dan migrasi legacy bersyarat.

Schema terdiri dari 32 entity/table v1.0 serta 2 entity future scope. Entity baru dalam kontrak v1.0:
`ActivityCategory`, `ActivityRecurrence`, `TimeboxExecution`, `CourseNote`, `SyncDevice`,
`ProcessedChange`, `SyncChange`, `SyncSnapshot`, `SyncSnapshotItem`,
`HabitSchedule`, `UserSettings`, `DeviceSettings`, `SyncOutbox`,
`SyncConflictNotice`, `SyncSnapshotStaging`, `SyncRecoveryQueue`, `SyncEntityBase`,
`SyncMutationJournal`, `WeeklyReview`, dan `WeeklyPlanDraft`.

---

## 1. Physical Type Mapping

| Logical type | Drift / SQLite | Prisma / PostgreSQL | Wire format |
|---|---|---|---|
| UUID | `TEXT` | `UUID` | UUID string |
| Instant | integer-backed `DateTime` | `TIMESTAMPTZ` | RFC 3339 UTC |
| Local date | normalized `DateTime` | `DATE` | `YYYY-MM-DD` |
| Local time | `TEXT` | `TIME` | `HH:mm:ss` |
| Money | `INTEGER` | `BIGINT` | integer Rupiah |
| JSON array | JSON text | `JSONB` | JSON array |

Server dan client menyimpan nominal sebagai integer Rupiah. Keduanya tidak
memakai floating point atau `Decimal` untuk nominal v1.0.

---

## 2. Global Columns

Semua entity yang ikut sync memiliki kolom berikut:

| Field | Type | Constraint / purpose |
|---|---|---|
| `id` | UUID | Primary key; client dapat membuat UUID saat offline. |
| `created_at` | Instant | Waktu pembuatan dari device asal. |
| `updated_at` | Instant | Waktu mutasi dari device asal; metadata audit, bukan cursor pull. |
| `is_deleted` | BOOLEAN | Default `false`; delete memakai tombstone. |
| `deleted_at` | Instant nullable | Wajib terisi saat `is_deleted=true`. |
| `origin_device_id` | UUID nullable | Device yang membuat mutasi terakhir. |
| `server_revision` | BIGINT nullable | Revision yang server berikan setelah menerima mutasi. |

Top-level entity milik user memiliki `user_id`. `TugasChecklist`, `CourseNote`,
`HabitSchedule`, `HabitLog`, `TimeboxExecution`, dan `WeeklyPlanDraft` mewarisi ownership dari
parent dan tidak menyimpan `user_id` kedua. Query child wajib join atau
memvalidasi parent.

Representasi wire REST dan sync selalu berisi field domain yang tercantum pada
entity ditambah `id`, `created_at`, `updated_at`, `is_deleted`, `deleted_at`, dan
`server_revision`. `user_id` dan `origin_device_id` adalah metadata persistence
dan tidak dikirim ke client. OpenAPI mendefinisikan bentuk wire penuh per entity;
response atau payload bebas (`additionalProperties: true`) tidak diperbolehkan.

Timestamp domain seperti `completed_at`, `archived_at`, waktu aksi Pomodoro, dan
actual time Timebox merekam waktu tindakan user. REST memakai waktu server jika
command tidak membawa timestamp; aksi offline memakai waktu device dan membawa
nilai yang sama pada typed sync payload. Server menolak timestamp aksi lebih dari
lima menit di masa depan, tetapi tidak menolak nilai lama hanya karena device
lama offline. Timestamp tersebut tidak menentukan pemenang conflict. Merge mengikuti bagian
18.1; commit server dan `server_revision` memberi urutan kanonik dalam satu generation.

### Global invariants

- Server menyimpan instant dalam UTC. API tidak memakai timezone lokal VPS.
- Mutation mengubah `updated_at`, termasuk soft delete dan perubahan urutan.
- `deleted_at` bernilai null saat row aktif.
- Server mengalokasikan `server_revision`; client tidak boleh mengarang nilainya.
- Pull memakai opaque cursor dari `SyncChange`, bukan `updated_at` client. Semua revision/cursor terikat sync_generation; revision tidak dibandingkan lintas generation.
- FK lintas user ditolak meskipun aplikasi v1.0 hanya memiliki satu user.
- Update stale terhadap tombstone ditolak. Restore hanya sah sebagai operasi eksplisit
  dengan `base_server_revision` yang sama dengan revision tombstone terbaru.
- Create/restore child ditolak jika parent menjadi tombstone. Child yang ikut
  cascade tidak dapat di-update. Pengecualian tunggal: TimeboxExecution `pending`
  yang dipertahankan setelah schedule dihapus boleh ditransisikan ke `completed`
  `missed`, atau `skipped`, tetapi tidak boleh di-reschedule.

### Lifecycle delete dan restore

Soft delete tidak boleh menyerahkan perilaku FK kepada default database. Service
menjalankan kebijakan berikut dalam satu transaction dan menulis satu
`SyncChange` untuk setiap row yang berubah. Untuk cascade, child ditombstone lebih
dahulu dan parent terakhir agar urutan revision aman diterapkan client.

| Resource yang dihapus | Dependensi aktif | Kebijakan v1.0 |
|---|---|---|
| `MataKuliah` | `CourseNote` | Cascade tombstone ke seluruh CourseNote. |
| `MataKuliah` | `Tugas` | Detach dengan `Tugas.mata_kuliah_id=null`; tugas dan historinya dipertahankan. |
| `Tugas` | `TugasChecklist` | Cascade tombstone ke checklist. |
| `Tugas` | `PomodoroSession`, `TimeboxSchedule` | Pertahankan histori; FK boleh tetap menunjuk tombstone. Session/schedule baru tidak boleh memakai tugas tersebut. |
| `ActivityRecurrence` | `Activity` | Stop materialisasi baru; occurrence yang sudah ada dipertahankan. |
| `TimeboxSchedule` | `TimeboxExecution` | Stop materialisasi baru; execution lama dipertahankan. |
| `Habit` | `HabitSchedule`, `HabitLog` | Cascade tombstone. UI harus menawarkan archive sebelum delete karena delete mengeluarkan habit dari perhitungan aktif. Derived Activity lama dipertahankan. |
| `ActivityCategory` | Activity/recurrence/Timebox aktif atau histori | Gunakan archive; delete ditolak selama masih direferensikan. |
| `Akun` | `Transaksi` aktif atau tombstone yang masih diretain | Gunakan archive; delete hanya diizinkan jika belum pernah dipakai ledger. |
| `CategoryKeuangan` | `Transaksi` aktif atau tombstone yang masih diretain | Gunakan archive; delete hanya diizinkan jika belum pernah dipakai ledger. |
| `UserSettings` | Singleton konfigurasi user | Delete/restore tidak didukung; hanya full upsert melalui sync atau partial update melalui REST. |
| `WeeklyReview` | `WeeklyPlanDraft` | Review tidak dapat dihapus. Draft boleh dihapus sebelum promoted; promoted/discarded dipertahankan sebagai histori. |

Restore hanya tersedia melalui sync `operation=restore`, wajib membawa
`base_server_revision` tombstone terbaru, dan tidak menjalankan cascade otomatis.
Parent harus direstore sebelum child. Detach pada Tugas tidak dibalik saat
MataKuliah direstore. Restore entity yang natural key-nya telah dipakai entity
aktif lain ditolak `409 CONFLICT`. REST v1.0 tidak menyediakan fitur undo-delete;
client hanya membuat operasi restore selama undo lokal belum disinkronkan atau
melalui recovery tooling yang memakai protokol sync yang sama.

### Deterministic IDs

Resource biasa memakai UUIDv4 yang dibuat client saat offline. Entity yang mewakili
kejadian logis tunggal memakai UUIDv5 agar dua device menghasilkan ID yang sama.
Namespace UUID adalah UUID namespace URL standar
`6ba7b811-9dad-11d1-80b4-00c04fd430c8`, dengan canonical name berikut:

| Entity | Canonical name |
|---|---|
| Seed `ActivityCategory` | `urn:dailys:v1.0:activity-category:{user_id}:{slug}` |
| Seed `CategoryKeuangan` | `urn:dailys:v1.0:finance-category:{user_id}:{tipe}:{slug}` |
| `HabitLog` | `urn:dailys:v1.0:habit-log:{habit_id}:{YYYY-MM-DD}` |
| `TimeboxExecution` | `urn:dailys:v1.0:timebox-execution:{schedule_id}:{planned_start_at_utc}` |
| `HabitSchedule` | `urn:dailys:v1.0:habit-schedule:{habit_id}:{effective_from}` |
| `UserSettings` | `urn:dailys:v1.0:user-settings:{user_id}` |
| Recurring `Activity` | `urn:dailys:v1.0:activity-occurrence:{recurrence_id}:{YYYY-MM-DD}` |
| Derived `Activity` | `urn:dailys:v1.0:derived-activity:{source}:{source_id}` |
| `WeeklyReview` | `urn:dailys:v1.0:weekly-review:{user_id}:{week_start}` |
| Target hasil `WeeklyPlanDraft` | `urn:dailys:v1.0:weekly-plan-promotion:{draft_id}:{target_type}` |

UUID input selalu lowercase canonical. Natural unique constraint tetap wajib sebagai
pertahanan tambahan terhadap client yang tidak mengikuti algoritma ini.
`planned_start_at_utc` dinormalisasi ke UTC RFC 3339 presisi detik
(`YYYY-MM-DDTHH:mm:ssZ`) tanpa fractional seconds.

Golden vector lintas-platform:

```text
name: urn:dailys:v1.0:habit-log:00000000-0000-0000-0000-000000000001:2026-09-03
uuid: d4eef7e7-655b-5e0d-9157-89f85d2b78de
```

Implementasi Dart dan Node.js wajib menghasilkan UUID tersebut sebelum sync
diaktifkan.

### Materialisasi occurrence dan reminder

`ActivityRecurrence` dan `TimeboxSchedule` memakai rolling materialization
window yang sama. Pada app start, setelah pull berhasil, setelah template
dibuat/diubah, dan sekali sehari sesudah pukul 00.00 timezone user, local service
memastikan occurrence tersedia untuk rentang inklusif `today ... horizon_end`.
Server menjalankan pekerjaan ekuivalen sebagai rekonsiliasi, bukan sebagai
sumber ID berbeda.

`horizon_end = today + max(30, ceil(max_reminder_offset_minutes / 1440) + 1)`
hari. Jika array reminder kosong, horizon tetap 30 hari. Untuk setiap tanggal
yang cocok dengan template, service melakukan upsert idempotent memakai UUIDv5
dan natural key. Instant lokal yang tidak ada karena DST digeser ke instant valid
pertama setelah gap; waktu ambigu memilih offset yang lebih awal. Keputusan ini
harus identik di Dart dan Node.js; golden vector ada di bagian 23.1.

Occurrence dan execution yang sudah dimaterialisasi adalah snapshot immutable
dari waktu, judul/kategori, dan reminder template. Edit template hanya memengaruhi
tanggal setelah `materialized_through_date`; API mengembalikan tanggal tersebut
agar UI dapat menjelaskan kapan perubahan mulai berlaku. Delete atau pause
template membatalkan notifikasi yang belum terkirim dan menghentikan pembuatan
baru, tetapi tidak menghapus histori. Reminder dengan waktu trigger yang sudah
lewat tidak ditembakkan ulang; client menandainya `expired` secara lokal.

---

## 3. User

Auth v1.0 memakai bearer API key. User tidak menyimpan password.

| Field | Type | Constraint |
|---|---|---|
| `id` | UUID | PK |
| `nama` | TEXT | Non-empty |
| `email` | TEXT nullable | Unique jika terisi |
| `api_key_hash` | TEXT | Hash API key; server tidak menyimpan secret mentah. |
| *(global columns tanpa `origin_device_id`)* | | |

### 3.1 UserSettings (synced)

Tepat satu row per user menyimpan preferensi yang harus konsisten lintas device.
ID adalah UUIDv5 dari `urn:dailys:v1.0:user-settings:{user_id}`.

| Field | Type | Constraint |
|---|---|---|
| `id` | UUID | PK; deterministic UUIDv5 |
| `user_id` | UUID | FK → User.id; unique |
| `language` | ENUM | `id`, `en`; default `id` |
| `timezone` | TEXT | IANA timezone; default `Asia/Jakarta` |
| `pomodoro_focus_minutes` | INTEGER | Default 25; 1..180 |
| `pomodoro_short_break_minutes` | INTEGER | Default 5; 1..60 |
| `pomodoro_long_break_minutes` | INTEGER | Default 15; 1..120 |
| `pomodoro_long_break_interval` | INTEGER | Default 4; 2..12 focus sessions |
| `alarm_mode` | ENUM | `sound`, `muted`; default `sound` |
| `notifications_enabled` | BOOLEAN | Default `true`; preference, bukan izin OS |
| `weekly_review_time` | Local time | Default `09:00:00`; hari tetap Minggu pada v1.0 |
| *(global columns)* | | |

Row dibuat saat provisioning user dan tidak dapat dihapus. Sync hanya menerima
full upsert `user_settings`; REST `PUT /settings` bersifat partial tetapi service
menyimpan dan mengembalikan row penuh.

Semua batas hari, recurrence, statistik, reminder, dan streak memakai
`UserSettings.timezone`. Update timezone tidak menulis ulang Local date yang
tersimpan (`tanggal`, `occurrence_date`, `effective_from/to`, dan deadline) atau
Instant apa pun. Activity occurrence dan TimeboxExecution yang sudah
dimaterialisasi tetap snapshot immutable pada Local date dan Instant semula;
notifikasinya dijadwalkan ulang ke Instant trigger yang sama. Timezone baru hanya
dipakai untuk menentukan "hari ini", batas query/proyeksi, dan occurrence yang
belum dimaterialisasi setelah watermark. Setelah mutation diterima, server dan
setiap client yang menarik revision tersebut wajib merecompute cache streak dan
proyeksi berbasis batas hari sebelum menampilkan hasil.

Perubahan durasi Pomodoro hanya berlaku saat phase/session berikutnya dibuat;
`durasi_menit` pada PomodoroSession `running` tidak berubah. Bahasa diterapkan
pada render UI berikutnya tanpa memutasi data domain. Saat
`notifications_enabled=false`, setiap device membatalkan trigger lokal yang belum
terkirim tetapi mempertahankan reminder offsets pada entity. Saat kembali `true`,
device menjadwalkan ulang trigger masa depan hanya jika izin OS `granted`.
`alarm_mode=muted` menonaktifkan suara alarm tetapi tidak menyembunyikan visual
notification; volume device diterapkan hanya jika platform mendukungnya.

Hari Weekly Review tetap Minggu pada v1.0. `weekly_review_time` menentukan awal
gate dalam timezone user. Perubahan waktu hanya menjadwalkan ulang trigger yang
belum lewat. Review, cutoff, dan snapshot yang sudah tersimpan tidak berubah.

### 3.2 DeviceSettings (local-only)

Row ini berada hanya di Drift/secure storage dan tidak memiliki `server_revision`
atau `SyncChange`.

| Field | Type | Constraint |
|---|---|---|
| `device_id` | UUID | PK; sama dengan SyncDevice.id |
| `notification_permission` | ENUM | `unknown`, `granted`, `denied` |
| `alarm_volume_percent` | INTEGER | Default 100; 0..100 |
| `theme` | ENUM | `system`, `light`, `dark`; default `system` |
| `active_timer_notification_id` | INTEGER nullable | Platform notification handle |
| `last_pull_cursor` | TEXT nullable | Opaque; dibuang saat epoch/generation berubah |
| `sync_generation` | UUID nullable | Generation server terakhir; null sebelum registrasi |
| `sync_epoch` | BIGINT nullable | Epoch device terakhir dari server |
| `last_sync_status` | ENUM | `idle`, `syncing`, `success`, `failed`, `snapshot_required`, `review_required`, `recovery_required` |
| `last_sync_at` | Instant nullable | Waktu sukses terakhir |
| `onboarding_completed_at` | Instant nullable | Null sampai first-run onboarding selesai |

Bearer API key disimpan di platform secure storage, bukan tabel ini. API key,
permission OS, notification handle, dan cursor tidak pernah masuk export domain,
push payload, snapshot, atau log aplikasi. `notifications_enabled=true` tidak
menggantikan izin OS; jika izin `denied`, UI menampilkan aksi membuka system
settings tanpa mengubah preferensi user.

`theme` adalah preferensi tampilan per-device dan mengikuti pola field lokal yang
sama seperti `alarm_volume_percent`: tidak memiliki `server_revision` atau
`SyncChange`, tidak disinkronkan, dan tidak ditimpa snapshot. Ia bukan bagian
UserSettings sehingga tiap device dapat berbeda; default `system` mengikuti tema
OS. Tema tidak memengaruhi data domain, status, atau perhitungan apa pun.

### 3.3 SyncOutbox (local-only)

Client menulis perubahan domain, jurnal, dan outbox dalam satu transaction SQLite.
Satu entity hanya memiliki satu request yang sedang dikirim atau menunggu retry.
Perubahan berikutnya tetap menjadi draft berurutan; client tidak mengirimnya
sebelum outcome request sebelumnya diketahui.

| Field | Type | Constraint |
|---|---|---|
| `change_id` | UUID | PK; dibekukan sebelum kirim pertama |
| `device_id` | UUID | DeviceSettings.device_id |
| `sync_generation` | UUID nullable | Null hanya pada draft sebelum registrasi |
| `sync_epoch` | BIGINT nullable | Epoch saat body dibekukan |
| `entity_type`, `entity_id` | TEXT, UUID | Allowlist dan ID domain |
| `operation` | ENUM | `upsert`, `delete`, `restore` |
| `base_server_revision` | BIGINT nullable | Null untuk create; draft successor belum siap kirim |
| `base_record_json` | JSON nullable | Base server terakhir saat edit dibuat |
| `local_before_json` | JSON nullable | Proyeksi lokal tepat sebelum draft edit, termasuk mutation pendahulu; basis rebase draft |
| `payload_json` | JSON nullable | Kandidat lengkap field mutable; null untuk delete/restore |
| `resolution_of` | UUID nullable | Change ID review yang sedang diselesaikan |
| `local_sequence` | BIGINT | Monotonic per device; urutan draft |
| `request_hash` | TEXT nullable | SHA-256 canonical item; wajib sejak kirim pertama |
| `frozen_at` | Instant nullable | Setelah terisi, body/hash/change ID tidak boleh berubah |
| `status` | ENUM | `draft`, `pending`, `sending`, `retry_wait`, `rejected`, `review_required`, `quarantined` |
| `attempt_count` | INTEGER | Default 0, non-negative |
| `next_retry_at` | Instant nullable | Waktu retry transient |
| `last_error_code` | TEXT nullable | Tanpa secret |
| `created_at`, `updated_at` | Instant | Audit lokal |

Startup mengembalikan `sending` ke `pending` tanpa mengubah body beku. Outcome
accepted/duplicate memperbarui SyncEntityBase, menyimpan receipt ke jurnal, dan
menghapus item outbox dalam transaction yang sama. Client memproyeksikan ulang
edit draft di atas base baru menggunakan kelompok merge bagian 18.1, dengan
local_before_json sebagai versi sebelum edit draft. Ini membedakan perubahan
pengguna sendiri yang baru accepted dari perubahan perangkat lain. Draft
create yang mengikuti create accepted berubah menjadi update dengan revision
accepted; draft belum pernah dikirim boleh mendapat payload/hash yang baru.
Response/pull lama tidak boleh mengganti tampilan edit yang lebih baru. Jika
rebase draft bertabrakan, client membuat review lokal dan menahan entity itu.

Client tidak mengganti base dengan revision yang lebih rendah dalam generation
yang sama. Pull yang mengenai request beku disimpan sebagai base terbaru, tetapi
request beku tetap diretry dengan body awal. Tombstone atau parent yang berubah
memicu review/rejection; client tidak membangkitkan record otomatis. Rejection
bertahan sampai diperbaiki atau dibuang pengguna; perbaikan memakai change ID baru.

### 3.4 SyncConflictNotice (local-only)

| Field | Type | Constraint |
|---|---|---|
| `id` | UUID | PK |
| `change_id` | UUID nullable | Null untuk review draft yang belum dikirim |
| `entity_type`, `entity_id` | TEXT, UUID | Entity yang ditahan untuk edit |
| `sync_generation` | UUID | Generation review |
| `base_record_json` | JSON nullable | Base kanonik atau base draft lokal |
| `local_payload_json` | JSON nullable | Kandidat pengguna; null untuk delete/restore |
| `server_record_json` | JSON nullable | Snapshot aktif/tombstone, null jika tidak ada |
| `reviewed_server_revision` | BIGINT nullable | Revision saat review dibuat |
| `conflicting_groups_json` | JSON array | Nama kelompok dari bagian 18.1 |
| `selected_groups_json` | JSON array | Pilihan `local`/`server` per kelompok; belum menjadi mutation |
| `status` | ENUM | `pending_review`, `submitted`, `resolved`, `discarded` |
| `created_at`, `resolved_at` | Instant, Instant nullable | Audit review |

Membuka notice tidak menyelesaikan konflik. Client menahan edit record, termasuk
aksi parent/cascade dan materializer lokal yang dapat mengubahnya. Resource lain
tetap dapat dipakai. Jika record adalah timer running, perhitungan tampilan waktu
tetap berjalan; transisi persisten menunggu review. Client menampilkan base,
lokal, server, dan pilihan per kelompok, lalu mengirim resolusi dengan change ID
baru. Snapshot server yang lebih baru membatalkan pilihan kelompok terdampak.

### 3.5 SyncSnapshotStaging (local-only)

Primary key `(snapshot_id, sequence)`. Field: `snapshot_id`, `sync_generation`,
`sync_epoch`, `sequence`, `entity_type`, `entity_id`, `record_json`, `size_bytes`,
dan `received_at`. Client memverifikasi count/byte/ID sebelum replacement atomik.
Staging yang expired boleh dibuang; salinan recovery dan jurnal tidak ikut dihapus.
Snapshot untuk data lokal yang sudah ada wajib didahului salinan bagian 3.6.

### 3.6 SyncRecoveryQueue (local-only)

Queue berlaku untuk PITR, retention expiry, atau base revision yang sudah tidak
tersedia. Sebelum replacement, client membekukan write lokal sementara, membuat
salinan SQLite terenkripsi dengan manifest/hash, lalu mencatat data domain, base,
antrean, konflik, dan jurnal. Write dibuka kembali setelah snapshot terpasang;
entity yang masih direview tetap hanya dapat dibaca. Snapshot gagal tidak
menghapus salinan dan pengguna masih dapat membaca state lama.

| Field | Type | Constraint |
|---|---|---|
| `id` | UUID | PK |
| `original_change_id` | UUID nullable | Null jika hanya perbedaan snapshot yang tersedia |
| `replacement_change_id` | UUID nullable | Baru setelah persetujuan |
| `entity_type`, `entity_id` | TEXT, UUID | Entity terkait |
| `source_generation`, `target_generation` | UUID nullable, UUID | Generation sebelum/sesudah recovery |
| `recovery_copy_path`, `recovery_copy_sha256` | TEXT | Salinan lokal aman; tidak dikirim ke server |
| `base_record_json`, `local_record_json`, `server_record_json` | JSON nullable | Bahan review yang tidak berubah oleh replacement |
| `classification` | ENUM | `never_accepted`, `accepted_missing`, `superseded`, `manual_review` |
| `reason` | ENUM | `server_restore`, `retention_expired`, `base_unavailable` |
| `status` | ENUM | `pending_review`, `approved`, `discarded`, `replayed` |
| `created_at`, `resolved_at` | Instant, Instant nullable | Audit keputusan |

Receipt tanpa outcome pasti masuk `manual_review`, bukan `never_accepted`.
`accepted_missing` berarti receipt membuktikan acceptance di generation sumber
namun state hasil tidak tersedia pada target; nomor revision lintas generation
atau jam device tidak menjadi bukti urutan. State yang terbukti sudah terwakili
pada server menjadi `superseded` dan tidak direplay. Kasus ambigu tetap review.

Semua replay memerlukan persetujuan pengguna setelah perbandingan. Persetujuan
massal harus menampilkan jumlah, jenis perubahan, dan efek keuangan. Client
membentuk mutation baru terhadap state target terbaru, dengan lineage ke jurnal.
Tombstone tidak direstore otomatis. Transaksi dengan ID/efek yang sudah ada tidak
dibuat ulang; reversal/adjustment menggunakan domain service dan validasi ledger.
Salinan recovery dipertahankan sampai semua item resolved/discarded/replayed dan
minimal 30 hari; jurnal v1.0 tidak dibersihkan otomatis.

### 3.7 SyncEntityBase (local-only)

Primary key `(device_id, entity_type, entity_id)`. Field `sync_generation`,
`server_revision`, `record_json` (wire record aktif/tombstone), dan `received_at`.
Base adalah state server terakhir yang diketahui, terpisah dari proyeksi domain
lokal yang mungkin memuat draft. Snapshot mengganti base setelah salinan aman.
Metadata ini tidak termasuk payload domain sync.

### 3.8 SyncMutationJournal (local-only)

Primary key `change_id`; field `device_id`, `entity_type`, `entity_id`,
`local_sequence`, `sync_generation`, `base_record_json`, `request_json`,
`receipt_json` nullable, `original_change_id` nullable, `created_at`, dan
`acknowledged_at` nullable. Client mencatat semua mutation sebelum kirim dan
menambahkan receipt dalam transaction penerapan outcome, termasuk accepted yang
keluar dari outbox. Request beku dan receipt bersifat immutable; revisi draft
sebelum kirim boleh diperbarui. Client mempertahankan jurnal tanpa cleanup
otomatis pada v1.0 personal. Jurnal dan recovery copy dienkripsi dengan key lokal
sesuai OPERATIONS dan tidak berisi API key.

---

## 4. MataKuliah

| Field | Type | Constraint |
|---|---|---|
| `id` | UUID | PK |
| `user_id` | UUID | FK → User.id |
| `nama` | TEXT | Non-empty |
| `dosen` | TEXT nullable | |
| `sks` | INTEGER nullable | `sks > 0` jika terisi |
| `semester` | TEXT nullable | |
| `warna` | TEXT | Hex `#RRGGBB` |
| *(global columns)* | | |

Index: `(user_id, is_deleted, nama)`.

### 4.1 CourseNote

Entity ini menyimpan catatan perkuliahan bertanggal untuk satu Mata Kuliah.
Catatan tidak terikat ke Tugas; satu mata kuliah dapat memiliki beberapa catatan
pada tanggal yang sama.

| Field | Type | Constraint |
|---|---|---|
| `id` | UUID | PK |
| `mata_kuliah_id` | UUID | FK → MataKuliah.id |
| `tanggal` | Local date | Tanggal yang user pilih dalam timezone user |
| `isi` | TEXT | Non-empty |
| *(global columns, tanpa user_id)* | | |

Index: `(mata_kuliah_id, is_deleted, tanggal, created_at)`. Catatan ikut soft
delete dan sync sebagai entity type `course_note`; ownership selalu divalidasi
lewat MataKuliah parent.

---

## 5. Tugas

| Field | Type | Constraint |
|---|---|---|
| `id` | UUID | PK |
| `user_id` | UUID | FK → User.id |
| `mata_kuliah_id` | UUID nullable | FK → MataKuliah.id, same user |
| `judul` | TEXT | Non-empty |
| `deskripsi` | TEXT nullable | |
| `deadline` | Instant | |
| `prioritas` | ENUM | `low`, `medium`, `high` |
| `estimasi_menit` | INTEGER nullable | `> 0` jika terisi |
| `status` | ENUM | `belum`, `progress`, `selesai` |
| `completed_at` | Instant nullable | Server/device command time; wajib untuk `selesai`, null untuk status lain |
| `archived_at` | Instant nullable | Waktu arsip manual; null berarti tidak diarsipkan manual |
| `reminders` | JSON array | Array TaskReminder unik; default H-7/H-3/H-1 pukul 09.00 dan 120 menit sebelum deadline |
| *(global columns)* | | |

Index: `(user_id, is_deleted, status, deadline)` dan
`(user_id, mata_kuliah_id, is_deleted)`.

TaskReminder memakai salah satu bentuk berikut:

- `{ "kind": "calendar_day", "days_before": 7, "local_time": "09:00:00" }`;
- `{ "kind": "relative_minutes", "minutes_before": 120 }`.

`calendar_day` dijadwalkan pada Local date deadline dikurangi `days_before`
dalam timezone user. `relative_minutes` dihitung dari Instant deadline. Trigger
yang sudah lewat saat create/update tidak ditembakkan ulang. Duplikat canonical
ditolak.

Tugas belum selesai tetap aktif meskipun deadline telah lewat. Tugas selesai
masuk riwayat pada pukul 00.00 tujuh Local date setelah Local date
`completed_at`. Arsip manual berlaku segera dan memakai Local date `archived_at`
sebagai `history_date`. Membuka kembali status selesai mengosongkan
`completed_at`; unarchive mengosongkan `archived_at`. Tugas aktif jika
`archived_at=null` dan belum mencapai tanggal arsip otomatis. Query tampilan
menghitung `history_date` tanpa memutasi row.

### 5.1 TugasChecklist

| Field | Type | Constraint |
|---|---|---|
| `id` | UUID | PK |
| `tugas_id` | UUID | FK → Tugas.id |
| `judul` | TEXT | Non-empty |
| `is_done` | BOOLEAN | Default `false` |
| `urutan` | INTEGER | `>= 0` |
| *(global columns, tanpa user_id)* | | |

Unique aktif: `(tugas_id, urutan)`. Index: `(tugas_id, is_deleted, urutan)`.

## 6. ActivityCategory

ActivityCategory menjaga nama dan warna yang sama pada Activity serta Timebox.
Aplikasi membuat seed per user untuk Kuliah, Tugas, Personal, Istirahat, Sosial,
dan Olahraga; seed memakai UUIDv5 deterministik dari user dan slug kategori.

| Field | Type | Constraint |
|---|---|---|
| `id` | UUID | PK; UUIDv5 untuk seed, UUIDv4 untuk custom |
| `user_id` | UUID | FK → User.id |
| `nama` | TEXT | Non-empty |
| `warna` | TEXT | Hex `#RRGGBB` |
| `icon` | TEXT nullable | Resource/icon key, bukan path file |
| `is_system` | BOOLEAN | `true` untuk seed; tidak dapat dihapus |
| `is_archived` | BOOLEAN | Default `false`; kategori arsip tidak muncul pada picker baru |
| *(global columns)* | | |

Unique aktif: `(user_id, lower(nama))`. Kategori yang direferensikan histori
tidak dapat dihapus. Rename atau perubahan warna berlaku pada seluruh tampilan
karena entity lain menyimpan ID kategori; histori tetap mempertahankan relasi.

## 7. ActivityRecurrence

Entity ini menyimpan template recurrence. Activity menyimpan occurrence nyata.

| Field | Type | Constraint |
|---|---|---|
| `id` | UUID | PK |
| `user_id` | UUID | FK → User.id |
| `judul` | TEXT | Non-empty |
| `activity_category_id` | UUID | FK → ActivityCategory.id, same user |
| `start_time` | Local time nullable | Null untuk all-day |
| `end_time` | Local time nullable | `end_time > start_time` jika terisi |
| `is_all_day` | BOOLEAN | Default `false` |
| `recurring_days` | JSON array | Weekday integer 1..7, unique |
| `starts_on` | Local date | Tanggal aktif pertama |
| `ends_on` | Local date nullable | `>= starts_on` |
| `reminder_offsets_minutes` | JSON array | Default `[]`; integer non-negative, unique |
| `catatan` | TEXT nullable | |
| `materialized_through_date` | Local date nullable | Server/local-service watermark; read-only via REST |
| *(global columns)* | | |

Index: `(user_id, is_deleted, starts_on, ends_on)`.

Reminder hanya sah jika template mempunyai `start_time`. Template all-day wajib
memiliki array reminder kosong. Nilai reminder disalin ke setiap Activity
occurrence agar perubahan template tidak mengubah reminder occurrence lama.

---

## 8. Activity

Satu row mewakili satu occurrence atau satu activity non-recurring.

| Field | Type | Constraint |
|---|---|---|
| `id` | UUID | PK |
| `user_id` | UUID | FK → User.id |
| `recurrence_id` | UUID nullable | FK → ActivityRecurrence.id |
| `occurrence_date` | Local date | Tanggal activity dalam timezone user |
| `judul` | TEXT | Snapshot judul saat occurrence dibuat |
| `activity_category_id` | UUID | FK → ActivityCategory.id, same user |
| `start_time` | Instant nullable | Null untuk flexible/all-day |
| `end_time` | Instant nullable | `end_time > start_time` jika terisi |
| `is_all_day` | BOOLEAN | Default `false` |
| `status` | ENUM | `belum_mulai`, `selesai`, `dilewati` |
| `source` | ENUM | `manual`, `pomodoro`, `timebox`, `habit` |
| `source_id` | UUID nullable | ID immutable source event |
| `reminder_offsets_minutes` | JSON array | Snapshot reminder; default `[]` |
| `catatan` | TEXT nullable | |
| *(global columns)* | | |

Home menggabungkan TimeboxExecution dan Activity `source=timebox` dengan
`source_id` yang sama menjadi satu unit presentasi. Record tetap terpisah agar
plan dan hasil dapat diaudit tanpa menampilkan kartu ganda.

Source event mapping:

| source | source_id points to |
|---|---|
| `pomodoro` | PomodoroSession.id |
| `timebox` | TimeboxExecution.id |
| `habit` | HabitLog.id |
| `manual` | Null |

Pekerjaan tugas yang berjalan lewat Pomodoro atau Timebox memakai source event
tersebut. Schema v1.0 tidak membuat Activity langsung dari perubahan status Tugas.
Activity tanpa `start_time` wajib memiliki `reminder_offsets_minutes=[]`.
Derived Activity dari Pomodoro, Timebox, atau Habit selalu memakai array kosong;
reminder dijadwalkan pada source resource sebelum eksekusi, bukan pada histori.

Unique aktif: `(user_id, recurrence_id, occurrence_date)` jika
`recurrence_id` terisi, serta `(user_id, source, source_id)` jika `source_id`
terisi. Index: `(user_id, is_deleted, occurrence_date, status)`.

Jika sumber legacy terverifikasi tersedia, migration harus memindahkan `is_recurring`, `recurring_days`, dan
`recurring_end_date` dari Activity ke ActivityRecurrence. Migration membuat
occurrence pertama tanpa mengubah histori non-recurring.

---

## 9. PomodoroSession

| Field | Type | Constraint |
|---|---|---|
| `id` | UUID | PK |
| `user_id` | UUID | FK → User.id |
| `tugas_id` | UUID nullable | FK → Tugas.id, same user |
| `habit_id` | UUID nullable | FK → Habit.id, same user |
| `start_time` | Instant | Ditulis saat user menekan Start |
| `end_time` | Instant nullable | Wajib untuk completed/cancelled |
| `paused_at` | Instant nullable | Wajib saat status `paused`; null pada status lain |
| `accumulated_pause_seconds` | INTEGER | Default 0; `>= 0` |
| `durasi_menit` | INTEGER | Planned duration, `> 0` |
| `actual_seconds` | INTEGER nullable | Durasi aktual, `>= 0` |
| `jenis` | ENUM | `fokus`, `istirahat_pendek`, `istirahat_panjang` |
| `status` | ENUM | `running`, `paused`, `completed`, `cancelled` |
| *(global columns)* | | |

Index: `(user_id, is_deleted, start_time)` dan
`(user_id, status, start_time)`. Maksimal satu dari `tugas_id` dan `habit_id`
boleh terisi. Pause menyimpan `paused_at`; resume menambah selisih pause ke
`accumulated_pause_seconds` lalu mengosongkan `paused_at`. Completion/cancel
mengisi `end_time`. Jika session masih paused, service lebih dahulu menambahkan
pause terbuka `end_time - paused_at` ke accumulator. Service menghitung
`actual_seconds = max(0, end_time - start_time - accumulated_pause_seconds)`;
REST client tidak mengirim field hasil hitung ini. Timestamp command tidak boleh
lebih awal dari transisi sebelumnya. Transition command wajib idempotent.
Statistik hanya menghitung sesi `jenis=fokus` dengan
status `completed`, memakai `actual_seconds`, dan mengelompokkan sesi menurut
Local date `start_time` dalam timezone user.

---

## 10. TimeboxSchedule

Entity ini menyimpan template atau definisi ad-hoc. Outcome per tanggal berada
di TimeboxExecution.

| Field | Type | Constraint |
|---|---|---|
| `id` | UUID | PK |
| `user_id` | UUID | FK → User.id |
| `tugas_id` | UUID nullable | FK → Tugas.id, same user |
| `habit_id` | UUID nullable | FK → Habit.id, same user |
| `judul` | TEXT | Non-empty |
| `activity_category_id` | UUID | FK → ActivityCategory.id, same user |
| `start_time` | Local time | |
| `end_time` | Local time | `end_time > start_time` |
| `hari` | INTEGER nullable | Weekday 1..7 |
| `tanggal_spesifik` | Local date nullable | Untuk ad-hoc |
| `is_recurring` | BOOLEAN | |
| `is_active` | BOOLEAN | Default `true` |
| `reminder_offsets_minutes` | JSON array | Default `[]`; integer non-negative, unique |
| `materialized_through_date` | Local date nullable | Server/local-service watermark; read-only via REST |
| *(global columns)* | | |

Constraint: recurring wajib memiliki `hari` dan tidak memiliki
`tanggal_spesifik`; ad-hoc mengikuti aturan sebaliknya.
Maksimal satu dari `tugas_id` dan `habit_id` boleh terisi. `is_active=false`
menonaktifkan seluruh template dan tidak mewakili pengecualian satu occurrence.

Reminder dihitung dari `start_time` pada occurrence lokal, lalu dikonversi ke
Instant UTC memakai timezone user. Edit reminder hanya berlaku untuk execution
yang belum dimaterialisasi; execution lama tetap memakai snapshot waktunya.

### 10.1 TimeboxExecution

| Field | Type | Constraint |
|---|---|---|
| `id` | UUID | PK |
| `schedule_id` | UUID | FK → TimeboxSchedule.id |
| `occurrence_date` | Local date | |
| `planned_start_at` | Instant | Snapshot jadwal |
| `planned_end_at` | Instant | `> planned_start_at` |
| `status` | ENUM | `pending`, `completed`, `missed`, `skipped`, `rescheduled` |
| `actual_start_at` | Instant nullable | |
| `actual_end_at` | Instant nullable | |
| `rescheduled_to_id` | UUID nullable | FK → TimeboxExecution.id |
| `activity_id` | UUID nullable | FK → Activity.id |
| `catatan` | TEXT nullable | Catatan outcome dari user |
| *(global columns, tanpa user_id)* | | |

`planned_start_at` dan `planned_end_at` selalu diisi server/client local service
saat execution dimaterialisasi, menggunakan `occurrence_date`, timezone user,
serta snapshot `start_time`/`end_time` dari schedule. `actual_start_at` diisi saat
user benar-benar memulai block; `actual_end_at` diisi saat block diselesaikan.
Completion membuat tepat satu Activity deterministik dan mewajibkan
`activity_id`; execution pending, missed, skipped, atau rescheduled tidak memiliki
Activity hasil.

Command `start` hanya berlaku dari `pending` dan mengisi `actual_start_at` tanpa
mengubah status. Command `skip` berlaku untuk satu execution, tidak membuat
Activity, dan tidak mengubah `TimeboxSchedule.is_active`. `missed` menyatakan
pengguna gagal menjalankan rencana; `skipped` menyatakan pengecualian yang
disengaja. Home menampilkan execution dan Activity hasilnya sebagai satu unit.

Untuk status `rescheduled`, command `reschedule` mengirim target Instant
`rescheduled_to`. Service membuat destination TimeboxExecution berstatus
`pending` dalam transaction yang sama, mempertahankan durasi rencana asal,
kemudian menyimpan ID destination pada `rescheduled_to_id`. Source tetap
`rescheduled` sebagai histori immutable. Target yang sama dengan source atau
bertabrakan dengan execution aktif ditolak.

Unique aktif: `(schedule_id, planned_start_at)`. Index:
`(schedule_id, is_deleted, occurrence_date, planned_start_at)`.

---

## 11. Habit

| Field | Type | Constraint |
|---|---|---|
| `id` | UUID | PK |
| `user_id` | UUID | FK → User.id |
| `nama` | TEXT | Non-empty |
| `warna` | TEXT | Hex `#RRGGBB` |
| `icon` | TEXT nullable | |
| `current_streak` | INTEGER | Default 0; reconstructable cache |
| `longest_streak` | INTEGER | Default 0; cache |
| `is_archived` | BOOLEAN | Cache dari state HabitSchedule pada hari ini |
| `urutan` | INTEGER | `>= 0` |
| *(global columns)* | | |

Index: `(user_id, is_deleted, is_archived, urutan)`.

### 11.1 HabitSchedule

Versioned schedule menjaga interpretasi histori ketika target hari atau batas
izin diubah.

| Field | Type | Constraint |
|---|---|---|
| `id` | UUID | PK; deterministic UUIDv5 |
| `habit_id` | UUID | FK → Habit.id |
| `effective_from` | Local date | Awal inklusif dalam timezone user |
| `effective_to` | Local date nullable | Akhir inklusif; wajib `<` schedule berikutnya |
| `target_hari` | JSON array | Weekday integer 1..7, unique |
| `max_izin_per_minggu` | INTEGER | Default 1; `>= 0` |
| `state` | ENUM | `active`, `paused`; snapshot status pada rentang ini |
| *(global columns, tanpa user_id)* | | |

Unique aktif: `(habit_id, effective_from)`. Hanya boleh ada satu schedule aktif
untuk suatu Habit pada satu tanggal. Tanggal efektif wajib hari ini atau masa
depan dalam timezone user. Update target atau batas izin membuat schedule baru
pada tanggal efektif lalu menyesuaikan `effective_to` milik schedule sebelum dan
sesudahnya dalam satu transaction agar tidak ada overlap. Schedule yang sudah
berakhir sebelum tanggal efektif tidak dimutasi.

Periode izin adalah minggu kalender Senin 00.00 sampai Minggu 23:59:59 dalam
`UserSettings.timezone`. Hanya log `skip` pada target day yang dihitung. Saat membuat
skip, batas yang digunakan adalah `max_izin_per_minggu` dari schedule yang aktif
pada tanggal log. Skip di atas batas ditolak dan tidak memutus atau mengubah
histori streak yang sudah tersimpan.

Archive/resume tidak mengubah `Habit.is_archived` secara bebas. Service membuat
HabitSchedule baru dengan `state=paused` atau `state=active` pada
`schedule_effective_from` (default hari ini), lalu memperbarui cache
`Habit.is_archived` berdasarkan schedule hari ini dalam transaction yang sama.
Schedule paused tetap membawa `target_hari` dan batas izin terakhir sebagai
snapshot, tetapi seluruh tanggal pada rentangnya dikeluarkan dari evaluasi
streak. Resume membuat versi active baru dan tidak mengisi log untuk periode
pause.

### 11.2 HabitLog

| Field | Type | Constraint |
|---|---|---|
| `id` | UUID | PK |
| `habit_id` | UUID | FK → Habit.id |
| `tanggal` | Local date | |
| `status` | ENUM | `done`, `skip`, `missed` |
| `catatan` | TEXT nullable | |
| *(global columns, tanpa user_id)* | | |

Unique aktif: `(habit_id, tanggal)`. Activity `source=habit` memakai HabitLog.id,
bukan Habit.id. Perhitungan current/longest streak selalu mencari HabitSchedule
yang aktif pada setiap tanggal historis; schedule terbaru tidak diterapkan
mundur.

Koreksi log menjaga derived Activity dalam transaction yang sama. Transisi dari
`done` ke `skip`/`missed` men-tombstone Activity aktif dengan source ID tersebut.
Transisi menuju `done` membuat atau me-restore Activity dengan UUIDv5 yang sama.
Perubahan catatan pada log `done` memperbarui catatan Activity dan menghasilkan
revision baru tanpa membuat Activity kedua.

### 11.3 Algoritma streak normatif

Evaluasi memakai Local date dalam `UserSettings.timezone` dan hanya tanggal sampai hari
ini. Untuk setiap tanggal berurutan sejak `effective_from` pertama:

1. Jika tidak ada schedule atau `state=paused`, tanggal diabaikan dan tidak
   menambah maupun memutus streak.
2. Jika weekday bukan anggota `target_hari`, tanggal diabaikan.
3. Target day dengan log aktif `done` menambah streak satu.
4. Target day dengan `skip` yang masih berada dalam kuota schedule untuk minggu
   Senin–Minggu dianggap *excused*: tidak menambah dan tidak memutus streak.
5. Target day dengan `missed`, tanpa log setelah hari itu berakhir, atau `skip`
   yang tidak valid memutus streak menjadi nol. Server menolak skip di atas
   kuota; row `missed` boleh dibuat eksplisit untuk audit tetapi hasil hitungnya
   sama dengan ketiadaan log pada tanggal lampau.
6. Target day hari ini tanpa log belum memutus current streak sampai pukul
   23:59:59 lokal. Untuk `longest_streak`, hari ini belum dihitung.

`current_streak` adalah jumlah `done` sejak miss terakhir pada target day,
melewati non-target, paused, dan excused day. Jika hari ini/non-target terakhir
tidak membutuhkan aksi, nilai terakhir dipertahankan. `longest_streak` adalah
maksimum historis dari counter tersebut dan merupakan cache yang wajib dapat
direkonstruksi. Perubahan schedule, log, timezone, pause/resume, atau restore
memicu recompute dari tanggal terdampak paling awal.

Golden table (timezone `Asia/Jakarta`):

| Tanggal | Schedule/state | Log | current sesudah evaluasi | longest |
|---|---|---|---:|---:|
| Sen 2026-09-07 | active `[1,3,5]` | done | 1 | 1 |
| Rab 2026-09-09 | active `[1,3,5]` | skip valid | 1 | 1 |
| Jum 2026-09-11 | active `[1,3,5]` | done | 2 | 2 |
| Sen 2026-09-14 | active `[1,3,5]` | tidak ada setelah hari berakhir | 0 | 2 |
| Rab 2026-09-16 | active `[1,3,5]` | done | 1 | 2 |
| Sen 2026-09-21 | paused | tidak ada | 1 | 2 |
| Sel 2026-09-29 | active `[2,4]` | done | 2 | 2 |

Implementasi Dart, Node.js, dan recompute migration wajib menghasilkan angka
yang sama untuk fixture ini.

---

## 12. Akun

| Field | Type | Constraint |
|---|---|---|
| `id` | UUID | PK |
| `user_id` | UUID | FK → User.id |
| `nama` | TEXT | Non-empty |
| `tipe` | ENUM | `cash`, `bank`, `ewallet`, `custom` |
| `saldo_awal` | Money | Dapat diperbaiki hanya sebelum ada transaksi retained |
| `saldo` | Money | Cache; server memperbarui dalam transaction |
| `is_archived` | BOOLEAN | Default `false` |
| `archived_at` | Instant nullable | Wajib saat `is_archived=true` |
| *(global columns)* | | |

Index: `(user_id, is_deleted, nama)`.

Saat create, `saldo=saldo_awal`. Endpoint update akun dapat memperbaiki
`saldo_awal` hanya jika akun belum memiliki transaksi aktif atau tombstone yang
masih diretain. Sesudah ledger terbentuk, koreksi saldo membuat Transaksi
`adjustment`; client tidak pernah mengirim `saldo` sebagai mutation. Akun arsip
tidak muncul pada picker transaksi baru dan tidak masuk total saldo aktif,
sementara histori tetap merujuk akun tersebut. Seluruh mutation ledger baru,
termasuk koreksi saldo, ditolak saat akun arsip; user harus unarchive lebih dahulu.

---

## 13. CategoryKeuangan

| Field | Type | Constraint |
|---|---|---|
| `id` | UUID | PK; UUIDv5 untuk seed, UUIDv4 untuk custom |
| `user_id` | UUID | FK → User.id |
| `nama` | TEXT | Non-empty |
| `tipe` | ENUM | `income`, `expense` |
| `icon` | TEXT nullable | |
| `is_archived` | BOOLEAN | Default `false` |
| `archived_at` | Instant nullable | Wajib saat `is_archived=true` |
| *(global columns)* | | |

Unique aktif: `(user_id, tipe, nama)`.
Kategori arsip tidak muncul pada transaksi baru dan tetap dapat dirender pada
histori. Seed expense dan income dibuat per user saat onboarding/provisioning.

---

## 14. Transaksi

| Field | Type | Constraint |
|---|---|---|
| `id` | UUID | PK |
| `user_id` | UUID | FK → User.id |
| `akun_id` | UUID | FK → Akun.id, same user |
| `akun_tujuan_id` | UUID nullable | FK → Akun.id, same user |
| `category_id` | UUID nullable | FK → CategoryKeuangan.id, same user |
| `jumlah` | Money | `> 0` |
| `tipe` | ENUM | `income`, `expense`, `transfer`, `adjustment` |
| `adjustment_direction` | ENUM nullable | `increase`, `decrease`; wajib hanya untuk adjustment |
| `tanggal` | Local date | |
| `catatan` | TEXT nullable | |
| *(global columns)* | | |

Transfer wajib memiliki akun tujuan yang berbeda dan `category_id=null`.
Income/expense wajib memiliki category dengan tipe yang cocok. Adjustment
memiliki `category_id=null`, `akun_tujuan_id=null`, dan direction non-null.
Mutation transaksi dan saldo akun berjalan dalam satu database transaction.

Create dan update transfer memakai mutation khusus yang menerima
`akun_asal_id`, `akun_tujuan_id`, `jumlah`, `tanggal`, dan `catatan`. Endpoint
income/expense tidak boleh mengubah `tipe` menjadi/keluar dari `transfer`.
Update transfer membalik efek ledger lama lalu menerapkan nilai baru pada kedua
akun dalam satu transaction; delete transfer membalik kedua sisi sebelum membuat
tombstone. Insufficient balance tidak menjadi invariant v1.0 sehingga saldo
negatif diizinkan. Replay idempotent tidak boleh menerapkan pembalikan dua kali.

Command koreksi saldo menerima saldo target. Service membaca saldo terbaru,
menghitung selisih, lalu membuat adjustment `increase` atau `decrease` dengan
`jumlah=abs(target-current)` dalam transaction yang sama. Selisih nol
mengembalikan saldo tanpa membuat transaksi. Adjustment immutable; koreksi
berikutnya membuat adjustment kompensasi agar audit ledger tetap dapat dijelaskan.

Index: `(user_id, is_deleted, tanggal)`, `(akun_id, is_deleted, tanggal)`, dan
`(category_id, is_deleted, tanggal)`.

### 14.1 Derived projections dan interval

Semua rumus berikut normatif dan harus menghasilkan nilai yang sama di query
server, repository lokal, dan test fixture.

**Daily completion rate.** Untuk Local date `D`, `planned` adalah jumlah Activity
aktif (`is_deleted=false`) dengan `occurrence_date=D`, termasuk all-day,
flexible, recurring, dan derived Activity. Semua status masuk denominator,
termasuk `dilewati`; `completed` hanya status `selesai`. Rumus:

`rate_percent = planned == 0 ? 0.0 : round_half_up(100 * completed / planned, 1)`

**Overlap.** Interval terjadwal selalu half-open `[start, end)`, sehingga block
yang berakhir tepat saat block lain dimulai tidak overlap. Dua interval overlap
jika `max(start_a,start_b) < min(end_a,end_b)`. Kandidat adalah Activity aktif
dengan start/end non-null dan status bukan `dilewati`, serta TimeboxExecution
aktif berstatus `pending`. All-day/flexible dikeluarkan. Perbandingan memakai
Instant UTC; filter tanggal hanya memilih interval yang beririsan dengan batas
Local date dalam `UserSettings.timezone`. Activity `source=timebox` tidak
dibandingkan dengan TimeboxExecution pada `source_id` yang sama agar tidak memberi
warning terhadap representasi dirinya sendiri. Overlap menghasilkan warning
non-blocking `SCHEDULE_OVERLAP` dengan ID pasangan dan irisan interval, diurutkan
berdasarkan `overlap_start`, left key, lalu right key. Server menentukan sisi
`left` sebagai `(entity_type, entity_id)` yang lebih kecil secara leksikografis
dan menghapus pasangan duplikat.

**Ledger dan agregasi.** Untuk account `A`, hanya Transaksi aktif yang dihitung:

`saldo(A) = saldo_awal + income(A) - expense(A) - outbound_transfer(A) + inbound_transfer(A) + adjustment_increase(A) - adjustment_decrease(A)`

`total_balance` adalah jumlah saldo seluruh Akun non-arsip. Category chart hanya
menjumlah transaksi `expense`; trend menjumlah `income` dan `expense` per bulan;
transfer dan adjustment dikeluarkan dari kedua agregasi. Pengelompokan tanggal memakai
Local date transaksi, bukan `created_at`. Semua hasil memakai integer Rupiah;
persentase chart, jika ditampilkan client, dihitung dari integer total dan
dibulatkan satu desimal dengan `round_half_up`.

Rentang agregasi memakai pasangan Local date inklusif. Summary dan category chart
default ke bulan kalender berjalan; trend default ke 12 bulan kalender termasuk
bulan berjalan. `total_balance` tidak dipengaruhi rentang, sedangkan total income
dan expense pada summary mengikuti rentang. Category chart menghilangkan kategori
bernilai nol dan diurutkan amount menurun lalu category ID. Trend mengembalikan
setiap bulan yang beririsan, termasuk bulan nol, dengan `period_start` pada hari
pertama bulan dan urutan naik.

Fixture hitung minimum yang wajib identik di server dan repository lokal:

| Kasus | Input relevan | Expected |
|---|---|---|
| Completion kosong | Tidak ada Activity aktif pada D | `planned=0`, `completed=0`, `rate_percent=0.0` |
| Completion campuran | Tiga Activity aktif: `selesai`, `dilewati`, `belum_mulai` | `planned=3`, `completed=1`, `rate_percent=33.3` |
| Boundary interval | A `[09:00,10:00)`, B `[10:00,11:00)` | Tidak overlap |
| Irisan interval | A `[09:00,10:30)`, B `[10:00,11:00)` | Overlap `[10:00,10:30)` |
| Ledger | Saldo awal 100000; income 50000; expense 20000; transfer keluar 10000; transfer masuk 5000 | `saldo=125000` |
| Agregasi transfer | Hanya transfer 10000 dalam periode | Income/expense/chart category/trend tetap `0`; saldo kedua akun berubah berlawanan |
| Koreksi saldo | Saldo 125000; target koreksi 120000 | Adjustment decrease 5000; saldo 120000; agregasi income/expense tetap `0` |

**Weekly summary snapshot.** WeeklyReview draft menghitung projection dari
`week_start` Senin sampai `min(now, week_end 23:59:59)` dalam timezone user.
Command complete memakai satu Instant `summary_cutoff_at` untuk semua query dan
menyimpan hasil berikut sebagai JSON bertipe:

| Kelompok | Field |
|---|---|
| Activity | `planned`, `completed`, `skipped`, `not_started`, `rate_percent` |
| Tugas | `completed`, `active`, `overdue` |
| Pomodoro | `completed_focus_sessions`, `focus_seconds` |
| Timebox | `completed`, `missed`, `skipped`, `pending` |
| Habit | `done`, `missed`, `excused` |

Activity memakai aturan completion rate bagian ini. Tugas `completed` memiliki
`completed_at` dalam rentang minggu sampai cutoff; `active` berarti belum selesai
dan belum diarsipkan pada cutoff; `overdue` adalah bagian active dengan deadline
sebelum cutoff. Pomodoro hanya menghitung fokus completed dengan `start_time`
dalam rentang. Timebox memakai `occurrence_date` dalam minggu. Habit mengevaluasi
target day yang sudah berakhir sebelum cutoff serta log `done|skip` yang sudah
ada pada hari cutoff; target hari cutoff tanpa log belum menjadi `missed`.
Snapshot tidak memasukkan Transaksi atau agregasi keuangan.

**Next-week workload.** Weekly Review mengembalikan tujuh row Senin–Minggu untuk
minggu setelah `week_start`. `task_count` menghitung Tugas aktif dengan
`status != selesai` berdasarkan Local date deadline. `estimated_minutes`
menjumlah `estimasi_menit` dengan null bernilai nol; `unestimated_task_count`
menghitung Tugas dengan estimasi null. Hari tanpa Tugas tetap memiliki row nol.
Projection ini hanya menjadi bagian Weekly Review; v1.0 tidak menyediakan
endpoint workload mandiri.

---

## 15. Weekly Review

### 15.1 WeeklyReview

Satu row menyimpan sesi evaluasi untuk satu minggu kalender. Client membuat ID
UUIDv5 `urn:dailys:v1.0:weekly-review:{user_id}:{week_start}` saat review pertama
kali dibuka. Fresh install tidak membuat review parsial; review pertama dibuat
pada trigger Minggu pertama setelah onboarding.

| Field | Type | Constraint |
|---|---|---|
| `id` | UUID | PK; deterministic UUIDv5 |
| `user_id` | UUID | FK → User.id |
| `week_start` | Local date | Wajib Senin |
| `week_end` | Local date | `week_start + 6 hari` |
| `status` | ENUM | `draft`, `completed`; tidak ada skipped |
| `evaluation_text` | TEXT | Boleh kosong saat draft; non-empty saat completed |
| `next_week_focus_text` | TEXT | Boleh kosong saat draft; non-empty saat completed |
| `summary_snapshot` | JSON nullable | WeeklySummarySnapshot; wajib dan immutable saat completed |
| `summary_cutoff_at` | Instant nullable | Wajib saat completed; immutable |
| `completed_at` | Instant nullable | Wajib saat completed; immutable |
| *(global columns)* | | |

Unique aktif `(user_id, week_start)`. Index `(user_id, status, week_start)`.
`week_end`, cutoff, snapshot, dan status completed tidak dapat diubah setelah
completion. User masih dapat mengedit dua field teks; mutation itu mengubah
`updated_at` tanpa menghitung ulang snapshot. Delete, restore, reopen, dan skip
ditolak. Complete berjalan offline dan membuka gate lokal dalam transaction yang
sama dengan snapshot. Client mengirim WeeklyReview completed sebelum mutation
planning minggu berikutnya.

Command complete menolak teks kosong. Semua WeeklyPlanDraft aktif harus memiliki
target dan tanggal yang valid, tetapi tidak harus promoted. Client/server
menghitung snapshot dari database masing-masing memakai cutoff yang sama. Server
menolak cutoff lebih dari lima menit di masa depan. Jika hasil server berbeda
dari snapshot client, server menerima snapshot hasil hitung kanoniknya dan
response/pull mengganti snapshot lokal; perbedaan tidak membuka kembali gate.

### 15.2 WeeklyPlanDraft

Satu row menyimpan niat planning ringan. Field detail modul tidak diduplikasi;
promotion membuka form Tugas, Activity, atau Timebox dan memvalidasi payload
target melalui domain service modul tersebut.

| Field | Type | Constraint |
|---|---|---|
| `id` | UUID | PK; UUIDv4 dari client |
| `weekly_review_id` | UUID | FK → WeeklyReview.id |
| `target_type` | ENUM | `tugas`, `activity`, `timebox` |
| `judul` | TEXT | Non-empty |
| `catatan` | TEXT nullable | |
| `target_date` | Local date | Harus berada pada `week_start + 7..13 hari` |
| `source_entity_type` | ENUM nullable | `tugas`, `activity`, `timebox_execution` |
| `source_entity_id` | UUID nullable | Wajib bersama source type; hanya referensi kandidat |
| `status` | ENUM | `draft`, `promoted`, `discarded` |
| `promoted_entity_type` | ENUM nullable | Wajib saat promoted dan sama dengan target_type |
| `promoted_entity_id` | UUID nullable | Wajib saat promoted; UUIDv5 hasil promotion |
| *(global columns tanpa user_id)* | | |

Unique aktif `(weekly_review_id, id)` dan partial unique
`(weekly_review_id, promoted_entity_type, promoted_entity_id)` untuk status
promoted. Index `(weekly_review_id, status, target_date)`. Source type dan ID
harus keduanya null atau keduanya terisi dan dimiliki user yang sama. Source
tidak ikut cascade jika record asal dihapus; draft mempertahankan judul/catatan.

Draft dapat diubah atau dihapus sebelum promoted. `discarded` dan `promoted`
menjadi histori dan tidak dapat kembali ke draft. Promotion membuat target ID
UUIDv5 `urn:dailys:v1.0:weekly-plan-promotion:{draft_id}:{target_type}` dan target
record dalam transaction yang sama, lalu mengisi promoted fields. Retry command
yang sama mengembalikan target semula. Target yang sudah terhapus tidak membuat
draft dapat dipromosikan ulang; restore mengikuti lifecycle target.

### 15.3 Gate planning

Gate aktif dari Minggu `weekly_review_time` sampai review minggu berjalan
completed. Gate memeriksa Local date pada minggu berikutnya dan menolak:

- create/reschedule Activity atau perubahan field jadwal ke periode itu;
- create Tugas atau perubahan deadline ke periode itu;
- create/edit Timebox yang membuat atau mengubah execution pada periode itu;
- create/edit recurrence yang mengubah occurrence periode itu.

Record yang sudah ada tetap terbaca. Command status, actual timestamps,
completion/cancel/skip, edit catatan/non-planning, serta planning di luar periode
tetap sah. REST dan sync menjalankan aturan yang sama. Server menggunakan
WeeklyReview completed kanonik; client offline menggunakan row lokal. Jika target
dibuat lokal setelah completion tetapi tiba sebelum review di server, client
menahannya di outbox sampai mutation WeeklyReview accepted. Error
`WEEKLY_REVIEW_REQUIRED` bersifat deterministik untuk REST, tetapi sync client
boleh membuat change ID baru setelah review accepted.

---

## 16. SyncDevice (server-only)

Registry device diperlukan untuk acknowledgement, epoch reset, cursor expiry,
dan kebijakan retensi tombstone.
Response SyncDevice menambahkan sync_generation dari konfigurasi deployment;
field ini tidak menjadi kolom kedua pada registry.

| Field | Type | Constraint |
|---|---|---|
| `id` | UUID | PK; dibuat client satu kali per instalasi |
| `user_id` | UUID | FK → User.id |
| `name` | TEXT | Non-empty; nama yang dapat dikenali user |
| `platform` | ENUM | `windows`, `android` |
| `sync_epoch` | BIGINT | Default 1; naik saat full snapshot dimulai |
| `sync_state` | ENUM | `active`, `snapshot_required`, `snapshot_in_progress` |
| `last_ack_revision` | BIGINT | Default 0; hanya boleh bergerak naik |
| `last_seen_at` | Instant | Server time dari request sync terakhir |
| `is_revoked` | BOOLEAN | Default `false` |
| `revoked_at` | Instant nullable | Wajib terisi saat revoked |
| `created_at` | Instant | Server time |
| `updated_at` | Instant | Server time |

Unique: `(user_id, id)`. Index:
`(user_id, is_revoked, sync_state, last_seen_at)`. Device yang revoked tidak
boleh push, pull, ack, atau memulai snapshot.

Device dianggap aktif jika tidak revoked, `sync_state=active`, dan
`last_seen_at` berada dalam 180 hari terakhir. Device yang melewati batas ini
menjadi `snapshot_required`; antrean mutation dari epoch lama tidak boleh
diterapkan sebelum snapshot selesai.

Revocation device hanya memblokir ID device dan mengeluarkannya dari perhitungan
retensi; ini bukan pencabutan credential karena v1.0 memakai API key bersama.
Jika API key diduga bocor, operator wajib merotasi `User.api_key_hash`,
mereprovision key baru hanya ke device tepercaya, merevoke seluruh device lama,
dan memulai epoch/snapshot baru. API key tidak boleh ditulis ke log atau backup
domain.

---

## 17. ProcessedChange (server-only)

Ledger idempotency per item. Record ini berbeda dari cache response
`Idempotency-Key` tingkat HTTP yang boleh kedaluwarsa setelah 24 jam.

| Field | Type | Constraint |
|---|---|---|
| `sync_generation` | UUID | Generation outcome; bagian PK |
| `user_id` | UUID | FK → User.id |
| `device_id` | UUID | FK → SyncDevice.id |
| `change_id` | UUID | ID mutation dari client |
| `request_hash` | TEXT | Lowercase hex SHA-256 dari RFC 8785 canonical change item |
| `status` | ENUM | `accepted`, `rejected`, `review_required`, `recovery_required` |
| `result_json` | JSON | Response item yang pertama kali diberikan |
| `server_revision` | BIGINT nullable | Revision hasil mutation accepted |
| `processed_at` | Instant | Server time |

Primary key: `(sync_generation, user_id, device_id, change_id)`.
Field `sync_generation` adalah UUID generation server pada saat outcome dibuat. Replay dengan hash sama
memakai `result_json` tanpa revision baru: accepted diproyeksikan sebagai status
response `duplicate`, sedangkan outcome lain mempertahankan status dan isi awal. Hash berbeda
menghasilkan `IDEMPOTENCY_KEY_REUSED`. Ledger disimpan selama device masih terdaftar dan
minimal 180 hari setelah device direvoke. Untuk v1.0 personal, ledger disimpan
tanpa cleanup otomatis, sesuai API bagian 5.

Accepted, review_required, recovery_required, dan rejection deterministik disimpan. Rejection
deterministik meliputi validasi/schema, ownership/FK, conflict, resource-in-use,
invalid transition, parent tidak ada, dan deterministic-ID mismatch. Rate limit,
database timeout/deadlock, kehilangan koneksi, process crash, serta seluruh 5xx
adalah transient: transaction di-rollback dan tidak membuat ProcessedChange,
sehingga `change_id` yang sama aman di-retry. `IDEMPOTENCY_KEY_REUSED` dibaca dari
row lama dan tidak membuat row pengganti.

Validasi auth, generation, status/epoch device, kebutuhan snapshot, dan ukuran batch terjadi
sebelum loop item dan tidak membuat ProcessedChange. Payload record individual
di atas 256 KiB adalah rejection deterministik `PAYLOAD_TOO_LARGE`; batch di atas
500 item atau 2 MiB ditolak seluruhnya pada level HTTP.

---

## 18. SyncChange (server-only)

Append-only change log untuk pull cursor. Setiap row menyimpan snapshot entity
tepat pada revision tersebut, bukan membaca ulang state terbaru saat pull.

| Field | Type | Constraint |
|---|---|---|
| `revision` | BIGINT | PK, monotonic dalam generation dengan penguncian bagian 18.2 |
| `sync_generation` | UUID | Generation server saat commit |
| `user_id` | UUID | FK → User.id |
| `device_id` | UUID nullable | FK → SyncDevice.id; null untuk mutation server |
| `change_id` | UUID nullable | Mutation client pemicu; null untuk mutation server |
| `entity_type` | TEXT | Resource name dari allowlist |
| `entity_id` | UUID | ID resource |
| `operation` | ENUM | `upsert`, `delete`, `restore` |
| `record_json` | JSON | Snapshot lengkap entity atau tombstone pada revision ini |
| `changed_at` | Instant | Server time |

Unique: `(revision)`. Index: `(user_id, revision)` dan
`(user_id, entity_type, entity_id, revision)`. Satu mutation dapat membuat
lebih dari satu row, misalnya completion Pomodoro dan derived Activity; semua
efek tersebut berada dalam database transaction yang sama.

`record_json` selalu memakai salah satu wire entity schema yang sesuai
`entity_type`; delete memakai `Tombstone`. Push `upsert` membawa kandidat lengkap
field mutable untuk merge tiga versi bagian 18.1, bukan JSON Merge Patch. Field server-owned dan field
yang dihitung (`server_revision`, timestamp infrastruktur server, `saldo`, cache
streak) tidak diterima. Timestamp domain aksi yang secara eksplisit tercantum
dalam typed payload tetap diterima sesuai aturan di bagian 2. `delete` dan
`restore` wajib memakai `payload=null`; restore mengambil
snapshot domain terakhir dari tombstone dan menghasilkan record aktif baru.
`base_server_revision=null` secara eksklusif berarti create dan tidak boleh
menimpa ID yang sudah ada. Update/delete memakai revision non-null. Delete stale masuk review; restore
wajib cocok dengan revision tombstone terbaru atau ditolak CONFLICT.

### 18.1 Merge tiga versi dan kelompok atomik

Untuk upsert stale pada record aktif, server mengambil base dari SyncChange
berdasarkan user, entity, generation, dan `base_server_revision` yang sama.
Base harus milik entity tersebut; base yang sudah dibersihkan menghasilkan
`recovery_required/BASE_REVISION_UNAVAILABLE`, bukan overwrite. Client tidak
mengirim base yang dipercaya server. Server membandingkan field mutable saja,
setelah normalisasi tipe domain. Array dianggap satu nilai; array bersemantik
set dinormalisasi menurut aturan canonical domain sebelum dibandingkan.

Per kelompok: lokal=base memakai server; server=base memakai lokal;
lokal=server memakai nilai tersebut. Perubahan berbeda pada kedua sisi
menghasilkan `review_required` tanpa write domain/SyncChange. Seluruh kandidat
gabungan melewati validasi domain; bila gabungan tidak valid tetapi masing-masing
kandidat valid, review membawa alasan `merged_invariant` dan kelompok yang
terlibat. Payload lokal yang sendiri invalid tetap `rejected/VALIDATION_ERROR`.

| Entity | Kelompok atomik; nama wire kelompok di kiri |
|---|---|
| UserSettings | `timer`: seluruh `pomodoro_*`; `notification`: alarm_mode, notifications_enabled; `weekly_review`: weekly_review_time; `language`: language; `timezone`: timezone |
| Tugas | `schedule`: deadline, reminders; `lifecycle`: status, completed_at, archived_at |
| ActivityRecurrence | `schedule`: start_time, end_time, is_all_day, recurring_days, starts_on, ends_on, reminder_offsets_minutes |
| Activity manual | `schedule`: occurrence_date, start_time, end_time, is_all_day, reminder_offsets_minutes |
| PomodoroSession | `command`: seluruh field mutable; transisi dan hasil hitung divalidasi ulang oleh domain service |
| TimeboxSchedule | `link`: tugas_id, habit_id; `schedule`: start_time, end_time, hari, tanggal_spesifik, is_recurring, is_active, reminder_offsets_minutes |
| TimeboxExecution | `command`: seluruh field mutable termasuk catatan; outcome dan destination atomik |
| HabitSchedule | `schedule`: seluruh field mutable; penyesuaian rentang tetangga tetap transaction domain |
| Akun | `archive`: is_archived, archived_at |
| CategoryKeuangan | `archive`: is_archived, archived_at |
| Transaksi | `ledger`: akun_id, akun_tujuan_id, category_id, jumlah, tipe, adjustment_direction, tanggal |
| WeeklyReview | `reflection`: evaluation_text, next_week_focus_text; `lifecycle`: status, summary_snapshot, summary_cutoff_at, completed_at |
| WeeklyPlanDraft | `plan`: target_type, judul, catatan, target_date; `source`: source_entity_type, source_entity_id; `promotion`: status, promoted_entity_type, promoted_entity_id |

Field mutable lain menjadi kelompok singleton bernama field tersebut, termasuk
catatan Transaksi dan status HabitLog. Identitas/FK parent occurrence, field
server-owned, cache turunan, dan field immutable mengikuti aturan entity dan
tidak menjadi pilihan untuk melanggar invariant. Derived Activity mengikuti
source event; tidak digabung manual. Adjustment tetap immutable. Perubahan pada
lebih dari satu record dijalankan melalui domain service yang sama pada REST dan
sync. REST tetap command/partial update untuk tooling; aplikasi offline-first
mengirim mutation domain melalui outbox agar tidak melewati review.

Delete stale meminta review kelompok `lifecycle`; server tidak menggabungkan
hapus dengan edit. Upsert atas tombstone tetap ditolak. Restore eksplisit
memerlukan revision tombstone terbaru. Jika revision berubah saat resolusi,
server mengembalikan review baru, tanpa merge otomatis kedua kali. Entity yang
sudah hilang secara fisik membutuhkan recovery, bukan pembuatan ulang diam-diam.

### 18.2 Urutan commit, watermark, dan generation

Setiap writer domain server (REST, sync, materializer, cascade, restore, cleanup)
mengambil transaction lock per user sebelum membaca state atau mengalokasikan
revision, dan menahannya sampai commit/rollback. Sequence dapat memiliki gap
karena rollback; writer berikutnya tidak boleh commit mendahului writer pemegang
lock user yang sama. Pull memakai revision committed, sehingga tidak melompati
mutation yang belum commit lalu muncul terlambat.

Snapshot menggunakan lock per user yang sama. Implementer harus memperoleh
lock sebelum snapshot MVCC terbentuk: gunakan transaction READ COMMITTED,
ambil lock, lalu baca watermark dan salin record pada statement berikutnya
sambil lock tetap dipegang. Tidak memakai repeatable-read snapshot yang sudah
terbentuk ketika masih menunggu lock. Pull tidak membutuhkan lock writer;
ack hanya mengakui prefix committed yang telah diterapkan client.

Operator membuat UUIDv4 `sync_generation` pada provisioning server dan menggantinya
setiap restore/PITR sebelum membuka API. Nilai aktif berada pada konfigurasi
deployment di luar database yang direstore; startup gagal bila konfigurasi tidak
tersedia. Restart biasa tidak mengubah generation. Cache HTTP, ProcessedChange,
cursor, device response, snapshot, dan receipt terikat generation. Setelah
restore, operator mereset ack device ke 0, menginvalidasi snapshot/cache lama,
dan memaksa snapshot. Revision lama baru bermakna dalam generation asal.
Record/checkpoint yang direstore boleh mempertahankan nomor revision; server
menggunakan generation baru dan mengalokasikan revision di atas maksimum hasil
restore. SyncChange hasil restore ditandai generation baru sebagai baseline
kanonik; receipt client generation lama tetap berada di jurnal untuk review.

---

## 19. SyncSnapshot (server-only)

Snapshot session membekukan state agar pagination tetap konsisten saat mutation
baru masuk.

| Field | Type | Constraint |
|---|---|---|
| `id` | UUID | PK; snapshot ID |
| `sync_generation` | UUID | Generation session; harus cocok dengan header request |
| `user_id` | UUID | FK → User.id |
| `device_id` | UUID | FK → SyncDevice.id |
| `sync_epoch` | BIGINT | Epoch baru milik device |
| `high_watermark_revision` | BIGINT | Revision tertinggi saat snapshot dibuat |
| `record_count` | INTEGER | Jumlah SyncSnapshotItem; `>= 0` |
| `total_bytes` | BIGINT | Total byte UTF-8 canonical record; `>= 0` |
| `created_at` | Instant | Server time |
| `expires_at` | Instant | Maksimal 30 menit setelah dibuat |
| `completed_at` | Instant nullable | Terisi setelah completion berhasil |

Index: `(user_id, device_id, expires_at)`. Server membuat row ini dalam
transaction READ COMMITTED dengan lock per user bagian 18.2: ambil watermark dan
materialisasikan state setelah lock diperoleh. Urutan record stabil berdasarkan
`(entity_type, entity_id)`.

Completion mengubah device menjadi `active` dan menaikkan
`last_ack_revision` ke minimal `high_watermark_revision`. Snapshot expired
tidak dapat dilanjutkan; client harus memulai session baru.

Hanya satu snapshot `snapshot_in_progress` boleh ada per device. Start baru
menginvalidasi session lama. Session expired/completed beserta item-nya dihapus
paling lambat satu jam setelah expiry/completion.

### 19.1 SyncSnapshotItem (server-only)

Record snapshot disimpan per item agar pagination tidak memuat satu JSON blob
besar ke memory.

| Field | Type | Constraint |
|---|---|---|
| `snapshot_id` | UUID | FK → SyncSnapshot.id; cascade hard-delete saat cleanup |
| `sequence` | INTEGER | `>= 0`; urutan stabil |
| `entity_type` | TEXT | Allowlist sync |
| `entity_id` | UUID | ID resource |
| `record_json` | JSON | Typed entity record atau tombstone |
| `size_bytes` | INTEGER | 1..262144 |

Primary key: `(snapshot_id, sequence)`. Unique:
`(snapshot_id, entity_type, entity_id)`. Satu page maksimal 500 item dan maksimal
2 MiB setelah encoding envelope; server memotong page pada batas yang tercapai
lebih dahulu. Satu record di atas 256 KiB ditolak saat mutation dengan
`PAYLOAD_TOO_LARGE`: HTTP `413` pada REST biasa atau per-item rejection
deterministik pada sync push, sehingga snapshot selalu dapat dipaginasi.

Fixture sync minimum:

| Kasus | Expected response/state |
|---|---|
| Base revision cocok | `accepted`, `conflict=false`; ProcessedChange dan SyncChange commit atomik |
| Base stale, kelompok berbeda | `accepted`, `merge_applied=true`, before/accepted snapshot terisi; tidak ada edit yang tertimpa |
| Base stale, kelompok bertabrakan | `review_required`, `conflict=true`, review base/lokal/server; tidak ada SyncChange |
| Base tidak tersedia | `recovery_required/BASE_REVISION_UNAVAILABLE`; snapshot setelah salinan lokal aman |
| FK/parent invalid | Per-item `rejected`; ProcessedChange tersimpan, tidak ada SyncChange |
| HTTP 429/5xx atau transaction deadlock | Tidak ada hasil per-item/ProcessedChange untuk item terdampak; retry memakai change ID dan payload sama |
| Replay hash sama atas accepted | Revision/record/conflict awal dikembalikan sebagai `duplicate`; tidak ada revision baru |
| Replay hash sama atas rejected | Error deterministik awal tetap `rejected`; tidak ada validasi atau row baru |
| Replay change ID dengan hash berbeda | `IDEMPOTENCY_KEY_REUSED`; row awal tidak diganti |
| Mutation masuk setelah snapshot start | Tidak muncul pada page snapshot; muncul pada pull setelah high watermark saat snapshot complete |
| Record canonical tepat 262144 byte | Diterima jika batch masih dalam batas; 262145 byte ditolak per-item `PAYLOAD_TOO_LARGE` |
| Page melewati 500 item atau 2 MiB | Dipotong pada batas pertama dan dilanjutkan dengan cursor berikutnya |

---

## 20. Future Scope

### 20.1 QuickCapture

Candidate future entity; tidak masuk migration v1.0.

Fields: `id`, `user_id`, `konten`, `tipe_tujuan`, `status`,
`processed_to_id`, `processed_to_type`, dan global columns.

### 20.2 BackupExportLog

Candidate future entity; tidak masuk migration v1.0.

Fields: `id`, `user_id`, `tipe`, `file_path`, dan global columns.

## 21. Relationship Summary

```text
User
 ├─ UserSettings
 ├─ DeviceSettings ─┬─ SyncOutbox
 │                  ├─ SyncConflictNotice
 │                  ├─ SyncSnapshotStaging
 │                  ├─ SyncRecoveryQueue
 │                  ├─ SyncEntityBase
 │                  └─ SyncMutationJournal (semua local-only)
 ├─ MataKuliah ─┬─ Tugas ─ TugasChecklist
 │              └─ CourseNote
 ├─ ActivityCategory ─┬─ ActivityRecurrence ─ Activity
 │                    ├─ Activity
 │                    └─ TimeboxSchedule
 ├─ PomodoroSession ────────┐
 ├─ TimeboxSchedule ─ TimeboxExecution ─┤→ Activity
 ├─ Habit ─┬─ HabitSchedule
 │         └─ HabitLog ─────┘
 ├─ Akun ─ Transaksi
 ├─ CategoryKeuangan ─ Transaksi
 ├─ WeeklyReview ─ WeeklyPlanDraft
 ├─ SyncDevice ─┬─ ProcessedChange
 │              └─ SyncSnapshot ─ SyncSnapshotItem
 └─ SyncChange
```

---

## 22. Inisialisasi dan migrasi bersyarat

Baseline belum memiliki implementasi atau database legacy. Instalasi baru membuat
32 tabel target, constraint/index, seed deterministik, schema version awal, dan
fixture kontrak. User ID hasil provisioning lokal tetap sama saat registrasi M2.
Tidak ada backfill legacy pada instalasi baru.

Daftar konversi berikut hanya berlaku jika kelak sumber legacy terverifikasi
tersedia. Owner wajib mencatat schema asal dan pemetaan yang relevan; item tanpa
sumber legacy tidak menjadi gate instalasi baru.


Sebelum migration, operations owner memverifikasi backup PostgreSQL yang berumur
kurang dari 24 jam. Client membuat dan menguji backup SQLite sesuai
`OPERATIONS.md` sebelum mengubah schema version lokal.

Jika sumber legacy tersedia, checklist migration mencakup:

1. Backfill User dari `LOCAL_USER_ID` dan hash API key dari provisioning flow.
2. Konversi Activity recurring menjadi ActivityRecurrence plus occurrence awal.
3. Konversi status Pomodoro lama tanpa membuat sesi aktif palsu.
4. Konversi `target_hari` dan JSON array lain menjadi JSONB array, bukan JSON string.
5. Konversi nilai `hari` Timebox menjadi weekday integer 1..7.
6. Konversi PostgreSQL `Decimal` ke integer Rupiah setelah pemeriksaan nilai pecahan.
7. Pembuatan constraint dan index setelah backfill lolos validasi.
8. Drift `schemaVersion` baru, `onUpgrade`, dan migration test dari database legacy.
9. Pembuatan tabel `CourseNote`, index catatan per mata kuliah, migration test
   parent ownership, dan retensi yang independen dari deadline tugas.
10. Pembuatan `SyncDevice`, `ProcessedChange`, `SyncChange.record_json`,
    `SyncSnapshot`, dan `SyncSnapshotItem`, termasuk index dan foreign key
    server-only; jangan mempertahankan snapshot sebagai satu JSON blob.
11. Backfill change log lama menjadi snapshot record yang valid atau reset
    seluruh cursor lama ke `snapshot_required`; jangan mencampur kedua strategi.
12. Verifikasi UUIDv5 dengan golden vector yang sama di Dart dan Node.js.
13. Backfill reminder Activity/recurrence/Timebox menjadi array kosong dan
    tambahkan validasi reminder hanya untuk resource terjadwal.
14. Buat HabitSchedule awal dari `target_hari` dan batas izin legacy untuk setiap
    Habit dengan `state=active`; verifikasi tidak ada rentang schedule yang overlap
    dan sinkronkan cache `Habit.is_archived`.
15. Backfill `Akun.saldo_awal`: untuk akun tanpa transaksi gunakan saldo legacy;
    untuk akun dengan transaksi gunakan `saldo_legacy - net_ledger` setelah
    transfer dan transaksi soft-deleted dikeluarkan sesuai aturan agregasi.
    Recompute harus menghasilkan kembali saldo legacy sebelum migration diterima.
16. Tambahkan contract fixtures untuk seluruh wire entity, discriminator sync,
    lifecycle delete/restore, rolling materialization window, pause/resume Habit,
    dan pembalikan ledger transfer.
17. Buat `UserSettings` default dari konfigurasi legacy dan migrasikan timezone
    dari User jika ada. Buat `DeviceSettings` lokal tanpa menyalin API key ke
    database. Verifikasi perubahan timezone merecompute seluruh proyeksi tanggal.
18. Tambahkan fixture normatif untuk completion rate, interval overlap, formula
    saldo, deterministic/transient retry,
    merge/review conflict, batas page snapshot, serta cleanup session.
19. Migrasikan Activity `berjalan` menjadi `belum_mulai` kecuali source session
    membuktikan outcome selesai; UI tidak membawa status berjalan ke kontrak v1.0.
20. Buat ActivityCategory dan CategoryKeuangan seed deterministik, petakan
    kategori string legacy ke ID, dan verifikasi Activity/recurrence/Timebox serta
    transaksi memakai kategori yang benar.
21. Tambahkan `completed_at`/`archived_at` Tugas dan migrasikan reminder lama ke
    TaskReminder bertipe. Tugas legacy selesai memakai `updated_at` sebagai
    fallback completed time yang dicatat dalam laporan migration.
22. Tambahkan state pause Pomodoro. Session legacy yang running tetap running;
    migration mengisi pause accumulator nol dan paused_at null.
23. Tambahkan status TimeboxExecution `skipped`, field archive Akun/kategori,
    serta adjustment transaksi. Recompute saldo dan agregasi harus lulus fixture.
24. Buat tabel local-only SyncOutbox, SyncConflictNotice, SyncSnapshotStaging,
    SyncRecoveryQueue, SyncEntityBase, dan SyncMutationJournal. Migration lokal harus mempertahankan outbox legacy dan
    tidak menandainya accepted tanpa response server.
25. Buat WeeklyReview dan WeeklyPlanDraft. Instalasi existing tidak membuat review
    parsial untuk minggu migration; trigger wajib pertama jatuh pada Minggu berikutnya.
    Tambahkan default `weekly_review_time=09:00:00` pada UserSettings.

Server dan client tidak boleh mengaktifkan sync v1.0 sampai keduanya memakai
schema dan cursor protocol yang sama.

---

## 23. Golden fixtures lintas-platform

Fixture berikut normatif dan wajib menghasilkan nilai yang sama di Dart dan
Node.js, di query server dan repository lokal, serta pada contract test kedua
platform. Fixture ini melengkapi golden vector yang sudah ada (UUIDv5 pada bagian
Deterministic IDs, streak pada 11.3, completion/overlap/ledger pada 14.1) untuk
tiga area determinisme lintas-platform yang sebelumnya hanya dijelaskan prosa: DST,
recompute setelah ganti timezone, dan round-trip resolusi konflik. Untuk ID
deterministik, fixture memberi canonical name persis; UUIDv5 diturunkan memakai
namespace dan algoritma bagian Deterministic IDs, bukan nilai yang ditulis di sini.

### 23.1 Resolusi DST occurrence

Materialisasi occurrence memakai aturan bagian 2: waktu lokal yang tidak ada karena
maju DST **digeser ke instant valid pertama setelah gap** (clamp ke akhir gap, bukan
geser sepanjang durasi gap), dan waktu lokal ambigu karena mundur DST **memilih
kemunculan pertama (offset lebih awal)**. Fixture memakai `America/New_York` pada
tahun 2026: DST mulai Minggu 2026-03-08 (02:00 EST menjadi 03:00 EDT, gap
`[02:00,03:00)`) dan berakhir Minggu 2026-11-01 (02:00 EDT menjadi 01:00 EST,
`[01:00,02:00)` ambigu). EST = UTC-5, EDT = UTC-4.

TimeboxSchedule recurring dengan `start_time=02:30`, `reminder_offsets_minutes=[30]`:

| Kasus | occurrence_date | Local start diminta | planned_start_at (UTC) | reminder trigger (UTC) |
|---|---|---|---|---|
| Hari normal (EDT) | 2026-03-09 | 02:30 | `2026-03-09T06:30:00Z` | `2026-03-09T06:00:00Z` |
| Gap maju DST (tidak ada) | 2026-03-08 | 02:30 | `2026-03-08T07:00:00Z` | `2026-03-08T06:30:00Z` |
| Hari normal (EST) | 2026-11-02 | 02:30 | `2026-11-02T07:30:00Z` | `2026-11-02T07:00:00Z` |

TimeboxSchedule recurring kedua dengan `start_time=01:30` untuk kasus mundur DST:

| Kasus | occurrence_date | Local start diminta | planned_start_at (UTC) |
|---|---|---|---|
| Ambigu mundur DST | 2026-11-01 | 01:30 | `2026-11-01T05:30:00Z` |

Pada gap maju DST, `02:30` tidak ada sehingga di-clamp ke instant valid pertama
`03:00:00` EDT = `07:00:00Z`; hasil `03:30` (geser sepanjang gap) tidak sah untuk
v1.0. Kebijakan clamp ini disengaja dan berbeda dari default resolver tz umum
(java.time, Temporal, dan sejenisnya biasanya menggeser sepanjang gap); implementasi
Dart dan Node.js wajib menerapkan clamp eksplisit, bukan default library. Pada mundur DST, `01:30` terjadi dua kali; kemunculan pertama EDT (UTC-4) =
`05:30:00Z` dipilih, bukan EST (UTC-5) = `06:30:00Z`. `planned_start_at_utc` untuk
UUIDv5 TimeboxExecution memakai RFC 3339 presisi detik dari nilai UTC tersebut,
misalnya canonical name gap maju DST:
`urn:dailys:v1.0:timebox-execution:{schedule_id}:2026-03-08T07:00:00Z`.

### 23.2 Recompute setelah ganti timezone

Aturan FR-7.2 dan API-SPEC 9.8: ganti timezone tidak menulis ulang Local date atau
Instant tersimpan, tidak menggeser occurrence/execution yang sudah dimaterialisasi,
dan tidak menggeser Instant trigger notifikasi. Yang dihitung ulang hanya proyeksi
turunan: batas "hari ini", pengelompokan statistik menurut Local date, dan evaluasi
streak. Timezone baru hanya dipakai untuk occurrence setelah watermark.

Fixture memakai perubahan dari `Asia/Jakarta` (UTC+7, tanpa DST) ke
`America/Los_Angeles` (pada 2026-06-15 = PDT, UTC-7). Instant acuan tetap
`2026-06-15T02:00:00Z`.

Nilai turunan yang **berubah** setelah ganti timezone:

| Proyeksi | Input tetap | Sebelum (Asia/Jakarta) | Sesudah (America/Los_Angeles) |
|---|---|---|---|
| Batas "hari ini" pada Instant acuan | `2026-06-15T02:00:00Z` | Local date `2026-06-15` (09:00) | Local date `2026-06-14` (19:00) |
| Bucket statistik fokus PomodoroSession `start_time` | `start_time=2026-06-15T02:00:00Z` | dihitung pada `2026-06-15` | dihitung pada `2026-06-14` |

Nilai tersimpan yang **tidak berubah** (tidak ditulis ulang oleh ganti timezone):

| Field | Nilai sebelum | Nilai sesudah |
|---|---|---|
| `TimeboxExecution.planned_start_at` (Instant materialized) | `2026-06-15T02:00:00Z` | `2026-06-15T02:00:00Z` |
| `Activity.occurrence_date` (Local date materialized) | `2026-06-15` | `2026-06-15` |
| `HabitLog.tanggal` (Local date tersimpan) | `2026-06-15` | `2026-06-15` |
| Instant trigger reminder yang sudah dijadwalkan | `2026-06-15T01:30:00Z` | `2026-06-15T01:30:00Z` (dijadwalkan ulang ke Instant yang sama) |

Occurrence yang dimaterialisasi setelah watermark memakai kalender lokal
`America/Los_Angeles`. Client menghitung ulang proyeksi sebelum menampilkan hasil
baru dan tidak memperlakukan angka lama sebagai final.

### 23.3 Round-trip resolusi konflik

Aturan API-SPEC 8.4 dan bagian 18.1. Entity `Tugas` memakai kelompok atomik
`schedule` (deadline, reminders) dan `lifecycle` (status, completed_at,
archived_at). ID contoh `11111111-1111-4111-8111-111111111111`; `change_id`
berlabel `C_A`, `C_B`, `C2` adalah UUIDv4 client (bukan deterministik). Deadline
`D0=2026-09-20T10:00:00Z`, `D1=2026-09-22T10:00:00Z`.

Base pada `server_revision=10`: `schedule{deadline=D0, reminders=[H-1]}`,
`lifecycle{status=belum_dikerjakan, completed_at=null, archived_at=null}`.

Runtutan:

| Langkah | Aksi | base_server_revision | Perubahan | Hasil |
|---|---|---|---|---|
| 1 | Device A push `C_A` | 10 | `lifecycle`: status=selesai, completed_at set | `accepted`, server_revision `11`, `merge_applied=false` |
| 2 | Device B push `C_B` | 10 | `schedule`: deadline D0 ke D1; `lifecycle`: status ke progress | `review_required` |
| 3 | Resolusi push `C2` | 11 | `schedule`=D1 (merge disepakati); `lifecycle`=selesai (pilih server) | `accepted`, server_revision `12` |

Detail langkah 2 (merge tiga versi terhadap server rev 11):

- Kelompok `schedule`: lokal berubah (D0 ke D1), server tidak berubah (A hanya
  menyentuh `lifecycle`) sehingga satu sisi dan aman digabung ke D1.
- Kelompok `lifecycle`: base=belum_dikerjakan, lokal=progress, server=selesai;
  keduanya berubah berbeda sehingga konflik.
- Karena ada kelompok konflik, seluruh item menjadi `review_required`:
  `conflict=true`, `merge_applied=false`, `conflicting_groups=[lifecycle]`,
  `reviewed_server_revision=11`, `reason=field_conflict`, tanpa write domain atau
  SyncChange. Kelompok aman `schedule` **tidak** ditulis sebagian.

Detail langkah 3 (resolusi):

- Item baru `change_id=C2`, `resolution_of=C_B`, `base_server_revision=11` (sama
  dengan `reviewed_server_revision`), operasi dan entity sama dengan review.
- Kelompok aman `schedule` wajib sama dengan hasil merge yang disepakati (D1);
  kelompok konflik `lifecycle` wajib sama dengan salah satu kandidat review, di sini
  server (selesai, completed_at set), bukan nilai ketiga.
- Server memerlukan revision saat ini tepat `11`. Jika masih 11: `accepted`,
  `server_revision=12`, `accepted_record` berisi deadline D1 dan status selesai.
- Varian `server_changed`: jika sebelum langkah 3 server maju ke `12` oleh mutasi
  lain, resolusi dengan `base_server_revision=11` menghasilkan review baru
  `reason=server_changed`, kelompok terdampak dibatalkan, tanpa merge otomatis;
  keputusan berikutnya memakai `change_id` baru.

Kasus batas terkait yang hasilnya sudah ditetapkan kontrak dan wajib difixture
bersama: dua device mengubah kelompok berbeda (schedule vs lifecycle) dari base
sama menghasilkan `accepted` dengan `merge_applied=true` tanpa review; upsert atas
tombstone menghasilkan `CONFLICT`; delete stale menghasilkan review kelompok
`lifecycle`.
