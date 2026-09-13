# Dailys API Contract

**Versi:** 1.0 target contract  
**Status implementasi:** seluruh endpoint belum diimplementasikan  
**Terakhir diperbarui:** 6 September 2026  
**Base URL:** `https://<vps-domain>/api/v1`  
**Canonical machine contract:** `openapi.yaml`  
**Indeks:** `README.md`  
**Operasional:** `OPERATIONS.md`

Dokumen ini menjelaskan keputusan API yang sulit dibaca dari OpenAPI. Jika
contoh Markdown bertentangan dengan `openapi.yaml`, CI harus gagal dan tim
harus memperbaiki keduanya sebelum merge.

---

## 1. Authentication

`GET /health` tidak membutuhkan auth. Endpoint lain memakai:

```http
Authorization: Bearer <api-key>
```

Server membandingkan hash API key dengan `User.api_key_hash`. Kontrak v1.0
menyebut credential ini API key, bukan JWT. Provisioning dan rotasi key berada
di luar public API v1.0.

Revoking SyncDevice tidak mencabut API key bersama dan bukan security boundary.
Jika key diduga bocor, operator harus merotasi key di server, mereprovision hanya
device tepercaya, merevoke semua device lama, lalu memaksa snapshot/epoch baru.
Secret tidak boleh muncul pada response settings, payload sync, log, atau export.

---

## 2. Response Envelope

Success:

```json
{
  "data": {},
  "meta": {
    "request_id": "uuid"
  },
  "warning": null,
  "error": null
}
```

Error:

```json
{
  "data": null,
  "meta": {
    "request_id": "uuid"
  },
  "warning": null,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request tidak valid.",
    "details": [
      { "path": "start_time", "reason": "must be before end_time" }
    ]
  }
}
```

`warning` selalu berada di top-level. Handler tidak boleh menaruh warning di
dalam `data`.

Setiap success response memakai schema entity atau projection yang spesifik.
`Resource`, `ResourceList`, objek bebas, dan `additionalProperties: true` bukan
kontrak response yang sah. Bentuk wire entity berisi field domain client-visible
ditambah `id`, `created_at`, `updated_at`, `is_deleted`, `deleted_at`, dan
`server_revision`; `user_id` serta `origin_device_id` tidak dikirim.

### Status codes

| Status | Usage |
|---|---|
| 200 | Read/update berhasil atau idempotent replay |
| 201 | Resource baru dibuat |
| 204 | Operasi sukses tanpa response body; tidak dipakai jika client membutuhkan tombstone ID |
| 400 | Format atau invariant request salah |
| 401 | API key hilang atau salah |
| 404 | Resource tidak ditemukan atau bukan milik user |
| 409 | Unique conflict, state transition tidak valid, device state salah, atau sync epoch/generation mismatch |
| 410 | Sync cursor atau snapshot session sudah kedaluwarsa |
| 413 | Push batch atau payload terlalu besar |
| 422 | Payload valid secara struktur tetapi melanggar business rule |
| 429 | Rate limit |
| 500 | Error internal dengan pesan generik |

Error code minimum: `VALIDATION_ERROR`, `UNAUTHORIZED`, `NOT_FOUND`,
`PARENT_NOT_FOUND`, `RESOURCE_IN_USE`, `CONFLICT`,
`INVALID_STATE_TRANSITION`, `IDEMPOTENCY_KEY_REUSED`,
`CURSOR_EXPIRED`, `SNAPSHOT_REQUIRED`, `SYNC_EPOCH_MISMATCH`,
`SNAPSHOT_EXPIRED`, `SYNC_GENERATION_MISMATCH`, `BASE_REVISION_UNAVAILABLE`,
`WEEKLY_REVIEW_REQUIRED`, `DEVICE_REVOKED`, `PAYLOAD_TOO_LARGE`, `RATE_LIMITED`,
dan `INTERNAL_ERROR`.

---

## 3. Data Formats

- UUID memakai lowercase canonical string.
- Instant memakai RFC 3339 UTC, contoh `2026-08-29T12:15:00Z`.
- Local date memakai `YYYY-MM-DD`.
- Local time memakai `HH:mm:ss`.
- Day boundary memakai timezone user, default `Asia/Jakarta`.
- Nominal keuangan memakai integer Rupiah.
- JSON array dikirim sebagai array, bukan string berisi JSON.
- Reminder memakai array integer menit sebelum waktu mulai, selalu unik dan non-negative.
- Reminder Tugas memakai union `calendar_day {days_before, local_time}` atau
  `relative_minutes {minutes_before}`; trigger lama tidak ditembakkan ulang.
- Unknown request field ditolak pada mutation endpoint.

Timestamp domain merekam waktu aksi, bukan menentukan pemenang conflict. Untuk
REST yang tidak meminta timestamp secara eksplisit, server mengisi
`completed_at`/`archived_at` dengan waktu penerimaan command. Saat aksi dilakukan
offline, client mengisi timestamp UTC dari device dan mengirimnya dalam typed sync
payload. Command Pomodoro memakai `occurred_at`; command Timebox memakai
`actual_start_at`, `actual_end_at`, atau `rescheduled_to` sesuai action. Server
menolak timestamp aksi lebih dari lima menit di masa depan terhadap jam server,
tetapi menerima waktu lama agar antrean offline tetap dapat disinkronkan.
`client_updated_at` dan timestamp domain tidak menentukan pemenang. Merge tiga
versi mengikuti bagian 8.4; revision mengurutkan commit dalam satu generation.

---

## 4. Pagination

List besar memakai `limit` dan opaque `cursor`.

```http
GET /activity?limit=50&cursor=<opaque>
```

```json
{
  "data": [],
  "meta": {
    "request_id": "uuid",
    "next_cursor": "opaque-or-null",
    "has_more": false
  },
  "warning": null,
  "error": null
}
```

Default `limit=50`, minimum 1, maksimum 200. Endpoint baru tidak memakai
`offset` karena mutation selama pagination dapat membuat row terlewat atau
terulang.

---

## 5. Idempotency

Endpoint berikut mewajibkan header `Idempotency-Key` UUID:

- `POST /sync/push`
- `POST /pomodoro/sessions`
- seluruh `PUT /pomodoro/sessions/:id` (pause/resume/complete/cancel)
- `POST /habit/:id/logs`
- `POST /timebox/:id/executions`
- mutation transaksi, transfer, dan koreksi saldo

Server menyimpan cache response HTTP key selama minimal 24 jam. Replay dengan
key dan payload yang sama dalam generation aktif mengembalikan response pertama. Replay key dengan
payload berbeda mengembalikan `409 IDEMPOTENCY_KEY_REUSED`.

Idempotency item sync tidak bergantung pada cache 24 jam. Setiap
`(sync_generation, user_id, device_id, change_id)` dicatat dalam `ProcessedChange` selama device
masih terdaftar dan minimal 180 hari setelah revoke. Implementasi single-user
menyimpan ledger ini tanpa batas. Karena itu retry dari device yang lama offline
tetap tidak menjalankan mutation kedua.

`request_hash` dihitung server sebagai lowercase hexadecimal SHA-256 atas UTF-8
RFC 8785 JSON Canonicalization Scheme dari satu change item lengkap. Header dan
urutan field JSON tidak menjadi bagian semantik hash.

Database unique constraint tetap menjadi pertahanan utama untuk derived
Activity:

- Pomodoro: `(user_id, source='pomodoro', source_id=session_id)`
- Habit: `(user_id, source='habit', source_id=habit_log_id)`
- Timebox: `(user_id, source='timebox', source_id=timebox_execution_id)`

---

## 6. Soft Delete

`DELETE /resource/:id` membuat tombstone:

```json
{
  "data": {
    "id": "uuid",
    "is_deleted": true,
    "deleted_at": "2026-08-29T12:15:00Z",
    "server_revision": 1234
  },
  "meta": { "request_id": "uuid" },
  "warning": null,
  "error": null
}
```

List UI mengecualikan tombstone. Sync pull tetap mengirimkannya.

### 6.1 Lifecycle relasi

Delete parent adalah domain command atomik, bukan delete row tunggal:

| Parent | Efek wajib |
|---|---|
| MataKuliah | Tombstone seluruh CourseNote, detach Tugas dengan `mata_kuliah_id=null`. |
| Tugas | Tombstone checklist; pertahankan referensi histori Pomodoro/Timebox. |
| ActivityRecurrence | Hentikan occurrence baru; pertahankan Activity lama. |
| TimeboxSchedule | Hentikan execution baru; pertahankan execution lama. |
| Habit | Tombstone HabitSchedule dan HabitLog; pertahankan derived Activity lama. |
| ActivityCategory | Tolak delete jika direferensikan; gunakan archive agar histori tetap dapat dirender. |
| Akun atau CategoryKeuangan | Tolak delete jika pernah dirujuk transaksi yang masih diretain; gunakan archive untuk menyembunyikan dari picker baru. |

