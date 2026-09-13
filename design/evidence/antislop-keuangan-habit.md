# Preview Keuangan dan Habit

Tanggal: 12 September 2026. Sumber: PRD §§4.4, 4.5, 7; schema §§11–14.1; API-SPEC §§9.6, 9.7. Preview dua layar terhubung melalui navigasi Keuangan/Habit; seluruh isi contoh diberi label. State sementara dikembalikan saat reload.

## Design Read dan alasan

Aplikasi personal mahasiswa untuk Windows/Android, permukaan netral hangat dan indigo berkontras tinggi; ENERGY 2 / RHYTHM 2 / MOTION 1. Bahasa visual meneruskan Home, Tugas, dan Pomodoro.

- Saldo total menjadi fokus Keuangan karena pengguna mengecek uang yang tersedia; kartu akun memberi rincian sumber saldo.
- Transaksi menjadi daftar yang memprioritaskan nominal, tanggal, kategori dan akun. Income/expense memiliki tanda dan label, transfer/adjustment memiliki tipe yang jelas.
- Pie memberi rincian pengeluaran per kategori; legenda memuat nilai sebenarnya dan warna kategori stabil. Tren menyertakan angka tiap bulan dalam tabel, termasuk bulan nol.
- Habit memakai baris checklist, bukan statistik agregat atau kartu kategori. Target aktif dan non-target dipisahkan sesuai PRD; periode paused memiliki tab Dijeda.
- Streak memakai satuan target hari. Izin dan jadwal efektif terlihat untuk menjelaskan konsekuensi pencatatan, tanpa skor motivasi rekaan.
- Heatmap 4 minggu memakai simbol ✓/I/×/·/J dan accessible date/status. Sel 44 px mempertahankan target sentuh pada lebar 320 px. Periode lain dibuka melalui prev/next.
- Segoe UI dan hierarki judul mengikuti konteks Windows; angka Rupiah disusun konsisten dan mudah dipindai.
- Indigo menunjukkan pilihan/aksi. Hijau menunjukkan pemasukan/hasil, merah menunjukkan pengeluaran/miss/error, oker menjadi salah satu warna identitas; semua mempunyai teks/simbol.
- Radius berbeda untuk kontrol/kartu/dialog. Bayangan hanya pada dialog; tidak memakai glass, glow, atau animasi berulang.
- Glyph navigasi host dipilih karena house/clipboard/timer/wallet/checklist relevan dengan lima tab produk.
- Ponsel menumpuk kolom, akun dan filter; baris Habit memisahkan judul dari streak agar teks tidak terjepit.

## Traceability

| Area | Kontrak yang diwujudkan dalam preview |
|---|---|
| Akun dan saldo | Akun cash/bank/ewallet/custom; saldo dihitung dari opening + ledger; akun arsip dikeluarkan dari saldo aktif/picker. FR-4.1, 4.10, 4.16. |
| Transaksi | Income/expense, numpad Rupiah, kategori sesuai tipe, tanggal/catatan, edit/delete dengan konfirmasi. FR-4.3–4.9, 4.13–4.15. |
| Transfer | Create/edit/delete memperbarui dua saldo dengan perhitungan dari state ledger; transfer tidak masuk arus income/expense. FR-4.2. |
| Koreksi saldo | Opening dapat diperbaiki sebelum ada retained ledger; sesudahnya target menghasilkan adjustment selisih. Koreksi nol tidak membuat record; adjustment tidak memiliki edit/delete biasa. FR-4.17. |
| Insight | Pie expense default bulan berjalan; tren 12 bulan termasuk nol, income/expense saja. Transfer/adjustment dikeluarkan. FR-4.11, 4.12. |
| Habit target | Target hari khusus, bagian Hari ini/Habit lainnya, checklist hanya target aktif; paused di tab Dijeda. FR-5.1, 5.2, 5.5, 5.8. |
| Streak dan histori | Target done menambah; non-target/paused diabaikan; izin valid tidak memutus/menambah; target lampau tanpa log atau explicit missed memutus. Histori memakai versi schedule pada tanggal tersebut. FR-5.3, 5.6, 5.9. |
| Habit log | Catatan opsional, izin per minggu Senin–Minggu, pemeriksaan batas izin, perubahan done/non-done mengubah satu Activity contoh deterministik. FR-5.7, 5.12, 5.13, 5.15. |
| Pengelolaan Habit | Tambah/edit, jadwal efektif hari ini/masa depan, jeda/lanjutkan, reorder, dan konfirmasi hapus. FR-5.8–5.11. |
| Kalender/identitas | Heatmap dan simbol status; preset warna identitas. FR-5.4, 5.14. |

