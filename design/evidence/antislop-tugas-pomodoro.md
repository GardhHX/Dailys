# Preview Tugas dan Pomodoro

Tanggal: 12 September 2026. Sumber: PRD §§4.2, 4.6, 7; schema §§5, 9; API-SPEC §§9.2, 9.4. Preview terhubung melalui dua tab navigasi. Data contoh dan perubahan sementara; reload mengembalikan keadaan awal.

## Keputusan desain

Design Read: aplikasi personal untuk mahasiswa pada Windows/Android, permukaan netral hangat dan indigo berkontras tinggi. ENERGY 2 / RHYTHM 2 / MOTION 1, konsisten dengan preview Home.

- Warna indigo menandai aksi dan pilihan; merah menandai overdue dengan teks, hijau menandai hasil dengan teks. Tidak bergantung pada warna saja.
- Segoe UI mengikuti konteks Windows. Ukuran judul dan timer membangun hierarki; angka waktu memakai tabular numerals.
- Tugas memakai kartu sesuai FR-6.7; detail dibuka sebagai tampilan lokal dengan tombol kembali. Form tetap dialog.
- Kartu menampilkan status/prioritas di atas dan deadline/countdown/mata kuliah di bawah. Urutan default berdasarkan deadline, termasuk tugas terlambat yang tetap aktif.
- Pomodoro memakai satu timer dominan sesuai FR-2.13; statistik/riwayat menjadi pendamping. Tidak menambahkan chart atau ringkasan pengisi.
- Glyph house/clipboard/timer/wallet/checklist menunjukkan lima tab PRD; Lucide host dipilih untuk simbol kecil yang relevan, bukan dekorasi feature.
- Radius 4/6/9/12 px membedakan status, kontrol, kartu, dan dialog. Bayangan hanya menandai elevasi dialog.
- Spacing memisahkan navigasi, filter, pekerjaan, dan metadata; ponsel memakai satu kolom dan bottom navigation tanpa menutupi isi.
- Pembaruan angka/ring adalah representasi timer berjalan, bukan animasi dekoratif; sisanya hanya feedback hover/active.

## Perilaku produk

| Bagian | Preview dan kontrak |
|---|---|
| Tugas aktif | Status, prioritas, course, deadline, countdown, overdue; urutan deadline/prioritas/mata kuliah. FR-6.3, 6.7–6.10, 6.17. |
| Detail Tugas | Deskripsi, status manual, estimasi opsional, checklist, tautan mata kuliah, edit/arsip/hapus dengan konfirmasi hapus. FR-6.11, 6.13, 6.14, 6.19. |
| Checklist | Item yang selesai menawarkan perubahan status; tidak mengubahnya otomatis. FR-6.13. |
| Riwayat | Rentang Senin–Minggu yang dapat dinavigasi; history_date mengikuti arsip manual atau completed Local date + 7 hari. FR-6.17, 6.20. |
| CourseNote | Catatan bertanggal dibuka pada detail mata kuliah; tidak disimpan pada Tugas. FR-6.15. |
| Form Tugas | Judul, mata kuliah, priority, tanggal/jam deadline, deskripsi, estimasi opsional, checklist opsional. Reminder default diperlihatkan sebagai informasi. FR-6.1, 6.4. |
| Timer | Preset 25/50/90, custom, Tugas/Habit/bebas, manual start, pause/resume, complete/cancel. FR-2.3, 2.4, 2.7–2.9, 2.15. |
| Durasi aktual | performance.now mencatat waktu berjalan; pause dikeluarkan. Completion boleh sebelum planned end sesuai API. |
| Integrasi | Focus completed menghasilkan satu Activity contoh; break dan cancellation tidak menghasilkan Activity. Habit link tidak otomatis check-in. |
| Istirahat | Sesi fokus keempat menawarkan long break; setiap break tetap menunggu start manual. Short break tidak mereset hitungan menuju long break. |
| Statistik | Hanya jenis fokus + completed masuk total aktual; periode daily/weekly/monthly. Riwayat juga menampilkan break/cancel. FR-2.10, 2.11, 2.14. |
| Settings | Dialog global Timer & Alarm mengatur durasi dan interval; perubahan tidak mengubah sesi aktif. FR-2.16, FR-7.9. |