Cascade menulis revision child lebih dahulu dan parent terakhir. Restore hanya
melalui sync `operation=restore`, membutuhkan revision tombstone terkini, tidak
me-restore child otomatis, dan mensyaratkan parent aktif. Detach Tugas tidak
dibalik. Konflik natural key pada restore menghasilkan `409 CONFLICT`.

---

## 7. Health

| Method | Endpoint | Auth | Response |
|---|---|---|---|
| GET | `/health` | No | status, service version, database reachability |

Health tidak mengembalikan secret, hostname internal, atau stack trace.

---

## 8. Sync Protocol

### 8.1 Device registration dan state

Setiap instalasi membuat UUID device satu kali dan mendaftarkannya melalui:

`POST /sync/devices`

```json
{
  "device_id": "uuid",
  "name": "Laptop Gardh",
  "platform": "windows"
}
```

Response mengandung `sync_generation`, `sync_epoch`, `sync_state`, dan `last_ack_revision`.
Registrasi ulang dengan ID dan payload yang sama bersifat idempotent. Device
yang direvoke menerima `409 DEVICE_REVOKED` untuk seluruh operasi sync.

State device:

- `active`: push, pull, dan ack diizinkan;
- `snapshot_required`: push ditolak sampai full snapshot dimulai;
- `snapshot_in_progress`: hanya pagination dan completion snapshot diizinkan.

Device dianggap stale setelah 180 hari tanpa request sync. Server mengubahnya
menjadi `snapshot_required`. Client mengamankan salinan lokal dan memindahkan
perubahan ke review recovery sebelum snapshot mengganti data; perubahan tidak
dibuang atau direplay dari epoch lama. Detail berada di bagian 8.9.

Semua endpoint `/sync/*` kecuali registrasi membutuhkan header
`X-Sync-Generation: <uuid>` dari response registrasi. Server memvalidasi generation
setelah auth dan sebelum lookup cache idempotency, epoch, cursor, atau item.
Mismatch mendapat HTTP 409 `SYNC_GENERATION_MISMATCH` tanpa mutation. Client
menghentikan sync biasa, mengamankan state lokal, lalu melakukan registrasi ulang
untuk membaca generation/epoch aktif. Registrasi tidak mereset device aktif atau
membuka device revoked. Device yang hilang karena restore didaftarkan ulang lalu
wajib snapshot sebelum data lama direplay; client sendiri wajib memulai snapshot
walaupun registrasi membuat row baru `active`.

`sync_generation` adalah identitas restore server, berbeda dari `sync_epoch` per
device. Operator menggantinya dengan UUID baru setelah restore, sesuai schema
18.2 dan OPERATIONS. Request lama tidak boleh diterima hanya karena epoch atau
nomor revision kebetulan sama. Registrasi pertama untuk database lokal kosong
boleh melanjutkan sync biasa; device yang sudah mempunyai data server selalu
melindungi state lokal sebelum replacement.

### 8.2 Deterministic entity IDs

Entity occurrence berikut memakai UUIDv5 dengan namespace URL standar
`6ba7b811-9dad-11d1-80b4-00c04fd430c8`:

| Entity | Canonical name |
|---|---|
| Seed ActivityCategory | `urn:dailys:v1.0:activity-category:{user_id}:{slug}` |
| Seed CategoryKeuangan | `urn:dailys:v1.0:finance-category:{user_id}:{tipe}:{slug}` |
| HabitLog | `urn:dailys:v1.0:habit-log:{habit_id}:{YYYY-MM-DD}` |
| TimeboxExecution | `urn:dailys:v1.0:timebox-execution:{schedule_id}:{planned_start_at_utc}` |
| HabitSchedule | `urn:dailys:v1.0:habit-schedule:{habit_id}:{effective_from}` |
| Recurring Activity | `urn:dailys:v1.0:activity-occurrence:{recurrence_id}:{YYYY-MM-DD}` |
| Derived Activity | `urn:dailys:v1.0:derived-activity:{source}:{source_id}` |
| WeeklyReview | `urn:dailys:v1.0:weekly-review:{user_id}:{week_start}` |
| Target hasil WeeklyPlanDraft | `urn:dailys:v1.0:weekly-plan-promotion:{draft_id}:{target_type}` |

Input UUID harus lowercase canonical. Server memverifikasi ID deterministik dan
tetap mempertahankan natural unique constraint. Golden vector lintas-platform
didefinisikan di `schema.md` dan wajib menjadi contract test Dart serta Node.js.
Untuk TimeboxExecution, `planned_start_at_utc` memakai UTC RFC 3339 presisi
detik tanpa fractional seconds.

### 8.3 Typed wire contract

Tidak ada fallback object untuk entity yang ikut sync. Mapping normatif:

| `entity_type` | Response/pull record | Push upsert payload |
|---|---|---|
| `activity_category` | `ActivityCategory` | `SyncActivityCategoryPayload` |
| `mata_kuliah` | `MataKuliah` | `SyncMataKuliahPayload` |
| `course_note` | `CourseNote` | `SyncCourseNotePayload` |
| `tugas` | `Tugas` | `SyncTugasPayload` |
| `tugas_checklist` | `TugasChecklist` | `SyncTugasChecklistPayload` |
| `activity_recurrence` | `ActivityRecurrence` | `SyncActivityRecurrencePayload` |
| `activity` | `Activity` | `SyncActivityPayload` |
| `pomodoro_session` | `PomodoroSession` | `SyncPomodoroSessionPayload` |
| `timebox_schedule` | `TimeboxSchedule` | `SyncTimeboxSchedulePayload` |
| `timebox_execution` | `TimeboxExecution` | `SyncTimeboxExecutionPayload` |
| `habit` | `Habit` | `SyncHabitPayload` |
| `habit_schedule` | `HabitSchedule` | `SyncHabitSchedulePayload` |
| `habit_log` | `HabitLog` | `SyncHabitLogPayload` |
| `akun` | `Account` | `SyncAccountPayload` |
| `category_keuangan` | `FinanceCategory` | `SyncFinanceCategoryPayload` |
| `transaksi` | `Transaction` | `SyncTransactionPayload` |
| `user_settings` | `UserSettings` | `SyncUserSettingsPayload` |
| `weekly_review` | `WeeklyReview` | `SyncWeeklyReviewPayload` |
| `weekly_plan_draft` | `WeeklyPlanDraft` | `SyncWeeklyPlanDraftPayload` |

`SyncEntityRecord`, `SyncPayloadByEntityType`, dan `SyncRecordByEntityType` pada
OpenAPI mengikat mapping ini secara machine-readable. Payload upsert tidak membawa
`id` karena ID berada di `entity_id` outer change.

Pada pull, `operation=delete` hanya membawa Tombstone; `upsert`/`restore` hanya
membawa active record dengan tipe yang sesuai. Pada push result, accepted record
harus satu keluarga dengan `entity_type`; snapshot yang digantikan selalu active
record dari keluarga yang sama. `user_settings` tidak pernah memiliki tombstone.

### 8.4 Push, merge, dan review

`POST /sync/push` menerima header `Idempotency-Key` dan `X-Sync-Generation`.
Request berisi `device_id`, `sync_epoch`, dan `changes` maksimal 500 item/2 MiB.
Setiap item memuat:

| Field | Kontrak |
|---|---|
| `change_id` | UUID immutable sejak kirim pertama; stabil untuk retry |
| `entity_type`, `entity_id` | Allowlist dan ID domain yang dimiliki user |
| `operation` | `upsert`, `delete`, `restore` |
| `base_server_revision` | Null hanya untuk create; selain itu revision base kanonik |
| `client_updated_at` | Instant aksi/audit; tidak menentukan pemenang |
| `payload` | Kandidat lengkap field mutable untuk upsert; null untuk delete/restore |
| `resolution_of` | Null untuk mutation biasa; change ID outcome review yang diselesaikan |

Unknown/server-owned fields ditolak. Server memvalidasi pasangan entity/payload,
ownership, FK, natural key, deterministic ID, dan transisi domain. Record maksimal
256 KiB; ukuran body dihitung setelah decoding content encoding. Batch berlebih
mendapat HTTP 413; record berlebih dalam batch valid mendapat rejection per item.

Server memproses item sesuai urutan array dalam transaction per item. Client
mengirim parent sebelum child untuk create/restore dan child sebelum parent untuk
delete. Dependency tidak tersedia menghasilkan `PARENT_NOT_FOUND`; setelah
perbaikan client memakai change ID baru. Satu item beserta derived records,
ledger, ProcessedChange, dan SyncChange harus atomik. Partial success hanya
berlaku antar-item.

Urutan server: ambil lock user (schema 18.2), cek ProcessedChange, validasi base,
merge/validasi domain, tulis efek dan revision jika accepted, simpan outcome,
lalu commit. Semua REST writer/materializer menggunakan lock yang sama. Revision
sequence tanpa lock tidak memenuhi kontrak commit-order.

#### Perbandingan tiga versi

