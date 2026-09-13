# Home

Acuan: [`../preview/home.html`](../preview/home.html),
[`../mockups/home-desktop.png`](../mockups/home-desktop.png),
[`../mockups/home-mobile.png`](../mockups/home-mobile.png).

## Hierarki

Header identitas/tema → tanggal aktif dan tambah entry → strip Senin–Minggu →
pilihan Daftar/Timeline/Mingguan → jadwal utama → pendamping **Next deadline**,
**Habits**, dan shortcut Weekly Review. Desktop memberi ruang lebih besar pada
jadwal. Ponsel menumpuk section; grid mingguan menjadi agenda per hari.

Timebox terpilih memakai bidang indigo dominan dengan waktu/kategori/status,
judul dan plan/actual. Entry lain memakai permukaan putih/gelap dan metadata
ringkas. Aktivitas tanpa waktu berada pada bagian terpisah. Deadline tampil pada
timeline/grid dan panel pendamping, termasuk tugas overdue aktif.

## Interaksi

- Prev/next, date picker, dan strip hari mengubah tanggal aktif; landing Today.
- Tambah Activity/Timebox melalui modal. Activity boleh tanpa waktu; Timebox wajib
  memiliki rentang valid. Quick-add grid membawa tanggal/jam sel.
- Detail entry adalah modal; start, selesai, skip, missed, reschedule, dan
  putuskan nanti menjaga makna status domain. Start execution tetap pending dan
  mencatat actual_start_at; tidak menciptakan status Activity berjalan.
- Hasil execution menjadi satu unit dengan plan, tidak menggandakan entry.
  Completion rate memakai Activity aktif, bukan seluruh block pending.
- Panel deadline membuka detail contoh. Panel Habits hanya target tanggal aktif;
  checklist cepat hanya hari ini, done/non-done menjaga hasil Activity unik.
- Shortcut Weekly Review pada paket offline membuka
  [layar review](weekly-review.md) melalui `../preview/weekly-review.html`.
  Canvas Home asli mempertahankan jurnal ringkas historis; implementasi memakai
  route Weekly Review lengkap dan sumber domain bersama, bukan handler seed itu.

## Kontrak

PRD FR-1.3, 1.5, 1.6, 1.9, 1.13; FR-3.3, 3.6, 3.7, 3.12, 3.14, 3.15;
FR-5.2, 5.3, 5.7, 5.12, 5.13, 5.15; FR-6.6, 6.8–6.10, 6.17; FR-8.2–8.3.
schema §8 dan §14.1 menetapkan execution, sumber hasil, dan agregasi.

Next deadline/Habits ditambahkan atas permintaan pengguna. CourseNote tidak
ditempelkan ke Home/Tugas. Gunakan sumber Habit normatif bersama layar Habit;
seed streak sederhana pada fragmen Home hanya tampilan contoh. Lihat `../GAPS.md`.

## Periksa saat implementasi

Tanggal tanpa entry, entry tanpa waktu, judul panjang, tugas terlambat, satu hasil
execution, tujuh hari mobile beserta deadline/quick-add, dua tema, state data,
modal dan fokus keyboard.
