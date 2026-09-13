# Tugas

Acuan: [`../preview/tugas.html`](../preview/tugas.html),
[`../mockups/tugas-desktop.png`](../mockups/tugas-desktop.png),
[`../mockups/tugas-mobile.png`](../mockups/tugas-mobile.png).

## Hierarki

Judul/tambah tugas → tab Aktif/Riwayat/Mata kuliah & catatan → filter/sort → kartu.
Kartu menampilkan status/prioritas, judul, lalu deadline/countdown/mata kuliah.
Deadline dan overdue menentukan keputusan berikutnya; tidak menambahkan statistik
pengisi. Grid desktop berubah menjadi satu kolom pada ponsel.

Detail sebagai route dengan tombol kembali: judul/deadline → deskripsi/checklist →
status, prioritas, estimasi opsional, course, default reminder → edit/arsip/hapus.
Mata kuliah mempunyai detail sendiri dengan CourseNote bertanggal.

## Interaksi dan aturan

- Filter status/prioritas/course dan sort deadline/prioritas/course. Tugas overdue
  yang belum selesai tetap aktif.
- Add/edit adalah modal: judul, course, priority, deadline tanggal/jam, deskripsi,
  estimasi opsional, checklist opsional. Estimasi tetap opsional sesuai PRD kini.
- Semua checklist selesai menawarkan perubahan status; tidak mengubah otomatis.
- Status manual mencatat completed_at sesuai lifecycle. Riwayat dikelompokkan
  berdasarkan history_date dalam rentang Senin–Minggu yang bisa dinavigasi.
- Arsip manual memakai archived_at; otomatis memakai Local date completed_at +
  tujuh hari. Konfirmasi sebelum hapus.
- CourseNote berada pada mata kuliah; tidak menambah panel catatan pada Tugas.

## Kontrak dan gap

PRD FR-6.1, 6.3, 6.4, 6.7–6.11, 6.13–6.15, 6.17, 6.19–6.20;
schema §5; API-SPEC §9.2. Reminder editor bertipe dan edit/hapus resource course/
note belum lengkap pada preview; default reminder teks bukan seluruh flow.

## Periksa saat implementasi

Tugas tanpa course/estimasi/checklist, banyak item, semua checklist selesai,
status diperbaiki, overdue retention, batas tujuh hari/arsip manual, course note
bertanggal, filter tanpa hasil, dua tema, modal ponsel dan keyboard.
