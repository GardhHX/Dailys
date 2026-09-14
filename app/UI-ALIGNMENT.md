# Penyelarasan UI aplikasi — 14 September 2026

Acuan yang dibaca: `../DESIGN.md`, `../design/README.md`, `../design/GAPS.md`, spesifikasi Home/Tugas/onboarding/Settings/Splash, HTML preview terkait, dan PNG di `../design/mockups/`. Token bersama tetap dari `../design/tokens.json`. Folder acuan tidak diubah.

## Perubahan yang selesai

- Home: wordmark/app bar, rail desktop 142/76 px, navigasi bawah pada lebar ≤680 px, judul/tanggal/timezone, CTA tambah aktivitas, pemilih Daftar/Timeline, strip tujuh hari, serta kolom jadwal dan Next deadline. Tanggal dan data berasal dari database lokal. Timeline memakai waktu pada timezone pengguna.
- Next deadline membaca Tugas aktif dari Drift, mengeluarkan tugas selesai/diarsipkan, mengurutkan deadline dan tetap menampilkan overdue. Panel menyediakan keadaan kosong, memuat, dan gagal dengan retry. Kartu Home saat ini hanya membaca data; route detail Tugas tersedia melalui tab Tugas.
- Tugas: implementasi existing ditemukan pada branch `feat/m1-tugas`, commit `b3efe47`, lalu source Tugas/DAO/tes terkait dibawa ke checkout kerja tanpa mengganti perubahan Home/Settings. Navigasi Home kini membuka Tugas. Daftar mengikuti hierarki judul/tambah, tiga tab, filter/sort, dan grid dua kolom desktop/satu kolom ponsel. Kartu menampilkan status, prioritas, deskripsi, ringkasan checklist, deadline/countdown dan course; overdue memakai token danger.
- Detail Tugas memakai route kembali, deskripsi/checklist dan panel metadata kanan pada desktop, bertumpuk pada ponsel. Pengingat ditampilkan dari resource sebenarnya. Status, edit, arsip dan konfirmasi hapus mempertahankan DAO/lifecycle existing. Checklist penuh hanya menawarkan perubahan status. Modal tugas/course/note dibatasi lebarnya dan dapat discroll; tanggal/jam deadline memakai timezone pengguna. CourseNote berada pada detail mata kuliah, dengan tanggal dan isi.
- Race pemuatan detail Tugas/course diperbaiki agar route tidak tertutup sebelum data pertama hadir. Daftar Tugas memiliki gagal/retry. Panah riwayat dan aksi checklist mendapat label aksesibilitas.
- Form Activity menjadi dialog berbatas lebar, memakai autofocus, tombol tutup dan Escape. Form dan pengulangan yang sudah ada dipertahankan.
- Onboarding: komposisi form dan panel indigo 280 px pada desktop; form dahulu pada ponsel. Stepper menunjukkan dua tahap yang benar-benar tersedia. Picker timezone memakai daftar tzdb aplikasi dan lebar terukur.
- Settings: daftar bagian kiri dan satu panel isi pada desktop, susunan bagian bertumpuk pada ponsel, divider antarbagian dan dua kolom durasi Pomodoro bila ruang cukup. Bahasa, timezone, tema dan volume tetap terhubung ke penyimpanan yang sudah ada. Picker tidak memakai lebar infinity.
- Tema: tipografi 14/15/19/28–30 px, warna semantik, permukaan opaque, radius, border input aktif/fokus dan kontrol mengikuti acuan. Splash memakai wordmark dan live region status yang dapat discroll pada layar pendek.
- Gagal membaca Home/Settings kini menghasilkan pesan dan retry. Banner overlap membungkus teks.

Tujuan perubahan layout: jadwal mendapat ruang utama; deadline menjadi pendamping; panel onboarding menjelaskan penyimpanan lokal; daftar Settings membantu mencapai bagian terkait. Tidak ditambahkan dekorasi atau statistik baru.

## Verifikasi

