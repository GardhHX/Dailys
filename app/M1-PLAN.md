# M1 Implementation Plan

Milestone **M1 - Lokal Windows: Activity + Tugas**. Sasaran (PRD Section 3.1):
Activity dan Tugas berikut pendukungnya (Mata Kuliah, checklist, CourseNote,
ActivityCategory, recurrence, reminder, settings pendukung) bekerja **offline** di
Windows; create/edit/delete dan riwayat jalan, restart mempertahankan data, dan
backup SQLite tersedia sebelum migration ketika ada data nyata.

Belum termasuk M1 (jangan diimplementasi diam-diam): Pomodoro dan Timebox (M3,
**diimplementasikan sesudah dokumen ini — lihat catatan M3 di bawah dan
`../app/UI-ALIGNMENT.md`**), Habit dan Keuangan (M4), Weekly Review (M5), serta
seluruh sync/server, Pusat Sync, review konflik, dan recovery (M2). Android juga
M2. Struktur disiapkan agar area ini bisa ditambah tanpa membongkar fondasi (PRD:
"struktur antrean dipersiapkan untuk M2").

## Catatan M3 (Pomodoro + Timebox)

M3 menambahkan `PomodoroSession` (schema 9) dan `TimeboxSchedule`/
`TimeboxExecution` (schema 10/10.1) lewat migration Drift v1 -> v2
(`core/db/database.dart`), DAO (`TimeboxDao`, `PomodoroDao`), materializer
Timebox yang menggeneralisasi `RecurrenceMaterializer` (`core/recurrence/
timebox_materializer.dart`), reminder plan Timebox pada `ReminderScheduler`
yang sama, serta tab Pomodoro dan integrasi Timebox pada Home (grid mingguan +
timeline). Seksi "Tabel Drift M1" dan "Pemetaan FR -> komponen" di atas tetap
sebagai catatan sejarah scope M1; jangan diedit untuk mencerminkan M3 — lihat
`../app/UI-ALIGNMENT.md` bagian "Update M3" untuk gap yang masih ada.

## 1. Stack dan keputusan

| Area | Pilihan | Alasan / jangkar |
|---|---|---|
| State management | Bloc/Cubit (`flutter_bloc`) | Dipilih pengguna. Cubit untuk state list sederhana; Bloc (event/state) untuk alur berstatus seperti lifecycle Tugas, scope edit recurrence, dan onboarding |
| Persistence | Drift (SQLite) | Source of truth lokal (NFR-2); schema.md sebagai kontrak tabel |
| Navigasi | go_router | PRD Section 7: bottom nav/rail 5 tab + modal + detail route |
| ID | `uuid` v4 dan v5 | UUIDv4 offline; UUIDv5 deterministik (schema "Deterministic IDs") untuk seed kategori dan occurrence recurring |
| Waktu | `timezone` + kebijakan clamp manual | Instant UTC vs Local date (schema Section 2); DST clamp eksplisit (schema 23.1), bukan default resolver |
| Reminder | `flutter_local_notifications` | FR-1.10, FR-6.4; izin diminta saat fitur pertama membutuhkannya (FR-7.13) |
| Lokalisasi | `flutter_localizations` + gen_l10n | id/en sejak M1 (NFR-7); audit penuh gate M5 |
| Tema | ThemeData dari `design/tokens.json` | Tema per-device `DeviceSettings.theme` (FR-7.15), default `system` |

## 2. Struktur folder target

