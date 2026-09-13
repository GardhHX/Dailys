# Splash: design spec

Status: **spesifikasi tertulis**, diperbarui 13 September 2026 untuk paket v1.3.
Preview, mockup dan implementasi Splash belum tersedia. Spesifikasi ini
menjadi acuan tertulis untuk membangun `../preview/splash.html` dan
`../mockups/splash-desktop.png` / `../mockups/splash-mobile.png` berikutnya. Sampai
artefak itu dibuat, ikuti spesifikasi ini bersama token `../tokens.json`. Lihat
[`GAPS`](../GAPS.md). Otoritas tetap PRD → schema → API-SPEC → OpenAPI → desain.
Mode antislop **DURING**, mengikuti pilihan pengguna sebelumnya.

## Design Read dan alasan

Startup transien aplikasi personal mahasiswa, dengan visual Dailys:
netral hangat, indigo berkontras tinggi, Segoe UI;
**ENERGY 2 / RHYTHM 2 / MOTION 1**. Komposisi dipersempit menjadi satu identitas
dan satu status karena pengguna belum melakukan pekerjaan di layar ini.

## Tempat dan hierarki

Layar pertama saat aplikasi diluncurkan, sebelum shell dan sebelum onboarding.
Tanpa app bar, rail, atau bottom navigation. Isi minimal: identitas teks Dailys,
satu status singkat, dan indikator progress hanya bila ada pekerjaan yang benar
benar berjalan (migration). Tidak ada logo bitmap rekaan, ilustrasi, slogan, atau
animasi dekoratif; motion mengikuti MOTION 1.

Splash bersifat transien. Ia menutup segera setelah tugas startup selesai dan
mengarahkan ke tujuan yang tepat. Splash tidak menunggu VPS, tidak melakukan
request network, dan tidak meminta izin notifikasi.

## Layout desktop dan ponsel

Windows mempertahankan title bar native; Android menghormati safe area/system bars.
Tidak menambahkan toolbar prototype ke UI produk.

| Elemen | Desktop | Ponsel |
|---|---|---|
| Permukaan | Background memenuhi area client | Background memenuhi area aman |
| Kelompok isi | Maksimum 420 px, tengah horizontal/vertikal | Lebar tersedia, padding horizontal 24 px, tengah area aman |
| Identitas | Teks `dailys.`, 30 px, weight 750 | Teks `dailys.`, 28 px, weight 750 |
| Status | 14 px/1.5, rata tengah, jarak 24 px setelah identitas | Sama, membungkus tanpa pemotongan |
| Progress terukur | Maksimum 280 px, tinggi 4 px; jarak 16 px setelah status | Maksimum 280 px mengikuti ruang tersedia |
| Kegagalan | Kelompok maksimum 480 px, pesan dan aksi rata kiri | Isi menumpuk; aksi penuh lebar bila perlu |

Jalur normal:

```text
             dailys.

        Membuka data lokal…
```

Kegagalan database terkunci, bukan pesan universal semua error:

```text
dailys.

Data lokal belum dapat dibuka
Tutup aplikasi lain yang memakai data ini,
lalu coba kembali.

[Coba lagi]   [Panduan pemulihan]
```

Minimum lebar konten 320 px. Pada teks 200% atau layar pendek, kelompok isi boleh
bergeser ke atas dan halaman scroll vertikal; jangan memaksakan centering yang
memotong pesan/aksi. Tidak ada scroll horizontal atau tinggi panel tetap.

## Token visual

Gunakan [`tokens.json`](../tokens.json), bukan palette baru.

| Keputusan | Token/penerapan | Alasan |
|---|---|---|
| Background | `background`: #f5f4f0 / #17181e | Menghubungkan startup dengan permukaan utama Dailys |
| Identitas | `text`: #20212b / #f4f4fa | Fokus pada merek yang sudah ada tanpa asset baru |
| Status | `textMuted`: #595a68 / #b9bbc9 | Hierarki sekunder dengan kontras teks tinggi |
| Progress/aksi utama | `accent`, `onAccent` | Indigo menandai pekerjaan nyata atau retry |
| Kegagalan | `danger` plus judul/alasan | Makna terbaca tanpa mengandalkan warna |
| Font | Segoe UI, fallback sistem sesuai token | Konsisten dengan Windows dan lokalisasi Dailys |
| Spacing | 24 px identitas/status, 16 px status/progress, 12 px antaraksi | Memisahkan identitas, pekerjaan dan keputusan |
| Radius | 6 px tombol; 3 px ujung progress | Mengikuti token kontrol |