Base berasal dari SyncChange milik user/entity/generation pada revision yang
diminta. Jika base tidak tersedia, server mengembalikan `recovery_required` dengan
`BASE_REVISION_UNAVAILABLE`; server tidak mempercayai snapshot base kiriman client.
Create memakai base null; ID yang sudah ada menghasilkan `CONFLICT`, bukan overwrite.

Jika base sama dengan server, validasi kandidat normal. Jika stale dan record
aktif, bandingkan base, payload lokal, dan server per kelompok schema 18.1.
Perubahan satu sisi atau nilai identik aman digabung. Perubahan berbeda pada
kelompok sama menghasilkan `review_required`. Kandidat gabungan harus valid secara
utuh; konflik invariant lintas kelompok juga membutuhkan review tanpa write parsial.

Delete stale meminta review `lifecycle`. Upsert atas tombstone ditolak `CONFLICT`.
Restore selalu eksplisit dan memerlukan revision tombstone terbaru. Child dengan
parent tombstone ditolak kecuali terminalisasi TimeboxExecution pending yang
secara eksplisit dipertahankan; reschedule tetap ditolak.

#### Outcome dan replay

Setiap result membawa `change_id`, `entity_type`, `entity_id`, `status`,
`server_revision`, `replaced_revision`, `conflict`, `merge_applied`,
`accepted_record`, `replaced_record`, `review`, dan `error`.

| Status | Field dan efek |
|---|---|
| `accepted` | Record accepted dan revision terisi; error/review null; conflict=false. `merge_applied=true` hanya bila base stale berhasil digabung; replaced record/revision berisi state server sebelum merge. Jika false, keduanya null. |
| `duplicate` | Replay accepted; record, revision, merge metadata sama seperti hasil pertama; tidak ada efek domain baru |
| `review_required` | conflict=true; review terisi; merge_applied=false; accepted/replaced record dan revision null; error null; tidak ada write domain atau SyncChange |
| `recovery_required` | error BASE_REVISION_UNAVAILABLE; conflict/merge_applied=false; review, record, dan revision null; tidak ada write domain |
| `rejected` | Error deterministik; conflict/merge_applied=false; review, record, dan revision null; tidak ada write domain |

`review` memuat `base_record`, `local_payload`, `server_record`,
`reviewed_server_revision`, `operation`, `conflicting_groups`, dan `reason`
(`field_conflict`, `merged_invariant`, `stale_delete`, atau `server_changed`).
Snapshot record sesuai entity_type; tombstone boleh hadir pada base/server,
payload null hanya pada delete/restore. Identitas dan kesesuaian revision harus
diperiksa domain service. Kelompok kosong tidak sah. Jika entity telah dibersihkan,
server mengirim recovery_required, bukan review tanpa state server.

ProcessedChange menyimpan empat outcome deterministik: accepted, review_required,
recovery_required, dan rejected. Replay body/hash sama mengembalikan outcome
awal; hanya accepted berubah label menjadi duplicate. Body berbeda dengan change
ID sama mendapat IDEMPOTENCY_KEY_REUSED. Review yang direplay mungkin sudah lama;
client harus refresh server sebelum menyusun keputusan baru.

HTTP 429, timeout/deadlock, crash, dan 5xx tidak membuat outcome deterministik;
transaction item gagal di-rollback. Retry body/change ID sama memakai backoff
1, 2, 4, 8, 16 detik, maksimum 60 detik dengan jitter; hormati Retry-After.
Auth, generation, device state/epoch, dan ukuran batch diperiksa sebelum loop
item. Cache HTTP dan ledger idempotency terikat generation.

#### Penyelesaian konflik

Client menampilkan base/lokal/server dan meminta pilihan local/server per kelompok
berkonflik; kelompok aman tetap digabung. Field identitas/immutable/hasil hitung
bukan pilihan bebas. Memilih seluruh state server boleh membuang mutation lokal
tanpa request baru setelah refresh server, dan menutup review lokal.

Pilihan yang mengubah server dikirim sebagai item baru melalui `/sync/push`,
`resolution_of` menunjuk change ID review pada user/device/generation yang sama,
dan `base_server_revision` sama dengan reviewed_server_revision. Entity dan jenis
operasi harus sesuai review. Untuk upsert, kelompok aman harus sama dengan hasil
merge yang disepakati; kelompok konflik harus sama dengan kandidat local atau
server pada review, bukan nilai ketiga. Server memvalidasi pilihan itu dari
ProcessedChange sebelum domain service. Server memerlukan revision saat ini cocok persis;
perubahan server setelah review menghasilkan review baru `server_changed`, tanpa
merge otomatis. Client memakai change ID baru untuk setiap keputusan ulang.
Jika state server sudah hilang, gunakan recovery. Resolusi yang melanggar invariant
mendapat rejection dan review lokal tetap terbuka untuk diperbaiki.

Review draft lokal yang belum pernah dikirim tidak memiliki resolution_of; client
mengirim mutation biasa yang disiapkan dari base terbaru setelah pengguna memilih.
Bila kemudian server mendeteksi benturan, server membuat review formal. Client
menahan edit record dan aksi cascade lokal yang menyentuhnya sampai hasil final;
record lain tetap bisa digunakan. Lock ini lokal, bukan lock lintas perangkat
selama pengguna berpikir. Golden vector round-trip resolusi konflik (accepted,
review_required, dan server_changed) ada di `schema.md` bagian 23.3.

### 8.5 Pull

`GET /sync/pull?device_id=<uuid>&sync_epoch=3&cursor=<opaque>&limit=200`

```json
{
  "data": {
    "changes": [
      {
        "revision": 1234,
        "entity_type": "habit_log",
        "entity_id": "uuid",
        "operation": "upsert",
        "record": {},
        "changed_at": "2026-08-29T12:15:00Z"
      }
    ]
  },
  "meta": {
    "request_id": "uuid",
    "next_cursor": "opaque",
    "has_more": false
  },
  "warning": null,
  "error": null
}
```

Server mengurutkan changes berdasarkan `SyncChange.revision`. `record` adalah
snapshot persis pada revision tersebut, bukan state entity terbaru. Cursor
mengenkode versi format, user, sync_generation, sync epoch, dan revision terakhir. Cursor
ditandatangani atau dienkripsi dan tidak boleh diurai client.

Cursor dengan epoch berbeda menerima `409 SYNC_EPOCH_MISMATCH`. Cursor yang
melewati retention menerima `410 CURSOR_EXPIRED`; server mengubah device menjadi
`snapshot_required` dan client menjalankan full snapshot.

### 8.6 Acknowledgement

`POST /sync/ack`

```json
{
  "device_id": "uuid",
  "sync_epoch": 3,
  "revision": 1234
}
```

Ack bersifat idempotent dan monotonic dalam satu generation: revision yang lebih kecil tidak boleh
menurunkan `last_ack_revision`. Client mengirim ack hanya setelah seluruh change
sampai revision tersebut berhasil diterapkan secara transaction lokal.

### 8.7 Stable snapshot

Snapshot memakai session tiga langkah, bukan cursor pull biasa.

1. `POST /sync/snapshot/start`

   Header `Idempotency-Key` wajib. Retry dengan key dan body yang sama
   mengembalikan session pertama dengan HTTP 200; session baru memakai HTTP 201.
   Penggunaan key yang sama dengan body berbeda ditolak. Key baru membuat session
   baru dan menginvalidasi session lama.

   ```json
   {
     "device_id": "uuid",
     "sync_epoch": 2
   }
   ```

   Server menaikkan epoch menjadi 3, mengubah state menjadi
   `snapshot_in_progress`, lalu mengambil lock user dalam transaction READ COMMITTED sebelum menyimpan
   `sync_generation`, `high_watermark_revision`, `record_count`, `total_bytes`, dan frozen ordered
   SyncSnapshotItem. Response:

   ```json
   {
     "data": {
       "snapshot_id": "uuid",
       "sync_generation": "uuid",
       "device_id": "uuid",
       "sync_epoch": 3,
       "high_watermark_revision": 1234,
       "record_count": 921,
       "total_bytes": 481203,
       "expires_at": "2026-08-29T12:45:00Z"
     },
     "meta": { "request_id": "uuid" },
     "warning": null,
     "error": null
   }
   ```

2. `GET /sync/snapshot/{snapshot_id}?cursor=<opaque>&limit=200`

   Mengirim active records dan retained tombstones yang sudah dibekukan, dalam
   urutan `(entity_type, entity_id)`. Satu page maksimal 500 record dan 2 MiB;
   satu record maksimal 256 KiB. Mutation yang masuk setelah start tidak
   mengubah isi snapshot. Client menulis seluruh halaman ke staging tables,
   memvalidasi jumlah dan ID, lalu mengganti seluruh synced domain state dalam
   satu transaction lokal. Snapshot tidak di-merge ke state lama; DeviceSettings
   dan secret lokal tetap dipertahankan, sedangkan UserSettings berasal dari
   snapshot. Jika proses gagal, state lama tetap aktif.