```
app/
  pubspec.yaml
  analysis_options.yaml            # lints (pakai ../analysis_options.yaml sebagai basis)
  l10n.yaml                        # konfigurasi gen_l10n
  lib/
    main.dart                      # bootstrap: DI, buka DB, jalankan Splash
    app/
      app.dart                     # MaterialApp.router
      router.dart                  # go_router: rute 5 tab + global (Splash/Onboarding/Settings)
      theme/
        tokens.dart                # nilai dari design/tokens.json (light/dark)
        app_theme.dart             # ThemeData; dipilih via DeviceSettings.theme
    core/
      time/
        clock.dart                 # Instant (UTC) dan sumber waktu monotonic
        local_date.dart            # Local date vs Instant
        tz_resolver.dart           # Local<->Instant + DST clamp (schema 2, 23.1)
      ids/
        deterministic_id.dart      # UUIDv4 + UUIDv5 (namespace + canonical name)
      db/
        database.dart              # AppDatabase (Drift)
        tables/                    # tabel M1 (lihat Section 3)
        daos/                      # query per agregat
        migrations.dart            # v1 create + integrity check + backup (OPERATIONS 3)
      recurrence/
        materializer.dart          # rolling window + horizon (schema 2)
      projections/
        completion_rate.dart       # schema 14.1
        overlap.dart               # schema 14.1 (interval half-open)
      di/
        locator.dart               # get_it
    features/
      activity/                    # Home: Today list/timeline, Activity, kategori
        data/ domain/ bloc/ presentation/
      tugas/                       # Tab Tugas: list/detail/riwayat, MataKuliah, CourseNote
        data/ domain/ bloc/ presentation/
      settings/                    # bahasa, timezone, tema, config Pomodoro (disimpan), notifikasi
        data/ domain/ bloc/ presentation/
      onboarding/                  # first-run (bahasa/timezone/device; akun keuangan di-skip M1)
      splash/                      # buka DB, migration, route (FR-7.13)
    l10n/
      app_en.arb  app_id.arb
  test/
    contract/                      # golden fixtures wajib identik lintas platform
    unit/  bloc/  widget/
```

## 3. Tabel Drift M1 (dari schema.md)

Semua entity sync memakai **global columns** (schema Section 2): `id`, `created_at`,
`updated_at`, `is_deleted`, `deleted_at`, `origin_device_id`, `server_revision`.
Kolom ini ada sejak M1 untuk forward-compat M2 walau sync belum aktif. Buat sebagai
Drift mixin.

Tabel M1:

- `User`, `UserSettings` (schema 3.1; 9 field), `DeviceSettings` (schema 3.2; lokal,
  termasuk `theme`, tanpa server_revision/SyncChange)
- `MataKuliah` (schema 4), `CourseNote` (milik MataKuliah, tanpa tugas_id)
- `Tugas` (schema 5), `TugasChecklist`
- `ActivityCategory` (schema 6; enam seed deterministik UUIDv5)
- `ActivityRecurrence` (schema 7), `Activity` (schema 8)

Ditunda (jangan buat di M1): PomodoroSession, TimeboxSchedule/Execution (**dibuat
di M3 lewat migration v1 -> v2, lihat catatan M3 di atas**), Habit*,
Akun/CategoryKeuangan/Transaksi, WeeklyReview/WeeklyPlanDraft, dan seluruh tabel
Sync* server-only maupun local-only. Instalasi baru M1 membuat subset ini; migration
menuju M2+ menambah sisanya (schema 22).

Migration lokal wajib melewati langkah backup terverifikasi ketika ada data nyata
(OPERATIONS 3): stop write, `integrity_check`, consistent copy + manifest/checksum,
verifikasi, baru migrate.

## 4. Pemetaan FR -> komponen

