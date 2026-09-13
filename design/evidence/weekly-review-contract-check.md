# Pemeriksaan kontrak Weekly Review

Tanggal pemeriksaan: 13 September 2026. Acuan: `screens/weekly-review.md`, PRD
FR-8.1 sampai FR-8.14, schema 14.1 dan 15.1 sampai 15.3, API-SPEC 9.9, serta
OpenAPI command WeeklyReview/WeeklyPlanDraft. Pemeriksaan ini membaca dokumentasi;
bukan verifikasi runtime aplikasi.

## Sesuai

- Route global satu minggu Senin sampai Minggu, bukan tab utama keenam.
- Dua jurnal bebas wajib saat complete; draft boleh kosong. Teks completed tetap
  dapat diedit tanpa mengubah periode, status, cutoff atau membekukan ulang snapshot.
- Ringkasan lima kelompok Activity/Tugas/Pomodoro/Timebox/Habit, tanpa Keuangan.
- Kandidat hanya membaca source; tidak memindahkan pekerjaan otomatis.
- WeeklyPlanDraft menarget tepat satu modul dan tanggal pada minggu berikutnya.
- Promotion satu per satu membuat target dan status promoted atomik; retry command
  yang sama mengembalikan target semula, tanpa mengaktifkan ulang histori.
- Gate planning mulai trigger Minggu; existing record tetap terbaca dan perubahan
  hasil/aktual/non-planning tetap diizinkan. Complete lokal membuka gate offline.
- Draft tidak perlu dipromosikan sebelum complete. Promotion ke minggu berikutnya
  tetap ditahan selama gate aktif; jangan membuat ketergantungan melingkar.
- Workload selalu tujuh hari, menghitung tugas aktif yang sudah menjadi target,
  bukan WeeklyPlanDraft; estimasi null dihitung terpisah dan menyumbang nol menit.
- Fresh install menunggu trigger Minggu pertama setelah onboarding tanpa review parsial.

## Perbedaan yang perlu diselaraskan

Header screen spec menyebut CTA selesai hanya aktif saat gate tercapai. PRD FR-8.2
mengizinkan pembukaan manual sebelum trigger. PRD FR-8.11, schema 15.1 dan API-SPEC
9.9 menetapkan validasi teks/draft/cutoff, tetapi tidak mensyaratkan trigger sebagai
syarat command complete. Desain tidak menambahkan penolakan command yang tidak
ada pada kontrak: tombol selesai tersedia pada review draft yang sudah dibuka,
dengan validasi dua jurnal dan draft aktif. Banner sebelum trigger tetap menjelaskan
bahwa planning belum ditahan. Ini interpretasi dari kontrak yang lebih tinggi.

Snapshot completed tidak dihitung ulang oleh edit teks atau perubahan source lokal.
Schema 15.1 tetap mengizinkan response/pull mengganti snapshot client dengan hasil
kanonik server pada cutoff sama; perbedaan itu tidak membuka kembali gate.

## Batas rancangan

Preview harus memberi label data contoh dan state browser sementara. Penyimpanan
SQLite, transaction domain, UUIDv5, outbox berurutan, snapshot kanonik lintas device,
trigger/reminder OS, dan acceptance native tetap pekerjaan implementasi.

Presentasi beberapa missed review terkelompok dan Settings penuh memerlukan acuan
tersendiri. Form promotion contoh tidak menjadi allowlist payload API produksi.