3. `POST /sync/snapshot/{snapshot_id}/complete`

   ```json
   {
     "device_id": "uuid",
     "sync_epoch": 3
   }
   ```

   Server mengubah device menjadi `active` dan menaikkan ack ke high watermark.
   Client kemudian menjalankan pull mulai setelah high watermark. Snapshot
   kedaluwarsa setelah maksimal 30 menit dan menghasilkan
   `410 SNAPSHOT_EXPIRED`; client harus memulai session baru.

Hanya satu session in-progress per device. Start baru menginvalidasi session
lama. Server menyimpan record per `SyncSnapshotItem`, bukan satu JSON blob, dan
menghapus session completed/expired beserta item paling lambat satu jam kemudian.

Sebelum replacement state yang sudah berisi data, client membuat salinan recovery
terverifikasi. Retention expiry dan PITR mengikuti review bagian 8.9; antrean lama
tidak dikirim dengan epoch/generation baru tanpa keputusan pengguna. Selama fase
salin/snapshot client menahan write lokal sementara dan mempertahankan read dari
state lama. Client membuka write setelah replacement, kecuali entity dalam review.
Client dengan database lokal kosong pada fresh install tidak membutuhkan salinan kosong; snapshot server kosong tidak menghapus kewajiban salinan jika client memiliki data.

### 8.8 Retry matrix

Semua retry biasa memakai generation, body, dan parameter identik. Perubahan generation menghentikan retry biasa dan memulai recovery. `429` menghormati `Retry-After`;
timeout/network error/5xx memakai backoff plus jitter yang sama dengan push.

| Operasi | Identity retry | Hasil aman |
|---|---|---|
| Register device | `device_id` dan body sama | Registration existing dikembalikan |
| Push | HTTP `Idempotency-Key`, change ID, dan body sama | Hasil item yang sudah commit direplay; item transient diproses lagi |
| Pull | Device, epoch, cursor, dan limit sama | Page revision yang sama dapat diterapkan idempotently |
| Ack | Device, epoch, dan revision sama | Ack monotonic tidak turun atau menggandakan efek |
| Snapshot start | `Idempotency-Key` dan body sama | Session/epoch pertama dikembalikan, bukan membuat session baru |
| Snapshot page | Snapshot ID, cursor, dan limit sama | Frozen page yang sama dikembalikan |
| Snapshot complete | Snapshot ID dan body sama | Device tetap active pada high watermark yang sama |

Pada snapshot start, setelah auth/generation cocok, server mencari replay Idempotency-Key sebelum memvalidasi
epoch request. Result key disimpan atomik bersama session sampai sedikitnya satu
jam setelah expiry/completion. Ini memungkinkan retry body dengan epoch lama
setelah response pertama hilang. Key sama dengan hash body berbeda ditolak
`IDEMPOTENCY_KEY_REUSED`; key baru mengikuti validasi epoch terbaru.

### 8.9 State lokal, Pusat Sync, dan recovery

Client memakai SyncEntityBase terpisah dari proyeksi lokal dan SyncMutationJournal
yang tetap menyimpan request/receipt setelah accepted. Outbox hanya mengirim satu
request aktif per entity. Edit berikutnya menjadi draft; client membekukan body
sebelum kirim dan tidak mengubahnya ketika retry. Accepted/pull memperbarui base
secara monotonic dalam generation, kemudian client menerapkan ulang draft sesuai
schema 3.3. Edit lebih baru tidak diganti oleh response lebih lama. Konflik rebase
membuat notice lokal dan menahan record.

Pusat Sync menampilkan pending/rejected, review belum selesai, snapshot/recovery,
dan trigger manual dalam bahasa pengguna. Membuka notice tidak menandainya selesai.
Client memperlihatkan pilihan kelompok field dan menutup review setelah accepted
atau setelah pengguna membuang perubahan lokal. Timer running tetap menghitung
waktu untuk tampilan, tetapi mutation transisi pada record konflik ditahan.

Recovery menyimpan salinan terenkripsi domain/base/outbox/konflik/jurnal sebelum
replacement. Client membandingkan receipt dan snapshot untuk mengklasifikasikan
`never_accepted`, `accepted_missing`, `superseded`, atau `manual_review`.
Tidak ada replay otomatis, termasuk never_accepted. Superseded tidak direplay;
semua kandidat replay memerlukan persetujuan, boleh massal setelah ringkasan.
Receipt ambigu tidak dianggap belum pernah diterima. Revision lintas generation
serta jam client tidak membuktikan urutan data.

Replay memakai change ID baru, base target terbaru, dan original_change_id di
jurnal/recovery lokal. Field lineage lokal tidak ditambahkan ke payload domain.
Parent dipulihkan dahulu bila disetujui; tombstone tidak dihidupkan otomatis.
Client memeriksa apakah transaksi/efek sudah tersedia dan menampilkan dampak saldo
sebelum persetujuan. Kegagalan/rejection mempertahankan item serta salinan untuk
review ulang. Panduan backup dan generation berada pada OPERATIONS bagian 4.

### 8.10 Tombstone retention

Change log dan tombstone disimpan minimal 180 hari. Tombstone hanya boleh
dibersihkan jika minimum retention sudah lewat dan seluruh device aktif sudah
memiliki `last_ack_revision` setidaknya sama dengan revision tombstone.

Device stale tidak menahan garbage collection karena wajib full snapshot saat
kembali. Device revoked juga tidak dihitung sebagai device aktif. Processed
change ledger tetap mengikuti retensi yang lebih panjang seperti Section 5.

### 8.11 Required sync tests

Integration test minimum:

1. Replay item dengan hash sama dan berbeda, termasuk setelah cache HTTP 24 jam.
2. Dua device membuat HabitLog, TimeboxExecution, dan occurrence yang sama.
3. Completion Pomodoro menghasilkan tepat satu derived Activity.
4. Stale update setelah delete tidak membangkitkan entity kembali.
5. Mutation child ditolak setelah parent dihapus.
6. Crash setelah commit tetapi sebelum response, lalu request diulang.
7. Mutation baru masuk selama snapshot dipaginasi.
8. Cursor expired dan device kembali setelah lebih dari 180 hari.
9. Ack tidak pernah bergerak mundur.
10. Tombstone tidak dibersihkan sebelum seluruh device aktif mengakuinya.
11. Rejection deterministik direplay; timeout/deadlock/5xx tidak membuat
    ProcessedChange dan retry change ID yang sama berhasil tepat sekali.
12. Dua device mengubah kelompok berbeda: merge mempertahankan keduanya.
    Kelompok sama atau invariant gabungan invalid menghasilkan review tanpa write parsial.
13. Page berhenti pada 500 item atau 2 MiB, record 256 KiB tervalidasi, session
    tunggal terjaga, dan cleanup selesai maksimal satu jam.
14. Revocation device tidak dianggap rotasi credential; runbook rotasi API key
    memaksa reprovision serta epoch baru.

---

## 9. Resource Endpoints

### 9.1 Mata Kuliah

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/matakuliah` | List aktif |
| POST | `/matakuliah` | Create |
| PUT | `/matakuliah/:id` | Partial update |
| DELETE | `/matakuliah/:id` | Soft delete |

Create body: `{ nama, dosen?, sks?, semester?, warna }`.

Course notes:

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/matakuliah/:mataKuliahId/catatan?date=&limit=&cursor=` | List CourseNote, dapat difilter tanggal |
| POST | `/matakuliah/:mataKuliahId/catatan` | Tambah CourseNote dengan tanggal pilihan user |
| PUT | `/matakuliah/:mataKuliahId/catatan/:id` | Ubah tanggal atau isi CourseNote |
| DELETE | `/matakuliah/:mataKuliahId/catatan/:id` | Soft delete CourseNote |

Server memvalidasi ownership parent Mata Kuliah. CourseNote tidak memiliki
`tugas_id` dan tidak ikut berpindah saat tugas masuk riwayat.