Tanpa kartu, modal atau shadow pada jalur normal maupun pesan gagal. Tidak ada
gradient, glass, glow, pola latar, avatar, tagline, statistik atau nomor build.
Tidak ada animasi logo, spinner dekoratif, fade berulang atau transisi wajib.
Progress berubah ketika service melaporkan hasil nyata.

Tema mengikuti sistem sampai preferensi tampilan yang sah dapat dibaca. Tema
berkontrak sebagai field per-device `DeviceSettings.theme` (schema 3.2; PRD
FR-7.15); Splash membacanya lokal saat membuka database, sebelum shell tampil, dan
menerapkannya tanpa flash permukaan terang pada mode gelap. Tema tidak berada pada
UserSettings atau payload sync.

## Tugas startup

Urutan yang dijalankan sebelum shell tampil (PRD FR-7.13):

1. **Buka database lokal** dan baca schema version.
2. **Migration bila perlu.** Bila ada data nyata, ikuti OPERATIONS bagian 3:
   `PRAGMA integrity_check`, buat salinan konsisten via SQLite backup API dengan
   manifest/checksum, verifikasi salinan, baru jalankan migration. Instalasi baru
   membuat schema awal, constraint/index dan identitas user lokal yang stabil.
   Identitas tersedia sebelum seed UUIDv5 dibuat; koordinasikan seed idempotent
   dengan onboarding, tanpa backfill legacy yang tidak terverifikasi (schema §22).
   Ikuti scope milestone: setup akun Keuangan baru tersedia mulai M4.
3. **Recovery timer** Pomodoro. Pulihkan sesi `running`/`paused` dari Instant UTC
   tersimpan dan pause accumulator setelah relaunch; monotonic clock dipakai selama
   process hidup. Sesi paused tetap paused dan tidak mengurangi
   sisa waktu. Perbaikan state timer selesai maksimal 500 ms setelah frame pertama
   (OPERATIONS 7.3, NFR-13).
4. **Materialisasi ringan** occurrence lokal boleh dimulai tanpa memblokir tampilan;
   pekerjaan yang bergantung pull dijalankan setelah shell dan koneksi tersedia.

Urutan kesiapan ini bukan penghitung langkah/persentase UI. Service lokal mengelola
transaksi, schema version dan crash recovery; widget Splash tidak membuat aturan
database sendiri. Shell hanya terbuka setelah schema usable dan restore yang
diperlukan terverifikasi; proyeksi yang belum siap tidak ditampilkan sebagai final.

## Rute keluar

- **`DeviceSettings.onboarding_completed_at` null** ->
  [First-run onboarding](onboarding.md), melanjutkan draft lokal yang dapat dipulihkan.
- **Sudah onboarding, database usable** -> [Today pada Home](home.md).
- **Registrasi pending/gagal, offline atau VPS down** -> Tujuan lokal yang sama;
  status registrasi ditangani onboarding/[Pusat Sync](pusat-sync.md).
- **Recovery sync tertunda** tidak diproses di Splash. Deteksi generation/epoch/
  cursor/base terjadi saat sync setelah shell aktif dan disajikan di Pusat Sync,
   bukan pada Splash.

Tandai onboarding selesai ketika setup lokal selesai, bukan ketika registrasi
server sukses. Splash tidak membuat Weekly Review parsial; fresh install mengikuti
trigger Minggu pertama sesuai FR-8.12. Recovery timer tidak membuka rangkaian dialog
atau auto-cancel/auto-complete sesi; outcome dan derived Activity mengikuti kontrak.

Completion membuka Today tanpa menunggu VPS. Pada perangkat cepat Splash boleh
lewat sangat singkat; jangan menambah delay artifisial.

## Keadaan

