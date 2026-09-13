# Pomodoro

Acuan: [`../preview/pomodoro.html`](../preview/pomodoro.html),
[`../mockups/pomodoro-desktop.png`](../mockups/pomodoro-desktop.png),
[`../mockups/pomodoro-mobile.png`](../mockups/pomodoro-mobile.png).

## Hierarki

Satu timer dominan dengan circular progress dan angka tabular → fase fokus/short
break/long break → preset 25/50/90/custom → link Tugas/Habit/bebas → aksi sesi.
Statistik periode dan riwayat berada di kolom pendamping desktop, di bawah timer
pada ponsel. Shortcut membuka [Global Settings bagian Pomodoro](../preview/settings.html#dg-pomodoro).
Durasi dan alarm mengikuti UserSettings yang sama; jangan membangun form preferensi
terpisah dari shortcut lama pada fragmen historis.

## Interaksi dan aturan

- Manual start untuk fokus maupun break. Pause/resume mempertahankan sesi;
  durasi aktual mengecualikan pause. Complete boleh sebelum planned end sesuai
  API; cancellation memakai konfirmasi dan tidak menghasilkan Activity.
- Focus completed menghasilkan satu Activity. Break tidak menghasilkan Activity.
  Link Habit tidak otomatis check-in Habit.
- Hitungan sesi fokus menentukan penawaran long break; short break tidak
  mereset hitungan tersebut. Settings berubah tanpa memodifikasi sesi aktif.
- Statistik daily/weekly/monthly hanya mengagregasi actual duration sesi fokus
  completed; riwayat juga dapat menunjukkan break/cancelled.
- Picker link pada mockup inline. **Implementasi memakai modal sesuai Screen
  List PRD**, mempertahankan pilihan dan pola visual modal yang ada.

## Kontrak dan gap

PRD FR-2.3, 2.4, 2.7–2.11, 2.13–2.16; FR-7.3, 7.9;
schema §9; API-SPEC §9.4. Preset merupakan override sesi, bukan perubahan global.
Timer preview berjalan selama halaman hidup; jangan menyalinnya sebagai solusi
background, sleep/resume, atau process restart. NFR-13 tetap target native.

## Periksa saat implementasi

Idle/running/paused/completed/cancelled, custom invalid, link dihapus/diarsipkan,
pause actual time, fokus keempat/long break, manual break start, satu Activity,
pergantian tab, Settings isolation, recovery native, dua tema dan ponsel.
