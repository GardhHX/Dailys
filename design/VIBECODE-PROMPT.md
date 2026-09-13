# Prompt implementasi Dailys

Salin blok berikut ke coding agent yang memiliki akses ke folder atau ZIP desain:

```text
Implementasikan UI Dailys berdasarkan acuan desain lokal.
Baca AGENTS.md, DESIGN.md, design/README.md, design/tokens.json, design/GAPS.md,
lalu spesifikasi layar terkait pada design/screens/. Buka design/preview/index.html
dan bandingkan dengan PNG desktop/ponsel pada design/mockups/.

Pertahankan komposisi, hierarki, permukaan netral hangat, indigo berkontras tinggi,
tipografi sistem dan pola interaksi yang sudah ada. Navigasi utama tetap Home,
Tugas, Pomodoro, Keuangan, Habit. Home memuat Timebox, Next deadline dan Habits.
Form tambah/edit memakai modal; detail Tugas/Habit memakai route. Alur global
bukan tab tambahan: Settings → Pusat Sync → review konflik; onboarding first-run.
Weekly Review melalui shortcut Home atau Settings, bukan tab keenam. Baca
design/screens/weekly-review.md dan preview terkait sebelum implementasi M5.
Kontrol prototype dan toolbar acuan tidak termasuk UI produk.

Splash memakai design/screens/splash.md dan design/preview/splash.html.
Ikuti komposisi identitas/status minimal dan state kegagalan. Jangan menunggu VPS
atau meminta izin. Backup terverifikasi mendahului migration; rollback bersyarat
sesuai OPERATIONS. Relaunch timer memakai Instant UTC, monotonic clock saat process
hidup. Rute keluar memakai onboarding_completed_at lokal, tanpa delay merek.

Kontrak domain mengikuti PRD-Aplikasi-Produktivitas-Mahasiswa.md → schema.md →
API-SPEC.md → openapi.yaml → desain. Jangan menyalin seed, tanggal tetap, state
browser, rumus streak sederhana Home, callback simulasi, atau status accepted
buatan ke produksi. Gunakan sumber domain bersama untuk panel/layer lintas fitur.

Sync menampilkan sukses terakhir, pending/rejected, review dan recovery. Konflik
memakai base/lokal/server per kelompok atomik; bagian aman tetap digabung.
Identitas/immutable/hasil hitung bukan editor bebas. Submitted masih hanya-baca;
accepted atau discard setelah refresh baru menyelesaikan review. Server changed
membatalkan pilihan kelompok terdampak; keputusan ulang memakai change ID baru.
Seluruh versi server adalah discard terpisah dari pilihan per kelompok server.

Recovery mengamankan salinan terenkripsi sebelum staging/replacement atomik.
Gagal/expired mempertahankan data lama dan salinan. Tidak ada replay otomatis,
termasuk never_accepted. Persetujuan menunjukkan jumlah/jenis/dampak saldo;
superseded tidak direplay, receipt ambigu manual review, tombstone/parent tidak
dipulihkan otomatis. DeviceSettings dan secret tetap lokal, UserSettings mengikuti
snapshot. Implementasikan protokol sebenarnya, bukan progress simulasi prototype.

Onboarding meminta ID/EN, IANA timezone, registrasi device, dan menawarkan akun
keuangan pertama opsional. Registrasi gagal tidak memblokir offline/Today.
Jangan menampilkan API key. Izin notifikasi baru diminta ketika pertama memakai
reminder atau Pomodoro. Platform/device identity dan seed dibuat idempotent native.

Weekly Review mengikuti minggu Senin–Minggu timezone user. Dua jurnal wajib saat
complete, tetap editable setelah selesai tanpa menghitung ulang snapshot. Ringkasan
Activity/Tugas/Pomodoro/Timebox/Habit dibekukan pada cutoff completion; tidak ada
Keuangan. Kandidat hanya referensi source, tidak dipindahkan otomatis. Draft ringan
menarget satu modul/tanggal minggu berikutnya; tidak wajib promoted untuk complete.
Aktivasi membuka form modul, membuat target UUIDv5 dan status promoted atomik;
retry command yang sama mengembalikan target semula. Jangan menyalin receipt Map
atau ID example- dari prototype. Gate menahan planning minggu berikutnya sejak
trigger Minggu, tetap mengizinkan hasil/aktual/non-planning. Completion lokal membuka
gate offline, outbox menunggu review accepted sebelum planning dikirim. Workload
tujuh hari menghitung target Tugas aktif, estimasi null terpisah, bukan draft.
Fresh install menunggu trigger pertama; jangan membuat review parsial. Snapshot
kanonik server boleh mengganti hasil client pada cutoff sama tanpa membuka gate.

Global Settings memakai delapan bagian pada screens/settings.md. UserSettings
tepat sembilan field: language, timezone, pomodoro_focus_minutes,
pomodoro_short_break_minutes, pomodoro_long_break_minutes,
pomodoro_long_break_interval, alarm_mode, notifications_enabled,
weekly_review_time. Simpan partial, tampilkan record penuh, pertahankan input gagal.
Tema (`system`/`light`/`dark`, default `system`) adalah field per-device
`DeviceSettings.theme`; simpan lokal seperti volume, jangan tambahkan ke payload
UserSettings/sync. Izin OS, volume, registrasi dan sync state tetap per-device. Notification preference
bukan izin OS; muted mempertahankan visual. Timezone tidak menggeser tanggal/Instant
atau occurrence lama; hitung ulang proyeksi dan gunakan zona baru setelah watermark.
Durasi baru tidak mengubah snapshot sesi running, waktu review tidak mengubah review
lama. Implementasikan shortcut system settings sesuai platform dan gunakan build
metadata nyata. Pomodoro membuka bagian Settings yang sama; jangan memakai modal
preferensi lama sebagai sumber kedua. Tidak ada form credential.

Kerjakan milestone sesuai tugas pengguna. Catat gap yang relevan sebelum
implementasi; jangan menyatakan seluruh PRD selesai karena semua preview tersedia.
Verifikasi desktop/ponsel mulai 320 px, dua tema, data states, dialog/fokus keyboard,
teks panjang dan overflow root/descendant. Laporkan perubahan, bukti, dan gap tersisa.
Perbarui acuan bersama implementasi bila pengguna meminta perubahan desain.
```

Berikan seluruh ZIP v1.4 bila agent hanya menerima unggahan. Satu PNG tidak memuat
reflow, form, tema, invariant, atau gap desain.