| FR | Komponen M1 |
|---|---|
| FR-1.1, 1.3, 1.5, 1.12, 1.14 | `features/activity` domain + Activity DAO; status belum_mulai/selesai/dilewati |
| FR-1.4, 1.10 | `core/recurrence/materializer.dart` + reminder offsets pada template/occurrence |
| FR-1.6, 1.7 | Home Today: list dan timeline harian, color per kategori |
| FR-1.8 | `core/projections/overlap.dart` (warning non-blocking) |
| FR-1.9 | Navigasi tanggal (prev/next + date picker) |
| FR-1.11 | Bulk complete/reschedule Activity manual eligible |
| FR-1.13 | `core/projections/completion_rate.dart` |
| FR-1.2 | ActivityCategory manage + enam seed (UUIDv5) |
| FR-6.1-6.5, 6.7-6.11, 6.13-6.15, 6.17-6.20 | `features/tugas`: list/detail/riwayat, checklist, status/completed_at/archive, MataKuliah, CourseNote |
| FR-6.6, 6.8-6.10, 6.17 | Panel Next Deadline pada Home (overlay + panel pendamping) |
| FR-6.4 | Reminder Tugas bertipe (`calendar_day` / `relative_minutes`) |
| FR-7.1-7.2, 7.5-7.6, 7.9, 7.13-7.15 | `features/settings` + `features/onboarding` + `features/splash`; tema per-device |
| NFR-2, NFR-9 | Semua fitur jalan tanpa network; DB lokal source of truth |
| NFR-7 | Resource id/en (`l10n`) |
| NFR-13 (fondasi) | `core/time/clock.dart` monotonic (recovery timer penuh di M3) |

Ditunda: Timebox grid dan Weekly Grid Home (**dibuat di M3, lihat catatan M3 di
atas**), panel Habits Home (M4), shortcut Weekly Review aktif (M5). Placeholder
boleh ada tetapi tidak diisi desain generik.

## 5. Urutan kerja (dependency-ordered)

1. Init proyek: `flutter create`, pindahkan lints, folder skeleton, DI (`get_it`).
2. `core/time` (Instant/Local date/tz + DST clamp) dan `core/ids` (UUIDv4/v5).
   Tulis contract test lebih dahulu memakai golden vector schema 23.1 dan
   "Deterministic IDs".
3. `core/db`: global-columns mixin, tabel M1, DAO, migration v1 + integrity/backup
   (OPERATIONS 3), seed kategori UUIDv5.
4. `features/settings` (UserSettings + DeviceSettings + tema) lalu `onboarding` dan
   `splash` (buka DB, migration, route; tanpa nunggu network).
5. `features/activity`: recurrence materializer, occurrence CRUD, status, reminder,
   completion rate, overlap. Home Today (list/timeline) + navigasi tanggal.
6. `features/tugas`: CRUD, checklist, lifecycle/archive, riwayat 7 hari, reminder
   bertipe, MataKuliah, CourseNote. Panel Next Deadline pada Home.
7. Lokalisasi id/en; audit resource.
8. Reminder lokal (jadwal/cancel/reschedule) + permintaan izin saat pertama dipakai.
9. Uji: persistensi/restart, backup-sebelum-migration, plus contract test Section 6.

## 6. Contract test wajib (test/contract)

Ambil nilai persis dari kontrak; wajib identik dengan implementasi Node.js kelak.

- UUIDv5 golden vector (schema "Deterministic IDs", termasuk contoh habit-log yang
  sudah ada) dan kanonikalisasi name occurrence recurring.
- DST clamp/ambiguous (schema 23.1): `2026-03-08` 02:30 -> `07:00:00Z` (clamp),
  `2026-11-01` 01:30 -> `05:30:00Z` (kemunculan pertama).
- Recompute timezone (schema 23.2): bucket dan batas "hari ini" berubah, nilai
  tersimpan tidak berubah. (Relevan penuh saat statistik hadir; siapkan util-nya.)
- Completion rate dan overlap (schema 14.1): tabel fixture yang sudah ada.

Fixture streak, ledger, dan conflict round-trip ada di kontrak tetapi menargetkan
M4/M2; simpan sebagai test di-skip berlabel milestone agar tidak hilang.

## 7. Catatan forward-compat M2+

- Global columns dan tipe ID sudah final sejak M1 supaya M2 tidak mengganti ID
  domain (PRD Section 3.1).
- Jangan menaruh logika sync di feature; sisakan boundary repository sehingga
  outbox/journal M2 masuk di `core` tanpa mengubah UI.
- Identitas user hasil provisioning lokal stabil sebelum seed UUIDv5 dibuat.