### 9.2 Tugas

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/tugas?status=&mata_kuliah_id=&prioritas=&sort=&limit=&cursor=` | Daftar kartu tugas aktif |
| GET | `/tugas/riwayat?start_date=&end_date=` | Riwayat tugas per hari, maksimal rentang tujuh hari |
| GET | `/tugas/:id` | Detail dengan checklist dan tautan mata kuliah |
| POST | `/tugas` | Create |
| PUT | `/tugas/:id` | Partial update |
| PUT | `/tugas/:id/archive` | Archive/unarchive manual |
| DELETE | `/tugas/:id` | Soft delete |

`GET /tugas` mengembalikan tugas yang belum masuk riwayat. Tugas overdue dengan
status selain `selesai` tetap aktif. Saat status berubah menjadi `selesai`,
service mengisi `completed_at`; membuka kembali mengosongkannya. Server menghitung
arsip otomatis pada pukul 00.00 tujuh Local date setelah Local date
`completed_at`. Archive manual mengisi `archived_at` dan unarchive mengosongkannya.
Kartu tugas memuat deadline, `countdown_hari`, status overdue, dan ringkasan
mata kuliah agar client tidak perlu menghitung ulang data tersebut.

`GET /tugas/riwayat` mengembalikan grup harian berdasarkan `history_date`.
Jika `start_date` dan `end_date` tidak dikirim, server memakai tujuh hari
terakhir termasuk hari ini. Rentang lebih dari tujuh hari ditolak dengan
`400 VALIDATION_ERROR`. Untuk arsip otomatis, `history_date` adalah Local date
`completed_at + 7 hari`; untuk arsip manual, nilainya Local date `archived_at`.
Endpoint ini tidak memindahkan atau mengubah tugas.

Field `reminders` berisi TaskReminder bertipe. `calendar_day` memakai
`days_before` dan `local_time` pada timezone user; `relative_minutes` memakai
offset dari Instant deadline. Default adalah H-7/H-3/H-1 pukul 09.00 dan 120
menit sebelum deadline. Trigger yang sudah lewat tidak dikirim ulang. Checklist
tidak mengubah status otomatis: client hanya menawarkan progress setelah item
pertama selesai dan menawarkan selesai setelah seluruh checklist selesai.

Public router dan OpenAPI v1.0 tidak memuat endpoint workload mandiri
`GET /tugas/workload-mingguan`. Weekly Review memakai projection tujuh hari yang
tertanam pada response summary; formula normatif berada di `schema.md`.

Checklist:

| Method | Endpoint |
|---|---|
| GET | `/tugas/:tugasId/checklist` |
| POST | `/tugas/:tugasId/checklist` |
| PUT | `/tugas/:tugasId/checklist/:id` |
| DELETE | `/tugas/:tugasId/checklist/:id` |

Server memvalidasi bahwa parent Tugas milik user sebelum query checklist. Riwayat
tetap dapat dibuka dan memiliki checklist. Client memakai
`history_date` dari response untuk mengelompokkan riwayat, bukan waktu request.

### 9.3 Activity

Kategori Activity/Timebox:

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/activity-categories?is_archived=false` | List kategori tersinkron |
| POST | `/activity-categories` | Create kategori custom |
| PUT | `/activity-categories/:id` | Rename, ubah warna/icon, archive/unarchive |
| DELETE | `/activity-categories/:id` | Delete hanya jika belum direferensikan dan bukan seed system |

Activity, ActivityRecurrence, dan TimeboxSchedule menerima
`activity_category_id`, bukan string kategori. Server memvalidasi ownership dan
menolak kategori arsip untuk resource baru. Rename/warna baru berlaku pada semua
tampilan dengan ID tersebut; histori tetap mempertahankan relasinya.

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/activity?date=&start_date=&end_date=&activity_category_id=&limit=&cursor=` | Occurrence list |
| GET | `/activity/:id` | Detail |
| POST | `/activity` | Create non-recurring occurrence |
| PUT | `/activity/:id` | Update satu occurrence |
| DELETE | `/activity/:id` | Soft delete |
| POST | `/activity/bulk-complete` | Complete occurrence pada tanggal |
| POST | `/activity/bulk-reschedule` | Reschedule occurrence pending |
| GET | `/activity/completion-rate?date=` | Completion rate |

Recurrence:

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/activity-recurrences` | List template |
| POST | `/activity-recurrences` | Create template |
| PUT | `/activity-recurrences/:id` | Update future occurrences |
| DELETE | `/activity-recurrences/:id` | Stop recurrence |

Update recurrence tidak mengubah Activity occurrence yang sudah dibuat.

Status Activity v1.0 hanya `belum_mulai`, `selesai`, dan `dilewati`. State
pekerjaan yang sedang berjalan dimiliki PomodoroSession atau TimeboxExecution.
Home menggabungkan TimeboxExecution dan Activity `source=timebox` dengan source ID
yang sama menjadi satu unit, lalu menampilkan planned/actual pada detailnya.

Mutation Activity dan recurrence menerima `reminder_offsets_minutes`, array
integer unik `>= 0` dengan default `[]`. Activity tanpa `start_time` dan template
all-day wajib memakai array kosong. Saat recurrence mematerialisasi occurrence,
offset disalin ke Activity sebagai snapshot. Perubahan template hanya berlaku
untuk occurrence yang belum dibuat.

Client menjadwalkan notifikasi lokal dari `start_time - offset`, membatalkan
jadwal lama saat resource diubah/dihapus, dan menjadwalkan ulang setelah pull.
Derived Activity selalu memiliki reminder kosong karena reminder dimiliki source
sebelum execution, bukan histori hasil execution.

Materializer berjalan pada app start, sesudah pull, sesudah template berubah,
dan setiap pergantian hari lokal. Rolling window inklusif berakhir pada
`today + max(30, ceil(max_reminder_offset_minutes/1440)+1)` hari. UUIDv5 dan
natural key membuat materialisasi client/server idempotent. Waktu DST yang tidak
ada digeser ke instant valid berikutnya; waktu ambigu memilih offset lebih awal.
Response recurrence menyertakan `materialized_through_date`. Edit berlaku setelah
tanggal tersebut; pause/delete menghentikan pembuatan baru dan membatalkan
notifikasi mendatang tanpa menghapus occurrence lama.

Completion rate untuk tanggal `D` (default hari ini pada timezone user) adalah
`selesai / seluruh Activity aktif`
pada `occurrence_date=D`; status `dilewati`, all-day, flexible, recurring, dan
derived tetap masuk denominator. Jika tidak ada Activity hasilnya `0.0`, bukan
100. Hasil dibulatkan satu desimal dengan round-half-up.

Overlap memakai interval half-open `[start,end)`: menyentuh boundary bukan
overlap. Kandidat adalah Activity timed yang tidak `dilewati` dan
TimeboxExecution `pending`; all-day/flexible dikeluarkan. Perbandingan memakai
Instant UTC. Activity hasil execution Timebox tidak dibandingkan dengan source
execution yang sama. Warning `SCHEDULE_OVERLAP` bersifat non-blocking dan membawa
ID pasangan serta interval irisannya. Server menaruh entity dengan key
`(entity_type, entity_id)` lebih kecil pada sisi `left`, menghapus pasangan
duplikat, lalu mengurutkan detail menurut `overlap_start`, left key, dan right key.

### 9.4 Pomodoro

| Method | Endpoint | Purpose |
|---|---|---|
| POST | `/pomodoro/sessions` | Create session dengan status `running` |
| PUT | `/pomodoro/sessions/:id` | Command pause/resume/complete/cancel |
| GET | `/pomodoro/sessions?date=&tugas_id=&habit_id=&limit=&cursor=` | History |
| GET | `/pomodoro/stats?period=daily%7Cweekly%7Cmonthly&date=` | Focus stats |

Start menerima maksimal satu dari `tugas_id` dan `habit_id`; keduanya null berarti
sesi bebas. Session command selalu memakai `{ action, occurred_at }`;
`actual_seconds` adalah hasil hitung service dan tidak diterima dari REST client.

Transition valid:

- `running → paused`: isi `paused_at`;
- `paused → running`: tambahkan durasi pause ke `accumulated_pause_seconds` dan
  kosongkan `paused_at`;
- `running → completed|cancelled`: isi `end_time=occurred_at`, lalu hitung
  `actual_seconds = max(0, end_time - start_time - accumulated_pause_seconds)`;
- `paused → completed|cancelled`: tambahkan pause terbuka
  `occurred_at - paused_at` ke accumulator, isi `end_time=occurred_at`, kosongkan
  `paused_at`, lalu hitung rumus yang sama.

`occurred_at` tidak boleh lebih awal dari timestamp transisi sebelumnya. Planned
duration tidak membatasi actual duration; session boleh selesai lebih cepat atau
lebih lambat. Client offline menjalankan rumus yang sama dan mengirim state penuh
melalui `SyncPomodoroSessionPayload`.

Replay command yang sama dengan Idempotency-Key yang sama mengembalikan hasil
pertama. Transition lain menghasilkan `409 INVALID_STATE_TRANSITION`. Relaunch
mempertahankan session paused; hanya aksi user dapat membatalkannya.

Stats hanya menghitung session `jenis=fokus`, `status=completed`, memakai
`actual_seconds`, dan mengelompokkan sesi berdasarkan Local date `start_time`.
Session break, running, paused, dan cancelled tidak masuk total fokus. Completion
sesi fokus membuat satu Activity; completion break tidak membuat Activity.
Pengaturan durasi/alarm berada di Settings global, sedangkan tab Pomodoro hanya
menyediakan shortcut dan preset override untuk satu sesi.