## Antislop Delivery Gate

- Hard Gate PASS: R-02 copy tidak memakai em dash; R-03 144 checks root/descendant tanpa overflow; R-17/18/23/36/38 data contoh berlabel, tanpa testimonial, foto/profil rekaan atau klaim runtime; R-24 tab di luar cakupan disabled dengan penjelasan; R-25 teks utama non-disabled pada light/dark memenuhi AA dari perhitungan background aktual; R-26/35 kontrol utama diuji dan pageerror kosong; R-27 kondisi kosong/memuat/gagal/retry; R-28 tidak ada FAQ; R-32 kontrol native dan Enter/Tab/Escape diperiksa; R-33 source ditulis melalui patch; R-34 dua tema diuji; R-37 brief dan dials eksplisit.
- Purpose-Gate PASS: R-01/07 tidak ada gradient/glow/background pattern; R-04 glyph terkait navigasi; R-06 tipografi Windows dan angka uang memiliki alasan; R-08 chevron hanya navigasi/periode/detail; R-09 tidak ada badge marketing; R-10/12/13 tidak ada glass/glow dan shadow hanya dialog; R-14 saldo/akun, transaksi dan checklist memakai komposisi berbeda sesuai kebutuhan data; R-19 tidak ada gerakan berulang; R-22 tidak ada ilustrasi generik.
- Liveliness PASS: dials 2/2/1 konsisten; saldo total sebagai fokus Keuangan, target hari ini sebagai fokus Habit; spacing memisahkan pekerjaan dari rincian; indigo menjadi aksen; motif planning personal Dailys diteruskan; Design Read dinyatakan sebelum generasi.
- Craftsmanship/Quality Locks PASS: C-1/R-31 alasan tertulis; C-2 kontrol memiliki handler lokal; C-3/R-05 bagian berasal dari kebutuhan Keuangan/Habit; C-4/R-21 tema, kondisi data, keyboard, modal ponsel dan reflow diperiksa pada browser; C-5 angka merupakan hasil state contoh berlabel; R-11 radius bervariasi; R-15/16 CTA spesifik tanpa buzzword; R-20/30 layout berasal dari PRD Dailys; R-29 aksen indigo, hijau/merah/oker mempunyai arti data/status dan sisanya netral.

## Bukti verifikasi

`qa-life-results.json`: 144 checks = 2 tema × 8 viewport × 9 tampilan: ringkasan, transaksi, insight, akun, kategori, detail akun, Habit aktif, Habit dijeda, detail Habit. Viewport luar 352–1440 px menghasilkan lebar preview sekitar 320–1408 px. Pemeriksaan memeriksa root dan descendant, termasuk scrollWidth.

`qa-keuangan-habit.cjs` memeriksa nilai saldo awal contoh, transfer create/edit/delete dan dua sisi saldo, penolakan transfer ke akun sama, income/expense edit, nominal nol, numpad, filter/rentang/bulan, adjustment target dan no-op, retained opening, arsip/unarchive akun, opening akun belum dipakai, kategori duplicate/archive, 12 bulan nol, unique Activity Habit, koreksi done/non-done, batas izin mingguan, non-target read-only, versi jadwal historis, pause/resume, reorder, validasi target day, konfirmasi hapus, fixture streak, data states, tema, keyboard, dan modal ponsel.

Fixture normatif yang diuji: Sen 7 Sep done, Rab 9 Sep skip valid, Jum 11 Sep done pada target [1,3,5] menghasilkan current=2 dan longest=2.

Screenshot `keuangan-desktop.png`, `habit-desktop.png`, `keuangan-mobile.png`, `habit-mobile.png` diperiksa untuk komposisi dan keterbacaan. Hasil terakhir mengikuti perbaikan baris Habit pada ponsel.

## Batas preview

Ini desain interaktif dalam browser, bukan Flutter, database ledger, atau backend. Tidak ada persistensi/restart, REST, sync, notifikasi OS, atau fixture lintas perangkat. Transfer/correction dihitung ulang dari satu state lokal; belum merupakan bukti transaction database. Seed kategori sesuai PRD; custom kategori bisa ditambahkan/diarsipkan. Warna Habit berupa tiga preset, tanpa arbitrary color/icon picker. Operasi edit/hapus kategori dan akun yang belum digunakan, editor lifecycle penuh, serta lokalisasi/native accessibility memerlukan implementasi lanjutan. Tabel tren memberi nilai setiap bulan; filter rentang pada Insight berlaku pada pie, tren tetap 12 bulan kalender.

Gate ini khusus artefak preview, bukan sertifikasi WCAG menyeluruh atau bukti implementasi semua requirement.
