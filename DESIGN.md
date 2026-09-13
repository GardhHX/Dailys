# Dailys — acuan desain aktif

Versi paket: 1.3, 13 September 2026. Paket ini menyimpan lima layar utama dan lima
alur global: Home, Tugas, Pomodoro, Keuangan, Habit, Pusat Sync, review konflik,
onboarding, Weekly Review, dan Global Settings. Statusnya acuan untuk
implementasi, belum implementasi aplikasi dan belum desain lengkap seluruh PRD.

## Mulai dari sini

1. Buka [`design/preview/index.html`](design/preview/index.html) di Edge/Chrome.
   Tidak perlu npm, server, koneksi internet, atau akun Codex.
2. Pilih layar utama atau alur global. Navigasi utama tetap lima menu;
   Pusat Sync berada di Settings, review berada di bawah Pusat Sync, onboarding
   berjalan saat first-run. Weekly Review masuk dari shortcut Home. Settings masuk
   dari app bar; shortcut Timer & Alarm membuka bagian Pomodoro pada Settings.
   Kontrol contoh
   bukan bagian UI produk.
3. Baca spesifikasi layar di [`design/screens/`](design/screens/), token di
   [`design/tokens.json`](design/tokens.json), dan gap di
   [`design/GAPS.md`](design/GAPS.md).
4. Bandingkan dengan screenshot desktop/ponsel di
   [`design/mockups/`](design/mockups/). Screenshot adalah keadaan contoh tertentu;
   HTML menunjukkan reflow, tema, dialog, dan interaksi.

[`design/VIBECODE-PROMPT.md`](design/VIBECODE-PROMPT.md) berisi prompt yang bisa
langsung diberikan kepada coding agent. [`design/README.md`](design/README.md)
menjelaskan susunan file dan cara membangun ulang paket.

## Otoritas dan penyelesaian perbedaan

Kontrak produk: PRD → schema → API-SPEC → OpenAPI → desain. Desain tidak boleh
mengubah status domain, lifecycle, invariant saldo, rumus streak, atau scope.

Untuk presentasi visual yang sudah dicakup, gunakan spesifikasi layar dan token
bersama, kemudian HTML aktif untuk komposisi/interaksi, lalu screenshot sebagai
pembanding. Laporan QA mencatat bukti historis, bukan requirement tambahan.
Jika preview menyederhanakan kontrak, ikuti kontrak dan catatan `GAPS.md`;
jangan membawa penyederhanaannya ke produksi. Jika muncul perbedaan visual yang
tidak dijelaskan, catat dan selaraskan file acuan bersama perubahan implementasi.

Panel **Next deadline** dan **Habits** pada Home merupakan permintaan eksplisit
pengguna dalam percakapan ini. Keduanya kini tercantum sebagai panel pendamping
Home pada PRD Screen List (Section 7) dan menyajikan data FR-6/FR-5 yang sudah ada,
bukan scope baru.

## Arah visual

Dailys adalah aplikasi personal mahasiswa: pekerjaan hari ini, deadline akademik,
fokus, keuangan harian, dan kebiasaan. Arah yang diminta pengguna: modern dengan
kontras tinggi dan filter antislop. ENERGY 2 / RHYTHM 2 / MOTION 1.

- Permukaan netral hangat dan bidang indigo tegas. Aksen memberi prioritas pada
  aksi, pilihan aktif, serta konten utama, bukan mewarnai seluruh layar.
- Segoe UI pada Windows, fallback sans-serif sistem pada platform lain. Teks
  Indonesia ringkas, CTA menyebut aksi, angka waktu/nominal mudah dipindai.
- Home berpusat pada jadwal; Tugas pada kartu deadline; Pomodoro pada satu timer;
  Keuangan pada saldo dan ledger; Habit pada checklist target hari.
- Weekly Review mendahulukan dua jurnal bebas; ringkasan memakai baris angka,
  kandidat dan draft pada kolom pendamping, beban tujuh hari di bawah. Gate planning
  memberi konteks tindakan; tidak menambah tab utama atau statistik keuangan.
- Global Settings memakai daftar bagian kiri dan satu panel isi berkelompok.
  Ponsel menumpuk delapan bagian. Label lintas perangkat/lokal menjelaskan sumber
  preferensi; status simpan dan retry ditempatkan dekat field.
- Tidak menambahkan chart, statistik, slogan, atau bagian pengisi. Chart Keuangan
  menjawab rincian pengeluaran dan tren arus kas yang diminta PRD.
- Permukaan opaque, garis pemisah tipis, radius bervariasi. Bayangan hanya untuk
  elevasi dialog. Hover/active/fokus memberi feedback tanpa animasi berulang.
- Status selalu mempunyai teks atau simbol selain warna. Merah untuk
  overdue/error/pengeluaran/missed; hijau untuk hasil/pemasukan; warna kategori
  menjadi identitas data, bukan warna status universal.

## Token bersama

Nilai mesin ada di `design/tokens.json`; gunakan nama semantik, bukan prefix CSS
lokal `dh`, `dw`, atau `dl` sebagai arsitektur produksi.

| Token | Terang | Gelap |
|---|---|---|
| background | `#f5f4f0` | `#17181e` |
| surface | `#ffffff` | `#22232c` |
| text | `#20212b` | `#f4f4fa` |
| textMuted | `#595a68` | `#b9bbc9` |
| divider | `#dcdce2` | `#454651` |
| controlBorder | `#777887` | `#9092a2` |
| accent | `#3538a0` | `#b7b9ff` |
| onAccent | `#ffffff` | `#191a4c` |
| selectedSurface | `#eeeefa` | `#323347` |
| danger | `#9e2c30` | `#ffb3b6` |
| success | `#266044` | `#a2dfbb` |
| ochre | `#77501a` | `#e4c690` |