### 9.5 Timebox

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/timebox?hari=&tanggal_spesifik=` | Schedule list |
| POST | `/timebox` | Create schedule |
| PUT | `/timebox/:id` | Update future schedule |
| DELETE | `/timebox/:id` | Soft delete |
| PUT | `/timebox/:id/toggle-active` | Pause/resume template |
| POST | `/timebox/:id/duplicate` | Duplicate template |
| GET | `/timebox/:id/executions?start_date=&end_date=` | Execution history |
| POST | `/timebox/:id/executions` | Start atau catat outcome satu occurrence |

`POST /timebox/:id/mark-status` menjadi compatibility route selama migration dan
memanggil execution service yang sama. Route ini deprecated sejak v1.0.0, memakai
`POST /timebox/:id/executions` sebagai replacement, dan dihapus pada v2.0.0.

Create Timebox wajib mengirim `judul`, `activity_category_id`, `start_time`,
`end_time`, dan `is_recurring`. Maksimal satu dari `tugas_id` dan `habit_id`
boleh terisi. Recurring schedule wajib mempunyai `hari` dan
`tanggal_spesifik=null`; ad-hoc schedule wajib mempunyai `tanggal_spesifik` dan
`hari=null`. Update bersifat partial, tetapi server memvalidasi invariant tersebut
terhadap hasil merge, bukan payload parsial saja.

`reminder_offsets_minutes` mengikuti aturan Activity. Waktu notifikasi dihitung
dari occurrence lokal memakai timezone user. Edit schedule tidak mengubah
execution yang sudah dimaterialisasi.

Timebox memakai rolling materialization window dan aturan DST yang sama dengan
ActivityRecurrence. Response schedule menyertakan `materialized_through_date`.
Pilihan prompt **putuskan nanti** bukan status baru dan bukan mutation: dialog
ditutup, execution tetap `pending`, tidak ada timestamp outcome yang ditulis,
dan prompt boleh ditampilkan lagi paling cepat pada hari lokal berikutnya.
Client mengelompokkan beberapa execution terlewat dalam satu layar review agar
startup tidak membuka rangkaian dialog.

Execution command menerima:

```json
{
  "execution_id": null,
  "occurrence_date": "2026-09-03",
  "action": "reschedule",
  "actual_start_at": null,
  "actual_end_at": null,
  "rescheduled_to": "2026-09-04T03:00:00Z",
  "catatan": "Dipindah setelah kelas"
}
```

`planned_start_at` dan `planned_end_at` tidak dikirim sebagai keputusan bebas
client. Domain service mematerialisasikannya dari schedule, occurrence date, dan
timezone user. Client local memakai algoritma yang sama saat offline; server
memverifikasi snapshot tersebut ketika menerima sync.

Command `start` hanya berlaku pada execution pending dan mengisi
`actual_start_at` tanpa mengubah status. Untuk `completed`, `actual_end_at` wajib
dan `actual_start_at` dapat berasal dari command start atau command completion;
completion tanpa start tersimpan wajib membawanya atau menerima `422`.
Untuk `missed` dan `skipped`, actual timestamps serta `rescheduled_to` harus null.
Status `skipped` melewati satu occurrence tanpa menonaktifkan template dan tanpa
membuat Activity. Completion membuat tepat satu Activity deterministik dan
mengisi `activity_id`. Untuk `rescheduled`, `rescheduled_to` wajib. Service membuat destination execution
`pending` dalam transaction yang sama, mempertahankan durasi rencana, dan
menyimpan ID hasilnya pada `rescheduled_to_id` milik source. Response mengandung
`execution` dan `rescheduled_execution`; field kedua null untuk non-reschedule.

ID dan natural key execution memakai `(schedule_id, planned_start_at)`, sehingga
lebih dari satu execution pada tanggal yang sama tetap dapat dibedakan.
`PUT /timebox/:id/toggle-active` menonaktifkan atau mengaktifkan seluruh template;
ia tidak dipakai untuk pengecualian satu occurrence. Home menyajikan execution
dan Activity hasilnya sebagai satu unit plan/actual.

Compatibility route `/timebox/:id/mark-status` tetap menerima field legacy
`status=completed|missed|rescheduled`; route kanonik memakai field `action`.

### 9.6 Habit

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/habit?is_archived=false` | Flat list |
| POST | `/habit` | Create |
| PUT | `/habit/:id` | Update definition |
| DELETE | `/habit/:id` | Soft delete |
| PUT | `/habit/:id/archive` | Pause/resume bertanggal efektif |
| PUT | `/habit/reorder` | Reorder |
| GET | `/habit/:id/schedules?start_date=&end_date=` | Versioned target-day history |
| GET | `/habit/:id/logs?start_date=&end_date=` | Log history |
| POST | `/habit/:id/logs` | Upsert daily log |
| PUT | `/habit/:id/logs/:logId` | Update daily log |

Create Habit menghasilkan Habit dan HabitSchedule pertama. Jika update memuat
`target_hari` atau `max_izin_per_minggu`, server membuat schedule baru mulai
`schedule_effective_from`; default-nya hari ini dalam timezone user dan tidak
boleh berada di masa lalu. Server menyesuaikan rentang schedule yang
bersebelahan dalam satu transaction sehingga tidak ada overlap. Schedule yang
sudah selesai sebelum tanggal efektif tidak boleh ditimpa atau dihapus selama
masih dibutuhkan histori. Sync upsert HabitSchedule melakukan normalisasi rentang
yang sama sebagai derived mutation atomik.

Response create/update/archive selalu berbentuk `{ habit, schedule }`;
`schedule=null` hanya untuk update nama/warna/icon/urutan. Dengan demikian client
langsung menerima versi schedule yang benar tanpa menunggu pull berikutnya.

`target_hari` selalu JSON array weekday integer 1..7. Periode izin adalah minggu
kalender Senin–Minggu dalam timezone user. Hanya `skip` pada target day yang
dihitung, dengan batas `max_izin_per_minggu` dari schedule yang aktif pada
tanggal log. Streak historis selalu memakai schedule yang aktif pada tanggal
tersebut. Activity hasil check-in memakai HabitLog.id sebagai `source_id`.

Archive/resume body adalah `{ is_archived, schedule_effective_from? }` dan membuat
HabitSchedule baru dengan `state=paused|active`; field `Habit.is_archived` hanya
cache state hari ini. Tanggal paused dan non-target diabaikan. `done` pada target
day menambah satu; skip valid tidak menambah/tidak memutus; `missed` atau target
day lampau tanpa log memutus. Target day hari ini tanpa log belum memutus sampai
akhir hari. `current_streak` dan `longest_streak` dihitung ulang dari tanggal
perubahan paling awal sesuai algoritma normatif di `schema.md`.

UI menyebut action ini **Jeda/Lanjutkan**, bukan Archive. Habit List membagi
Habit aktif menjadi bagian Hari ini dan Habit lainnya; check-in hanya tersedia
pada target day. Response log menyertakan sisa izin minggu berjalan agar client
dapat menjelaskan batas sebelum user memilih skip.

Update HabitLog dan derived Activity berjalan dalam satu transaction. Perubahan
`done → skip|missed` men-tombstone Activity dengan `source_id=HabitLog.id`.
Perubahan `skip|missed → done` membuat atau me-restore Activity UUIDv5 yang sama.
Perubahan catatan pada log done memperbarui catatan Activity tanpa membuat record
baru. Pomodoro yang ditautkan ke Habit tidak menandai Habit done; client boleh
menawarkan check-in setelah sesi fokus selesai.

### 9.7 Keuangan

| Method | Endpoint | Purpose |
|---|---|---|
| GET/POST | `/akun?is_archived=false` | List/create akun |
| PUT/DELETE | `/akun/:id` | Update/archive fields atau soft delete akun belum dipakai |
| POST | `/akun/:id/koreksi-saldo` | Buat adjustment menuju saldo target |
| GET/POST | `/category-keuangan?is_archived=false` | List/create category |
| PUT/DELETE | `/category-keuangan/:id` | Update/archive atau soft delete category belum dipakai |
| GET/POST | `/transaksi` | List/create transaction |
| POST | `/transaksi/transfer` | Transfer atomic |
| PUT | `/transaksi/transfer/:id` | Update transfer atomic |
| PUT/DELETE | `/transaksi/:id` | Update income/expense; delete income/expense/transfer |
| GET | `/transaksi/summary?start_date=&end_date=` | Saldo total dan arus periode |
| GET | `/transaksi/chart/kategori?start_date=&end_date=` | Pie expense per kategori |
| GET | `/transaksi/chart/trend?start_date=&end_date=` | Trend income vs expense bulanan |

Transfer, mutation transaksi, dan update saldo berjalan dalam satu transaction.

`PUT /transaksi/:id` menolak resource bertipe transfer. Update transfer wajib
melalui `/transaksi/transfer/:id` dengan bentuk lengkap `{ akun_asal_id,
akun_tujuan_id, jumlah, tanggal, catatan? }`. Service membalik efek lama dan
menerapkan efek baru pada dua akun secara atomik. DELETE transfer membalik kedua
sisi sebelum membuat tombstone. Saldo negatif diizinkan pada v1.0.

Semua create/update/delete transaksi mengembalikan `{ transaction,
affected_accounts }`. Pada delete, `transaction` adalah tombstone; daftar akun
berisi satu akun untuk income/expense/adjustment atau dua akun untuk transfer,
dengan saldo ledger terbaru. Adjustment ditolak oleh update/delete biasa.