| Keadaan | Presentasi | Tindakan |
|---|---|---|
| Buka cepat/normal | Identitas + status singkat, tanpa progress bar | Lanjut ke Today atau onboarding |
| Instalasi baru | Menyiapkan data lokal | Buat tabel/seed, lalu onboarding |
| Migration berjalan | Progress migration dengan teks tahap; dapat lebih lama | Backup terverifikasi lebih dahulu; tidak menerima input lain |
| Backup gagal dibuat/diverifikasi | Pembaruan belum dapat dimulai; alasan spesifik | Migration tidak dimulai; retry hanya jika penyebab dapat diperbaiki |
| Migration gagal sebelum sync aktif | Mengembalikan salinan, lalu hasil restore | Copy/schema asal harus terverifikasi sebelum shell; retry aman dari versi asal |
| Mutation schema baru sudah dikirim | Data memerlukan aplikasi yang sesuai | Forward-fix/ekspor/recovery; tidak ada downgrade otomatis |
| Integrity check gagal | Data lokal tidak dapat dibuka, instruksi pemulihan | Arahkan ke jalur recovery; jangan menimpa data lama |
| Recovery timer | Memulihkan timer | Pulihkan state; tidak menandai sesi cancelled tanpa aksi user |

Migration dan first install diukur terpisah dari metrik startup rutin (OPERATIONS
7.1); Splash tidak mengklaim angka benchmark.

## Teks ID/EN dan progress

Semua teks UI memakai resource localization. Gunakan bahasa tersimpan setelah
terbaca; sebelumnya fallback localization aplikasi yang konsisten dengan onboarding.

| Resource/state | Bahasa Indonesia | English |
|---|---|---|
| Opening | Membuka data lokal… | Opening local data… |
| New install | Menyiapkan data lokal… | Preparing local data… |
| Backup | Membuat salinan sebelum pembaruan… | Creating a copy before updating… |
| Verify backup | Memeriksa salinan data… | Checking the data copy… |
| Migration | Memperbarui data lokal… | Updating local data… |
| Timer recovery | Memulihkan timer… | Restoring the timer… |
| Restore | Mengembalikan salinan data… | Restoring the data copy… |
| Open failed | Data lokal belum dapat dibuka | Local data could not be opened |
| Backup failed | Pembaruan data belum dapat dimulai | The data update could not start |
| Migration failed | Pembaruan data belum berhasil | The data update was unsuccessful |
| Integrity/restore failed | Data lokal perlu dipulihkan | Local data needs recovery |
| Downgrade forbidden | Data memerlukan aplikasi yang sesuai | These data need a compatible app |
| Retry | Coba lagi | Try again |
| Recovery guide | Panduan pemulihan | Recovery guide |
| Close guide | Tutup panduan | Close guide |

Default hanya status teks. Gunakan progress determinate beserta label tahap bila
completed/total berasal dari pekerjaan yang sama dan benar-benar diketahui;
`aria-valuenow` mengikuti nilai itu. Jika tidak terukur, jangan membuat persentase,
spinner dekoratif atau bar yang berjalan berdasarkan waktu. Jumlah langkah teknis
tidak dianggap persentase seluruh startup.

## Aksi dan pemulihan

**Coba lagi** tersedia ketika service menilai kegagalan retriable, misalnya database
terkunci atau ruang penyimpanan yang sudah dibebaskan. Retry memakai identitas dan
source version yang sama serta mengulang verifikasi yang diperlukan. Saat bekerja,
tombol disabled dan status tampil; double click tidak membuat pekerjaan paralel.

**Panduan pemulihan** membuka rincian inline dengan aksi Tutup panduan. Isi menyebut
penyebab, langkah yang tersedia dan status backup terakhir yang benar-benar
terverifikasi. Database terkunci meminta menutup aplikasi lain; ruang penuh meminta
membebaskan ruang; corruption meminta berhenti menulis dan mengikuti restore dari
salinan terverifikasi. Jangan mengklaim data aman/restore selesai sebelum verifikasi.
Tidak tampil credential, cursor, SQL mentah, path sensitif atau stack trace.

Tidak ada tombol reset/hapus database, lewati migration atau lanjut dengan data
parsial. Migration gagal sebelum sync aktif kembali mengembalikan copy/schema asal
sesuai OPERATIONS. Setelah mutation schema baru dikirim, gunakan forward-fix atau
prosedur ekspor/recovery; jangan gabungkan kondisi itu dengan retry migration biasa.
Flow ekspor/restore lanjutan belum mempunyai visual lengkap.

## Keadaan dan aksesibilitas

Status memakai teks, bukan hanya spinner atau warna. Perubahan status diumumkan ke
screen reader melalui live region; Splash tidak menjebak fokus dan tidak
membutuhkan input pada jalur normal. Layar migration/gagal memiliki teks yang dapat
dibaca dan target aksi minimal 44 px bila menampilkan tombol. Tema mengikuti sistem
atau pilihan pengguna; permukaan opaque, aksen indigo untuk progress, danger plus
teks untuk kegagalan.