Body utama 14 px, metadata 11–12 px, judul layar 28–30 px, judul bagian 19 px,
judul item 15 px. Variasi spesifik ada di CSS preview. Weight 600–650 untuk
hierarki utama; timer 60–64 px dengan angka tabular. Radius: 3–4 px untuk sel
padat/status, 6 px kontrol, 9 px kartu, 12 px dialog/shell. Touch target kontrol
utama minimal 44 px; metadata bukan target sentuh. Jangan menjadikan divider
berkontras rendah sebagai satu-satunya penanda batas input/fokus.

## Layout dan navigasi

Urutan menu: **Home → Tugas → Pomodoro → Keuangan → Habit**. Windows memakai
rail di kiri; ponsel memakai bottom navigation. Settings global melalui app bar,
bukan menu keenam. [Global Settings](design/screens/settings.md) mempunyai preview
mulai v1.3; shortcut Timer & Alarm membuka bagian Pomodoro yang sama.

Preview mulai merapatkan rail sekitar 860 px, menyusun ulang sebagian konten
sekitar 736 px, beralih ke mobile navigation pada 680 px, dan mengurangi
padding/menumpuk field pada 440 px. Angka ini mengacu pada lebar konten preview,
bukan nama model perangkat. Pastikan hasil tetap dapat dipakai pada 320 px.
Grid mingguan Home berubah menjadi agenda tujuh hari pada ponsel; hari, blok,
deadline, dan quick-add tetap tersedia.

Geometri preview mempunyai variasi yang disengaja: Home memakai rail 142/76 px;
empat layar berikutnya memakai 142 px, 166 px mulai 1150 px, dan 88 px saat compact.
Padding wide desktop keempat layar tersebut 38 px horizontal/32 px vertikal.
Variasi ini dicatat pada `layout.screenOverrides` di token; jangan meratakan semua
ukuran sehingga komposisi berubah dari preview yang sudah dibuat.

Form tambah/edit memakai modal; detail Tugas/Habit memakai route dengan tombol
kembali. Terapkan pada routing native walaupun preview memakai render lokal.
Bottom navigation native tidak boleh menutupi konten, termasuk safe area dan
keyboard. Bar navigasi preview berada dalam aliran dokumen untuk acuan offline.

## Keadaan dan aksesibilitas

Setiap list/section data memiliki keadaan terisi, kosong, memuat, dan gagal dengan
retry. Empty state menyebut objek dan langkah berikutnya. Error tidak menghapus
input yang masih dapat dipulihkan. Tema mengikuti sistem atau pilihan pengguna.

Gunakan kontrol dan semantic label yang sesuai, fokus terlihat, urutan Tab logis,
Enter untuk submit, Escape untuk menutup dialog, dan fokus kembali ke pemicu.
Modal mengelola fokus; heatmap mempunyai label tanggal/status. Target implementasi
teks normal AA 4.5:1, teks besar 3:1, komponen/indikator fokus 3:1. Grafik tetap
memiliki angka/legenda agar informasi tidak bergantung pada warna.

## Kriteria penerapan

Alur global: Pusat Sync memprioritaskan status, sukses terakhir, pending/rejected,
review terbuka dan recovery. Review memakai base/lokal/server dan kelompok atomik;
record hanya-baca sampai hasil final. Onboarding meminta bahasa/timezone,
registrasi perangkat dan menawarkan akun pertama, tetap dapat selesai offline.
Izin notifikasi diminta saat pertama menggunakan reminder/Pomodoro. Pemulihan
memerlukan salinan sebelum replacement dan persetujuan setiap replay. Spesifikasi:
[`Pusat Sync`](design/screens/pusat-sync.md),
[`review konflik`](design/screens/review-konflik.md),
[`onboarding`](design/screens/onboarding.md).

Splash mengikuti [spesifikasi startup](design/screens/splash.md): identitas teks,
status lokal, progress hanya bila terukur, serta state gagal dengan retry/panduan.
Tanpa navigasi aplikasi, network gate atau permintaan izin. Spesifikasi tertulis
tersedia; preview/mockup Splash belum dibuat.

Weekly Review memakai [acuan layar](design/screens/weekly-review.md): dua jurnal,
snapshot saat complete, kandidat hanya-baca, draft target satu modul, dan form
aktivasi satu per satu. Penyelesaian lokal membuka gate tanpa menunggu server;
draft tetap boleh disiapkan saat gate aktif. Snapshot client dapat direkonsiliasi
dengan hasil kanonik server pada cutoff sama. Preview mencontohkan perilaku ini
dengan fixture, tanpa database atau protokol sync.

- Sepuluh layar berpreview mempertahankan hierarki, token, navigasi, dan pola
  form/detail pada preview aktif. Fitur yang belum dicakup tidak diisi desain
  generik diam-diam.
- Home tetap mempunyai Timebox, Next deadline, dan Habits.
- Data produksi berasal dari kontrak lokal/sync; tidak memakai seed atau tanggal
  12 September 2026. Hasil lintas fitur memakai satu sumber domain bersama.
- Periksa desktop, ponsel, dua tema, kondisi data, dialog, teks panjang, overflow
  root dan descendant, serta keyboard. Lihat `design/GAPS.md` untuk cakupan native
  dan flow yang masih membutuhkan desain.
- Perubahan acuan diperbarui bersama spesifikasi, preview, dan gambar terkait
  agar coding agent berikutnya membaca satu versi yang konsisten.