Create akun menerima `{ nama, tipe, saldo_awal }`; server menetapkan
`saldo=saldo_awal`. Update akun menerima `nama`, `tipe`, dan archive state.
`saldo_awal` hanya dapat diperbaiki sebelum akun memiliki transaksi retained;
`saldo` tidak pernah diterima dari mutation API. Akun arsip hilang dari picker
transaksi baru serta total saldo aktif, tetapi histori tetap menampilkannya.
Seluruh mutation ledger baru, termasuk koreksi saldo, ditolak sampai akun
di-unarchive.

Koreksi saldo menerima `{ target_balance, tanggal, catatan? }`. Service membuat
Transaksi `adjustment` sebesar selisih terhadap saldo terbaru, dengan direction
increase/decrease. Selisih nol tidak membuat transaksi. Adjustment tidak dapat
diubah atau dihapus melalui endpoint transaksi biasa; koreksi selanjutnya membuat
adjustment kompensasi. Adjustment tidak masuk income/expense/chart.

Pada sync, create Akun dengan `base_server_revision=null` wajib membawa
`saldo_awal`. Upsert Akun yang sudah ada boleh mengubah `saldo_awal` hanya jika
belum ada transaksi retained; sesudah itu nilai harus identik dengan server.
Field `saldo` dari client tidak pernah dipercaya sebagai mutation dan server
selalu mengembalikan saldo hasil perhitungan ledger.

Formula saldo adalah `saldo_awal + income - expense - transfer_keluar +
transfer_masuk + adjustment_increase - adjustment_decrease` dari transaksi aktif.
Summary menjumlah saldo akun non-arsip. Category chart hanya expense; trend hanya
income dan expense; transfer serta adjustment dikeluarkan. Grouping memakai Local
date transaksi dan nominal tetap integer Rupiah.

CategoryKeuangan menyediakan seed expense serta income. Kategori yang pernah
dipakai diarsipkan, tidak dihapus; kategori arsip hilang dari picker baru dan
tetap dapat dirender pada histori.

`start_date` dan `end_date` selalu pasangan inklusif; hanya mengirim salah satu
atau `start_date > end_date` menghasilkan `400 VALIDATION_ERROR`. Untuk summary
dan category chart, jika keduanya kosong server memakai bulan kalender berjalan.
Untuk trend, default adalah 12 bulan kalender termasuk bulan berjalan. Summary
`total_balance` selalu current balance seluruh akun aktif dan tidak dipotong oleh
periode; `total_income`/`total_expense` mengikuti periode response. Category chart
menghapus kategori bernilai nol dan mengurutkan amount menurun lalu category ID.
Trend mengembalikan setiap bulan yang beririsan dengan periode, termasuk bulan
bernilai nol, dengan `period_start` hari pertama bulan dan urutan naik.
Response summary dan kedua chart selalu mengembalikan `start_date` serta
`end_date` efektif; response chart menaruh hasil pada `data.points`.

### 9.8 Settings

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/settings` | Membaca preferensi user yang disinkronkan |
| PUT | `/settings` | Partial update preferensi user |

UserSettings memuat bahasa `id|en`, IANA timezone, durasi focus/short/long break,
interval long break, mode alarm, preference notifikasi, dan Local time Weekly
Review. Hari review tetap Minggu dan waktu default `09:00:00`. PUT bersifat partial;
response selalu bentuk penuh. Mengubah timezone tidak menulis ulang Local date
atau Instant. Occurrence/execution yang sudah dimaterialisasi tetap memakai
snapshot semula dan reminder lokal dijadwalkan ulang pada Instant trigger yang
sama. Timezone baru dipakai untuk batas "hari ini"/query dan occurrence setelah
watermark. Client merecompute streak serta proyeksi setelah menerima revision
UserSettings dan sebelum menampilkan hasil baru. Golden vector recompute timezone
ada di `schema.md` bagian 23.2.

Durasi Pomodoro baru berlaku pada phase/session berikutnya; session `running`
mempertahankan `durasi_menit` snapshot. Menonaktifkan notifikasi membatalkan
trigger lokal yang belum terkirim tanpa menghapus reminder offsets domain.
Mengaktifkannya kembali hanya menjadwalkan trigger masa depan pada device dengan
izin OS `granted`. Mode `muted` menghilangkan suara alarm, bukan visual
notification.

Permission OS, alarm volume per-device, notification handle, cursor/status sync,
dan API key adalah DeviceSettings lokal. `notifications_enabled=true` tidak
berarti izin OS granted. Snapshot mengganti synced UserSettings tetapi selalu
mempertahankan DeviceSettings dan secret lokal.

Durasi, interval long break, serta alarm hanya dikelola pada Settings global.
Tab Pomodoro membuka bagian yang sama dan tidak menyimpan konfigurasi kedua.

Pusat Sync membaca DeviceSettings, SyncOutbox, SyncConflictNotice, dan
SyncRecoveryQueue lokal. Ia menampilkan status terakhir, pending/rejected count,
review konflik belum selesai, snapshot/recovery state, serta trigger manual. UI tidak
menampilkan error code protokol mentah atau secret.

First-run onboarding menetapkan bahasa/timezone, membuat device ID, menjalankan
registrasi, serta membuat seed ActivityCategory dan CategoryKeuangan. Kegagalan
registrasi tidak memblokir penggunaan offline; Pusat Sync meminta user mencoba
lagi. Client meminta izin notifikasi saat fitur pertama memerlukannya. Splash
tidak menunggu request network.

### 9.9 Weekly Review

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/weekly-reviews?week_start=` | Membaca review satu minggu; `week_start` wajib Senin |
| POST | `/weekly-reviews` | Membuat review draft dengan ID UUIDv5 dan periode kanonik |
| PUT | `/weekly-reviews/:id` | Mengubah dua teks jurnal pada draft atau completed |
| GET | `/weekly-reviews/:id/summary` | Ringkasan live/snapshot, workload minggu depan, dan gate state |
| GET | `/weekly-reviews/:id/candidates` | Kandidat Tugas, Activity, dan Timebox tersisa |
| POST | `/weekly-reviews/:id/complete` | Membekukan snapshot dan membuka gate planning |
| GET/POST | `/weekly-reviews/:id/drafts` | Membaca atau membuat WeeklyPlanDraft |
| PUT/DELETE | `/weekly-reviews/:id/drafts/:draftId` | Mengubah atau menghapus draft yang belum promoted |
| POST | `/weekly-reviews/:id/drafts/:draftId/promote` | Membuat satu target dan menandai draft promoted |

`week_start`/`week_end` mengikuti Senin–Minggu dalam timezone user. POST review
memakai body `id, week_start`; server menghitung `week_end` dan memverifikasi ID
deterministik. Existing `(user_id, week_start)` dengan ID yang sama dikembalikan
idempotently; ID berbeda mendapat `409 CONFLICT`. Fresh install membuat review
pertama pada trigger Minggu setelah onboarding.

Update review hanya menerima `evaluation_text` dan `next_week_focus_text`.
Completed review tetap menerima perubahan dua teks tersebut. PUT tidak menerima
status, periode, cutoff, snapshot, atau completed_at. Delete, restore, reopen,
dan skip WeeklyReview tidak tersedia.

Summary draft dihitung saat request dan mengembalikan `is_frozen=false` serta
`summary_cutoff_at=null`. Command complete membawa `completed_at` dan dua teks
penuh. Server memakai completed_at sebagai cutoff, menolak waktu lebih dari lima
menit di masa depan, menghitung snapshot kanonik, menyimpan status completed, dan
mengembalikan `is_frozen=true`. Retry idempotency tidak membekukan ulang.

Response summary memuat Activity, Tugas, Pomodoro, Timebox, dan Habit sesuai
schema bagian 14.1. Keuangan tidak dimuat. `next_week_workload` selalu berisi
tujuh row termasuk hari nol. Candidates hanya mengembalikan source type/ID,
judul, tanggal, dan status; endpoint tidak mengubah source.

Draft membawa `target_type`, judul, catatan, `target_date`, dan pasangan source
opsional. Target date harus berada pada minggu setelah review. DELETE hanya sah
untuk draft dan membuat tombstone. Discard memakai PUT status discarded;
promoted/discarded tidak dapat kembali ke draft.

Promotion membutuhkan `Idempotency-Key` serta union payload create Tugas,
Activity, atau TimeboxSchedule ad-hoc. Target ID wajib UUIDv5 dari draft dan
target_type. Server membuat target serta memperbarui draft dalam satu transaction;
retry mengembalikan target yang sama. Promotion kedua, target type salah, atau ID
tidak deterministik ditolak. Jika target kemudian dihapus, draft tetap promoted.