- `flutter analyze --no-pub`: lulus.
- `flutter test --no-pub`: 95 tes lulus setelah integrasi Tasks; log di `build/tasks-qa-final-log.txt`. Verifikasi ulang setelah label aksesibilitas: 95 tes lulus, log `build/tasks-verify-log.txt`. Pemeriksaan awal sebelum integrasi Tasks: 80 tes lulus.
- Pengujian UI: Home, Tugas, onboarding dan Settings pada 320, 440, 736, 860 dan 1408 px, dua tema, ID pada ukuran normal dan EN pada teks 200%. Memeriksa exception layout descendant, judul panjang, deadline terisi, dialog/autofocus/Escape, gagal baca Home/Settings, serta Splash gagal pada layar pendek.
- Flow Tasks dengan database pengujian: navigasi Home, kartu terisi/overdue/judul panjang, detail, checkbox tanpa perubahan status otomatis, filter status/clear, simpan tugas, serta tambah CourseNote bertanggal. Detail, kartu dan modal note diperiksa pada 320/1408 px dalam dua tema dengan teks EN 200%; modal tugas/tab riwayat/course juga diperiksa dalam matrix lima lebar.
- Overflow kontrol tanggal pada 320 px/teks 200% ditemukan dan diperbaiki dengan reflow kontrol.
- `flutter build windows --release --no-pub`: menghasilkan `build/windows/x64/runner/Release/dailys.exe`.
- PNG Flutter dengan font Segoe UI dan Material Icons tersimpan di `build/ui-qa/`. Data terisi dalam PNG ini merupakan fixture database pengujian, bukan data pengguna.
- Verifikasi ulang Windows: build release terbaru membuka Tasks/riwayat/course kosong sesuai data lokal yang tersedia; modal tugas/course memiliki autofocus, Tab berpindah fokus, Escape menutup tanpa menyimpan, navigasi minggu berhasil. Tidak ditambahkan fixture ke database pengguna. Detail terisi/CRUD dibuktikan pada database tes, bukan melalui data pengguna.
- Home dan Settings tema gelap diperiksa langsung pada build release Windows dengan data pengguna yang sudah ada. Build debug lama berbeda dari checkout dan tidak dipakai sebagai bukti hasil akhir.

## Gap yang masih ada

Kesimpulan pemeriksaan awal bahwa Tugas belum diimplementasikan dikoreksi: source berada pada branch `feat/m1-tugas`, bukan `main`. Checkout kerja sekarang mempunyai UI Tugas beserta CRUD/checklist/riwayat/course/note. Keuangan dan Habit masih disabled karena belum mempunyai layar pada checkout ini.

Gap Tugas: editor reminder bertipe belum tersedia; checklist ditambah pada detail, belum pada modal add/edit; edit isi CourseNote belum tersedia. Pesan gagal pada course/note belum mempunyai retry lengkap; kegagalan baca/simpan detail belum mempunyai presentasi lengkap. Belum ada audit keyboard/kontras lengkap seluruh operasi.

**Update M3 (Timebox + Pomodoro):** Home Timebox tidak lagi placeholder in-memory — `TimeboxSchedule`/`TimeboxExecution` (schema 10/10.1) tersimpan di Drift, dimaterialisasi lewat `TimeboxMaterializer`/`TimeboxMaterializationRunner`, dan tab Pomodoro (`TimeboxSchedule`/`PomodoroSession`, schema 9) kini punya layar nyata (timer, session link picker, statistik, riwayat) alih-alih tombol disabled. Agenda mingguan (grid Senin-Minggu) dan timeline harian menampilkan block Timebox pending berdampingan dengan Activity, quick-add klik-sel, prompt missed/reschedule/masih-berlaku, serta nonaktifkan-template vs lewati-occurrence. Panel Habits pada Home tetap in-memory (Habit menunggu M4) dan Weekly Review tetap seed tampilan — keduanya di luar scope M3 ini.

Gap yang sengaja tidak masuk scope M3 ini: quick-add grid belum mendukung drag (hanya klik); reminder-offset belum punya editor UI (schedule tersimpan `[]` dari form tambah, sama seperti Tugas yang juga belum punya editor reminder — lihat gap Tugas di atas); Pomodoro belum punya notifikasi background native/alarm suara berbeda untuk fokus vs istirahat (FR-2.5/2.6) — timer dihitung dari `start_time`/`paused_at` sehingga tetap akurat selama proses hidup (termasuk saat window di-minimize), tapi belum bertahan dari process kill, konsisten dengan catatan gap NFR-13 pada `design/screens/pomodoro.md`. Detail deadline dan Weekly Review lengkap masih di luar scope (M5).

Onboarding belum memiliki registrasi perangkat dan akun pertama. Settings belum mempunyai Pusat Sync/Tentang, binding izin OS, maupun status simpan/retry per field lengkap seperti preview. Splash belum menyamai seluruh presentasi kegagalan/panduan pemulihan pada contoh. Perubahan ini tidak mengimplementasikan gap domain tersebut.

Pengujian widget dua tema bukan bukti Android native. Audit kontras rendered lengkap, urutan keyboard seluruh flow, serta setiap tahap startup/migration/timer native belum diverifikasi dalam tugas ini. Hasil bukan klaim kesetaraan seluruh sebelas layar contoh. Pekerjaan M3 di atas diverifikasi lewat `flutter analyze`/`flutter test` dan contract test baru (lihat commit terkait); tidak ada screenshot/build Windows baru yang dihasilkan untuk M3 (lingkungan kerja ini tidak punya target Windows).