Gunakan satu live region polite untuk status tahap; alert untuk kegagalan baru.
Jangan mengumumkan perubahan setiap frame. Jalur normal tidak mempunyai kontrol
fokus. Saat route berganti, pindahkan konteks aksesibilitas ke judul tujuan melalui
mekanisme platform. State gagal mempunyai urutan retry, panduan, lalu tutup panduan.
Enter/Space menjalankan tombol, Escape menutup panduan dan fokus kembali ke pemicu.
Kontras teks normal minimal 4.5:1, besar 3:1, komponen/fokus 3:1; periksa warna
rendered, font platform, ID/EN, dua tema dan teks 200% pada 320 px/landscape pendek.
Penutupan mengikuti lifecycle OS; service harus tahan process kill melalui transaksi
dan backup, bukan mengandalkan widget yang mencegah aplikasi dihentikan.

## Kontrak dan gap

PRD FR-7.13; OPERATIONS bagian 3 (backup sebelum migration), 7.1 (startup), 7.3 dan
NFR-13 (recovery timer); schema bagian 22 (inisialisasi/migration). Splash tidak
memiliki endpoint sendiri; ia hanya membuka state lokal.

Belum mempunyai acuan visual: preview dan mockup layar ini, presentasi tahap
migration nyata, dan tampilan kegagalan integrity/migration. Pengukuran cold/warm
start dan timer recovery adalah target native, bukan bukti browser.

## Periksa saat implementasi

| Skenario | Hasil yang harus diverifikasi |
|---|---|
| Startup cepat, onboarding selesai | Home menerima input segera setelah local readiness; tidak ada minimum delay |
| First install di tengah minggu | Onboarding offline, identitas/seed stabil; tidak membuat review parsial |
| Registrasi gagal, airplane mode, VPS down | Tujuan lokal tetap terbuka; tanpa network gate/permission request |
| Schema lama dengan data nyata | Backup konsisten dan verifikasi mendahului migration; write/sync ditahan |
| Backup gagal atau ruang tidak cukup | Migration belum berjalan, alasan/retry tersedia; data asal tidak ditimpa |
| Migration gagal sebelum sync aktif | Copy/schema asal dipulihkan dan diverifikasi sebelum shell |
| Mutation schema baru sudah dikirim | Tidak downgrade otomatis; forward-fix/recovery dijelaskan |
| Integrity/restore gagal | Tidak membuka shell parsial, reset diam-diam atau mengklaim pemulihan sukses |
| Sesi running melewati planned end | Tidak auto-cancel/auto-complete atau menggandakan derived Activity |
| Sesi paused lalu relaunch/resume | Tetap paused; pause dihitung sekali, actual/statistik mengecualikan pause |
| Restart di tengah backup/migration/retry | State konsisten, identitas tetap, tidak menggandakan operasi |
| Desktop/ponsel, ID/EN, dua tema, teks 200% | Tidak ada overflow descendant/aksi terpotong; keyboard/live region sesuai |

Benchmark native mengikuti OPERATIONS §7.1/7.3: cold-start p95 ≤2.000 ms,
warm-start p95 ≤750 ms, drift relaunch ≤1 detik dan koreksi UI timer ≤500 ms setelah
frame pertama. First install/migration diukur terpisah. Ini target acceptance,
belum hasil pengukuran atau klaim performa Splash.

## Traceability

| Kontrak | Penerapan |
|---|---|
| PRD FR-7.13; NFR-2/7/9 | Local-first, tanpa network/permission, localization, rute onboarding/Home |
| PRD milestone M1–M4; schema §22 | Identitas sebelum seed, inisialisasi idempotent dan setup sesuai scope |
| schema §3.2 | `onboarding_completed_at` lokal untuk routing |
| API-SPEC §9.8 | Registrasi gagal tidak menjadi gate; Splash tidak menunggu network |
| OPERATIONS §3; NFR-11 | Backup/checksum/verifikasi dan batas rollback |
| OPERATIONS §7.1/7.3; NFR-8/13 | Startup/recovery dengan metode dan batas native |

Spesifikasi tidak menambah endpoint atau field domain/sync. Pemeriksaan dokumen
tidak menjadi bukti UI rendered, migration, backup atau recovery timer runtime.
