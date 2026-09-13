# Coverage dan gap desain

Status 13 September 2026. Kelima layar utama memiliki acuan visual dan interaksi
contoh. Seluruh fitur produk masih `direncanakan` menurut README; keberadaan paket
tidak menaikkan status implementasi atau verifikasi native.

## Coverage per layar

| Layar | Sudah dicontohkan | Belum mempunyai acuan lengkap |
|---|---|---|
| Home | Tanggal, daftar/timeline/grid, Activity, Timebox detail/start/complete/skip/reschedule, Next deadline, Habits, shortcut ke Weekly Review pada paket offline | Template recurrence penuh, scope edit occurrence/jadwal, reminder editor, kategori Activity, missed review terkelompok, data bersama lintas modul |
| Tugas | Aktif/filter/sort, detail/checklist/status, add/edit/arsip/hapus, riwayat mingguan, mata kuliah dan tambah CourseNote | Reminder editor bertipe, edit/hapus mata kuliah dan CourseNote, lifecycle resource lengkap |
| Pomodoro | Fokus/break, preset/custom, link Tugas/Habit/bebas, start/pause/resume/complete/cancel, statistik/riwayat, shortcut ke Global Settings bagian Pomodoro | Picker link modal sesuai PRD, detail sesi lengkap, alarm OS, timer background/restart |
| Keuangan | Saldo aktif, income/expense numpad, transfer create/edit/delete, filter, akun create/edit/archive/koreksi, kategori tambah/archive, pie/tren | Edit/hapus resource belum digunakan dan lifecycle kategori lengkap, flow native ledger/persistensi |
| Habit | Hari ini/lainnya/dijeda, checklist, detail heatmap, catatan/izin, schedule efektif, streak, add/edit/pause/reorder/delete | Color/icon picker penuh, lokalisasi dan accessibility native lengkap |
| Pusat Sync | Status/sukses terakhir, pending/rejected/perangkat/riwayat, registrasi tertunda, revoked, salinan/snapshot/failure/expiry, kandidat replay dan persetujuan berdampak saldo | Progress download/page nyata, backup/staging native, editor seluruh rejection, provisioning/revocation admin, receipt ambigu dan parent restore lengkap |
| Review konflik | Daftar/detail Tugas dan ledger, base/lokal/server per kelompok, bagian aman, all-server discard terpisah, submitted/accepted/server_changed/rejected | Detail semua entity/command, stale delete/explicit restore, cascade/materializer locks, seluruh rebase draft lintas entity |
| Onboarding | ID/EN form, timezone preset, registrasi berhasil/gagal, offline lanjut, akun opsional/skip, ringkasan dan Home tujuan | Picker IANA penuh, lokalisasi seluruh copy global, platform detection/secure provisioning nyata, seed/migration idempotent native |
| Weekly Review | Dua jurnal, draft/completed, ringkasan live/frozen, kandidat readonly, draft bebas/dari sumber, edit/hapus/discard, form aktivasi Tugas/Activity/Timebox, gate, fresh install, tujuh hari workload, shortcut Home/Settings offline | Missed review terkelompok, semua field/picker/reminder modul, gate bersama pada seluruh modul, SQLite/UUIDv5/outbox/snapshot kanonik native |
| Global Settings | Delapan bagian, resource ID/EN, IANA runtime picker/search, empat durasi/rentang, status simpan/gagal/retry, recompute, notifikasi vs izin OS, tema per-device, volume lokal, registrasi, ringkasan sync, Tentang dan route global | Binding system settings/izin/volume native, tzdb/alias server, build aplikasi nyata, SQLite/REST/outbox bersama dan recompute materializer |

## Perbedaan yang harus diselesaikan saat implementasi

1. **Home dan Habit tidak berbagi state pada mockup.** Home memakai seed streak
   sederhana untuk panel kecil. Implementasi harus memakai HabitSchedule/HabitLog
   dan rumus normatif pada schema, konsisten dengan layar Habit. Jangan memakai
   `base + doneHariIni` sebagai rumus produksi.
2. **Pomodoro link picker saat ini inline.** PRD Screen List menetapkan Session
   Link Picker modal. Gunakan modal pada implementasi dan pertahankan pilihan
   Tugas/Habit/sesi bebas. Style modal mengikuti form yang sudah ada.
3. **Global Settings mempunyai visual mulai v1.3.**
   [`screens/settings.md`](screens/settings.md) dan [preview](preview/settings.html)
   memisahkan sembilan field UserSettings dari izin/volume/registrasi perangkat.
   Tema `system`/`light`/`dark` kini berkontrak sebagai field per-device pada
   DeviceSettings lokal (schema 3.2; PRD FR-7.15/FR-7.6); simpan lokal seperti
   volume, bukan pada UserSettings, payload sync, atau OpenAPI. Shortcut OS berupa
   panduan Windows/Android;
   implementasi harus membuka system settings dan membaca izin native. Picker IANA
   mengikuti daftar runtime browser, dengan fallback berlabel; validasi alias/tzdb
   server bukan tanggung jawab fixture. Nomor build native belum tersedia.
4. **Reminder bukan sekadar teks produksi.** Task preview menampilkan default;
   implementasi harus memiliki editor bentuk `calendar_day`/`relative_minutes`
   sesuai kontrak. Activity tanpa waktu tidak mempunyai reminder.
5. **Weekly Review mempunyai acuan tersendiri mulai v1.2.**
   [`screens/weekly-review.md`](screens/weekly-review.md) dan
   [`preview/weekly-review.html`](preview/weekly-review.html) memuat ringkasan,
   kandidat, draft dan aktivasi. Home offline membuka route ini, tetapi seluruh
   halaman masih memakai state masing-masing. Implementasi gate semua operasi
   planning memerlukan sumber domain bersama; contoh ini hanya menahan aktivasi
   dari layar review. Workload menghitung target Tugas, bukan draft.
6. **Rentang Insight.** Pie mengikuti rentang filter; tren contoh selalu 12 bulan
   kalender. Jangan menyajikan tren seolah mengikuti rentang pie; label periode
   harus jelas pada implementasi.
7. **Navigasi preview offline memuat halaman baru.** Native harus memakai tab
   routing bersama dan mempertahankan domain/session state yang sesuai. Timer
   tidak boleh hilang saat pengguna membuka tab lain.

## Layar global yang belum dirancang

Pusat Sync, review, onboarding serta alur recovery mempunyai acuan contoh mulai
paket v1.1; detail yang belum lengkap tercatat di tabel. Weekly Review mempunyai
preview/mockup mulai v1.2; Global Settings mempunyai preview/mockup mulai v1.3.
Splash kini mempunyai spesifikasi tertulis di [`screens/splash.md`](screens/splash.md),
tetapi belum mempunyai preview/mockup; artefak visualnya masih perlu dibuat. Dengan
begitu seluruh layar global sudah memiliki minimal acuan tertulis. Jangan
menganggap gap tidak diperlukan; requirement tetap berada pada PRD/schema/API.
Tidak ada screenshot aktif untuk Splash di paket ini.

## Batas bukti

State browser sementara, tidak ada Flutter/SQLite/REST/sync, secret storage,
transaction database, provisioning, alarm/notifikasi OS, benchmark NFR, atau
timer recovery. Data contoh berlabel dan tanggal seed tetap. Bukti browser
mencakup interaksi yang tercatat, reflow dan pemeriksaan teks; bukan sertifikasi
WCAG menyeluruh atau bukti acceptance native Windows/Android.