Gate aktif sejak Minggu `weekly_review_time` sampai review completed. REST dan
sync menolak mutation planning yang membuat/mengubah jadwal pada minggu berikutnya
dengan `WEEKLY_REVIEW_REQUIRED`. Gate mencakup jadwal Activity, deadline Tugas,
Timebox, serta recurrence yang mengubah occurrence periode itu. Gate tidak
memblokir status/outcome/actual timestamps, catatan non-planning, record existing
yang tidak diubah, atau planning di luar periode. Client offline membuka gate
setelah completion lokal dan mengirim WeeklyReview completed sebelum mutation
planning minggu berikutnya; server menilai state kanoniknya sendiri.

### 9.10 API lifecycle

OpenAPI pada major version aktif hanya memuat endpoint yang tim dukung. Rencana
future tidak boleh muncul sebagai path aktif. Tim dapat menghapus endpoint yang
belum pernah masuk release public tanpa deprecation. Aturan ini berlaku pada
endpoint weekly workload mandiri sebelum rilis v1.0; proyeksinya tetap menjadi
bagian response Weekly Review.

Setiap operation public yang deprecated wajib mencantumkan:

- `deprecated: true`;
- `x-deprecated-since`, `x-deprecation-date`, dan `x-removal-version`;
- `x-replacement-operation-id` serta replacement path pada description;
- response header `Deprecation`, `X-Removal-Version`, dan `Link` pada success.

Tim hanya menghapus endpoint pada major version yang tercantum. Client owner
wajib menghapus pemakaian route sebelum release candidate major version tersebut.
Untuk v1.0, hanya `markTimeboxStatusCompatibility` yang deprecated dan versi
penghapusannya adalah `2.0.0`. Success response mengirim
`Deprecation: @1788480000`, `X-Removal-Version: 2.0.0`, dan `Link` menuju execution
path dengan ID resource aktual. Nilai `Deprecation` mengikuti Structured Field
Date RFC 9745.

---

## 10. Implementation Matrix

Belum ada implementasi. Tabel ini mencatat target, bukan hasil inspeksi runtime.

| Area | Status | Milestone |
|---|---|---|
| Mata Kuliah, CourseNote, Tugas, checklist, Activity, recurrence, kategori | Direncanakan | M1 Windows; M2 Android |
| Settings, onboarding dan identitas lokal | Direncanakan | M1 lokal; M2 registrasi/sync |
| Health, API resource M1, database server dan sync | Direncanakan | M2 |
| Pomodoro dan Timebox | Direncanakan | M3 kedua platform |
| Habit dan Keuangan | Direncanakan | M4 kedua platform |
| Weekly Review, seluruh acceptance, benchmark dan restore drill | Belum diverifikasi | M5 |

Status `diimplementasikan` membutuhkan repository/commit; `diverifikasi`
membutuhkan hasil test dan platform. Bagian 11 adalah kewajiban masa implementasi.

---

## 11. Contract Testing

CI harus menjalankan:

1. OpenAPI syntax validation.
2. Route coverage: setiap Express route memiliki OpenAPI operation.
3. Response validation untuk success dan error.
4. Integration test PostgreSQL untuk unique constraint, soft delete, dan
   idempotent derived Activity.
5. Durable sync replay setelah cache HTTP kedaluwarsa, termasuk payload hash mismatch.
6. Cursor pagination, monotonic ack, epoch mismatch, cursor expiry, dan stale-device snapshot test.
7. Two-device deterministic-ID collision untuk HabitLog, TimeboxExecution, recurring Activity, dan derived Activity.
8. Stable snapshot test saat mutation baru masuk di tengah pagination.
9. Tombstone acknowledgement, stale update setelah delete, parent-delete/child-push, dan retention test.
10. Crash-after-commit replay test untuk membuktikan response hilang tidak menggandakan mutation.
11. Tugas history test untuk overdue belum selesai, completed + tujuh hari,
    archive/unarchive manual, typed reminders, dan timezone user.
12. CourseNote ownership melalui Mata Kuliah, soft delete, filter tanggal, dan sync replay test.
13. Reminder invariant test untuk no-start Activity, recurrence snapshot isolation,
    Timebox timezone conversion, update, delete, dan pull rescheduling.
14. Timebox execution test untuk start, completed/missed/skipped constraints,
    atomic reschedule destination, collision, dan idempotent replay.
15. HabitSchedule test untuk non-overlapping effective ranges, edit histori,
    batas izin Senin–Minggu, serta streak lintas perubahan schedule.
16. Account contract test yang membatasi koreksi `saldo_awal`, menolak mutation
    `saldo`, serta membuktikan archive dan adjustment menjaga saldo/aggregation
    setelah create/update/delete/transfer/koreksi.
17. Typed-response dan sync-discriminator test untuk setiap entity type; tidak
    ada success payload bebas atau pasangan `entity_type/payload` yang lolos salah.
18. Lifecycle matrix test untuk cascade/detach/restrict, urutan revision, restore
    parent-child, dan natural-key conflict.
19. Rolling materialization/DST test serta reminder cancel/expiry di client.
20. Habit streak golden table meliputi pause/resume, non-target, izin mingguan,
    missing log, hari ini, perubahan schedule, dan timezone.
21. Transfer update/delete/replay test membuktikan pembalikan ledger tepat sekali
    pada kedua akun.
22. Golden calculation test untuk completion rate termasuk zero denominator,
    half-open overlap lintas Activity/Timebox, dan seluruh komponen formula saldo.
23. Settings test untuk validation bounds, ID/EN, IANA timezone, full response,
    cross-device sync, immutable running Pomodoro, cancel/rehydrate notification,
    local DeviceSettings preservation, dan secret exclusion.
24. Sync retry classification, bukti merge/review per kelompok, snapshot page
    byte/item limit, single-session invalidation, serta cleanup test.
25. API lifecycle test menolak future route pada OpenAPI v1 dan mewajibkan
    metadata deprecation, replacement, header, serta removal version.
26. ActivityCategory test untuk seed deterministic, rename/color sync, archive,
    dan referential delete restriction.
27. Pomodoro command test untuk pause/relaunch/resume, accumulator, terminal dari
    paused, exclusive Tugas/Habit link, serta statistik lintas tengah malam.
28. HabitLog correction test untuk tombstone/restore Activity deterministik dan
    perubahan catatan tanpa duplikasi.
29. Local sync-state test untuk crash outbox, snapshot staging atomic replace,
    review per kelompok, recovery retention, dan PITR dengan mutation acknowledged.
30. Weekly Review test untuk trigger Minggu, fresh install, snapshot cutoff,
    gate offline/server, kandidat tersisa, immutable snapshot, dan edit teks completed.
31. WeeklyPlanDraft test untuk batas minggu target, pasangan source, state
    transition, UUIDv5 promotion, atomic target creation, dan retry dua device.

### 11.1 Fixture tambahan hasil wawancara

| Skenario | Hasil wajib |
|---|---|
| Judul tugas berubah di Windows, deadline di Android | accepted merge; kedua kelompok bertahan |
| Deadline berubah berbeda pada kedua perangkat | review_required; domain/revision tidak berubah |
| Kelompok berbeda menghasilkan kandidat gabungan invalid | review reason merged_invariant; tidak ada write parsial |
| Server berubah setelah pengguna memilih | review baru server_changed; pilihan lama tidak menimpa |
| Edit B saat request A in-flight | Response A tidak menghapus B; draft B dikirim setelah rebase |
| Writer revision 101 lambat, writer 102 menunggu | 102 tidak dapat commit dahulu untuk user sama; pull tidak melewatkan 101 |
| Snapshot menunggu writer | Watermark dan state dibaca setelah lock; mutation tersebut tidak hilang |
| Base revision dibersihkan | recovery_required; tidak terjadi overwrite |
| PITR menghilangkan accepted mutation yang telah keluar outbox | Jurnal dan salinan menyediakan perubahan acknowledged untuk review |
| Epoch kebetulan sama setelah restore | Generation berbeda tetap menolak request lama sebelum cache replay |
| Review/recovery request diulang | Outcome deterministik sama, tanpa revision atau efek ledger baru |
| Recovery transfer sudah terwakili | Tidak membuat transaksi/efek saldo kedua |
| Snapshot atau replay gagal | Salinan/jurnal dan keputusan pengguna tetap tersedia |
| Fresh install hari Rabu | Review pertama dibuat pada trigger Minggu berikutnya; tidak ada review parsial |
| Review draft dibuka sebelum trigger | Jurnal dapat ditulis; planning belum diblokir sebelum Minggu pada waktu review |
| Gate aktif dan Activity minggu depan dibuat | WEEKLY_REVIEW_REQUIRED; Activity minggu berjalan dan status tetap dapat diubah |
| Complete offline dengan dua teks terisi | Snapshot/cutoff tersimpan atomik dan gate lokal terbuka tanpa network |
| Record sumber dikoreksi setelah complete | Snapshot lama tidak berubah; modul sumber menampilkan koreksi |
| Draft promotion diretry atau dilakukan dua device | Tepat satu target UUIDv5; draft tetap promoted |