Estimasi opsional mengikuti PRD dan schema yang sekarang tersedia, meskipun catatan preview lama pernah menghapusnya. Bukti dokumentasi saat ini menjadi dasar.

## Antislop Delivery Gate

- Hard Gate PASS: R-02 tidak ada em dash; R-03 96 pemeriksaan root/descendant tanpa overflow; R-17/18/23/36/38 seluruh angka/isi contoh berlabel dan tidak ada klaim marketing/runtime; R-24 tab lain disabled dengan penjelasan; R-25 pemeriksaan teks visible non-disabled light/dark AA tanpa kegagalan; R-26/35 click-through kontrol utama dan error JS kosong; R-27 state kosong/memuat/gagal/retry; R-28 tidak ada FAQ; R-32 kontrol native, Enter/Tab/Escape diperiksa; R-33 source ditulis lewat patch; R-34 dua tema diperiksa; R-37 Design Read eksplisit.
- Purpose-Gate PASS: R-01/07 tidak ada pola latar, gradient, atau glow; R-04 glyph memiliki relevansi navigasi; R-06 tipografi Windows dan angka waktu memiliki alasan; R-08 chevron hanya navigasi/detail; R-09 badge menunjukkan status data, bukan marketing; R-10/12/13 tidak ada glass/glow dan shadow hanya dialog; R-14 kartu sesuai kebutuhan Tugas, berbeda dari komposisi timer; R-19 timer update memiliki fungsi dan tidak ada animasi dekoratif; R-22 tidak ada ilustrasi generik.
- Liveliness PASS: dials 2/2/1 ditulis sebelum generasi; fokus Tugas pada deadline terdekat/overdue, fokus Pomodoro pada timer; whitespace membedakan pekerjaan dari metadata; indigo sebagai aksen; motif planning akademik diteruskan dari Home; komposisi kedua layar berbeda sesuai isinya.
- Craftsmanship/Quality Locks PASS: C-1/R-31 alasan keputusan tertulis; C-2 kontrol aktif memiliki handler; C-3/R-05 semua bagian berasal dari kebutuhan Tugas/Pomodoro; C-4/R-21 kondisi data, light/dark, modal ponsel, dan keyboard diperiksa pada browser; C-5 tidak mengklaim runtime native; R-11 radius bervariasi; R-15/16 CTA spesifik tanpa buzzword; R-20/30 identitas berasal dari PRD Dailys; R-29 netral + indigo, merah/hijau hanya status.

## Bukti

`qa-work-results.json`: 96 checks = 2 tema × 8 viewport × 6 tampilan (aktif, riwayat, mata kuliah, detail tugas, detail mata kuliah, Pomodoro). Viewport luar 352–1440 px memberikan lebar preview sekitar 320–1408 px.

`qa-tugas-pomodoro.cjs`: filter/sort, checklist offer/confirmation, completion date, tambah/edit/arsip/unarchive/delete, tambah CourseNote/mata kuliah, custom/preset, task/habit/free link, pause timing, konfirmasi cancel, complete, unique Activity, break manual, long-break counter, Settings isolation, stats periods, data states/retry, keyboard, dan modal mobile. Screenshot desktop/pomodoro/ponsel diperiksa.

## Batas

Tidak ada SQLite, REST, sinkronisasi, persistensi/restart, alarm suara, notifikasi OS, atau timer native di background. Timer berjalan lokal selama preview tetap hidup. Reminder task hanya menampilkan default; editor reminder bertipe, edit/hapus mata kuliah dan CourseNote, riwayat sesi detail, lokalisasi penuh, dan recovery native memerlukan implementasi lanjutan. Ini desain interaktif, bukan implementasi seluruh requirement atau sertifikasi aksesibilitas native.
