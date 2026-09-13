# Habit

Acuan: [`../preview/habit.html`](../preview/habit.html),
[`../mockups/habit-desktop.png`](../mockups/habit-desktop.png),
[`../mockups/habit-mobile.png`](../mockups/habit-mobile.png).

## Hierarki

Judul/tambah Habit → tab Aktif/Dijeda → **Hari ini** dan **Habit lainnya**, baris
flat dengan nama, target/status dan streak dalam target hari. Sisa izin menjadi
informasi pendamping. Pada ponsel, judul mendapat satu baris konten penuh dan
angka streak di bawahnya; jangan menjepit judul di antara checkbox/statistik.

Detail memakai route dengan tombol kembali: current/longest streak → target
hari → heatmap empat minggu dengan prev/next → catatan/status per tanggal →
edit, jeda/lanjutkan, reorder, hapus. Kalender rata Senin–Minggu dan sel 44 px.

## Interaksi dan aturan

- Checklist cepat hanya target aktif hari ini. Done membuat/upsert satu Activity
  hasil per HabitLog; koreksi non-done menghapus hasil yang diturunkan tersebut.
- Log modal: done/skip/missed dan catatan opsional. Izin dibatasi quota schedule
  pada minggu Senin–Minggu tanggal log; perubahan log menghitung ulang quota.
- Non-target/paused tidak dapat dicatat sebagai target; tanggal depan disabled.
- Streak: done target menambah; skip valid tidak menambah/memutus; non-target dan
  paused diabaikan; missing target lampau atau missed memutus. Hari ini yang
  belum tercatat tidak langsung memutus.
- Schedule versi efektif dipilih berdasarkan tanggal log. Edit hari/quota atau
  pause/resume efektif hari ini/masa depan, tidak menulis ulang jadwal historis.
- Form add/edit mempunyai nama, custom weekdays minimal satu hari, quota,
  effective date dan identitas warna. Preview memiliki tiga preset warna;
  arbitrary color/icon picker belum lengkap.
- Konfirmasi hapus; Activity hasil lama tetap histori sesuai kontrak.

Simbol heatmap: ✓ selesai, I izin, × missed, · non-target, J dijeda, ○ target
hari ini belum dicatat. Label aksesibel menyebut tanggal dan status, bukan simbol
saja. Gunakan model yang sama pada panel Habits Home.

## Kontrak dan pemeriksaan

PRD FR-5.1–5.15; schema §§13–14.1; API-SPEC §9.7.
Fixture normatif: target [Sen,Rab,Jum], Sen 7 Sep done, Rab 9 Sep skip valid,
Jum 11 Sep done menghasilkan current=2 dan longest=2.

Periksa hari non-target, pause interval, quota lintas minggu, koreksi done,
schedule historis/future, streak terputus, note panjang, unique Activity, heatmap
320 px, warna plus simbol, dua tema dan keyboard.
