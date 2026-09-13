# Global Settings

Acuan visual aktif mulai paket v1.3: [preview](../preview/settings.html),
[desktop](../mockups/settings-desktop.png), [ponsel](../mockups/settings-mobile.png),
dan [sumber canvas](../source/dailys-settings.html). Gunakan token bersama dan
komposisi ini. [Laporan antislop](../evidence/antislop-settings.md) mencatat bukti
browser; [GAPS](../GAPS.md) mencatat batas implementasi.

## Tempat dan hierarki

Route global dengan tombol kembali, dibuka dari tombol Settings pada app bar setiap
layar, bukan tab utama keenam. Menu utama tetap Home, Tugas, Pomodoro, Keuangan,
Habit. Settings mengelompokkan preferensi ke bagian bertajuk; desktop memakai
daftar bagian di kiri dan panel isi di kanan, ponsel menumpuk bagian dengan judul
yang jelas.

Urutan bagian: **Tampilan & bahasa -> Waktu & zona -> Pomodoro -> Notifikasi &
alarm -> Weekly Review -> Perangkat ini -> Pusat Sync -> Tentang**. Bagian yang
tersinkron dan bagian per-perangkat dipisahkan dan diberi label sumbernya, karena
keduanya berperilaku berbeda saat sync.

Data contoh berlabel; nilai bukan preferensi pengguna sebenarnya.

## Preferensi tersinkron (UserSettings)

Satu UserSettings per user, disinkron lintas device, tidak dapat dihapus. PUT
bersifat partial; layar menyimpan per perubahan dan menampilkan bentuk penuh.

- **Bahasa.** `id` atau `en`. Perubahan menerapkan resource localization; tidak ada
  string di luar resource.
- **Timezone.** Picker IANA lengkap dengan default device valid. Mengubah timezone
  tidak menulis ulang Local date atau Instant tersimpan dan tidak menggeser
  occurrence/execution yang sudah dimaterialisasi. Sistem menghitung ulang batas
  "hari ini", streak, dan statistik, menjadwalkan ulang notifikasi existing pada
  Instant trigger yang sama, lalu memakai timezone baru hanya untuk occurrence
  setelah watermark. Tampilkan status "menghitung ulang" sebelum menyajikan hasil.
- **Pomodoro.** Durasi fokus 1..180, short break 1..60, long break 1..120 menit,
  interval long break 2..12 sesi fokus. Ini satu-satunya sumber; tab Pomodoro hanya
  membuka bagian ini. Durasi baru berlaku pada fase/sesi berikutnya; sesi `running`
  mempertahankan `durasi_menit` snapshot.
- **Notifikasi & alarm.** Preferensi `notifications_enabled` dan mode alarm
  `sound`/`muted`. Preferensi ini bukan izin OS. Mematikan notifikasi membatalkan
  trigger lokal yang belum terkirim tanpa menghapus reminder offsets domain;
  mengaktifkan kembali hanya menjadwalkan trigger masa depan bila izin OS granted.
  `muted` menghilangkan suara, bukan visual notification.
- **Weekly Review.** Local time review; hari tetap Minggu pada v1.0, default
  `09:00:00`. Perubahan waktu menjadwalkan ulang trigger masa depan tanpa mengubah
  review atau snapshot yang sudah ada.

## Preferensi per-perangkat (DeviceSettings, lokal)

Bagian "Perangkat ini" mengelola state lokal yang tidak ikut sync dan tidak
ditimpa snapshot: tema tampilan (`system`/`light`/`dark`, default `system`),
status izin notifikasi OS, volume alarm per-device, dan info device (nama,
platform, status registrasi). Tema tersimpan per-device seperti volume, bukan pada
UserSettings, sehingga tiap device dapat berbeda. `notifications_enabled=true` tidak
berarti izin OS granted; saat izin ditolak layar menampilkan status dan shortcut
ke system settings tanpa mengubah preferensi user. Volume diterapkan bila platform
mendukung.

API key tidak pernah tampil di Settings, database domain, payload sync, log, atau
export. Tidak ada form credential.

## Pusat Sync

Bagian ini menautkan ke route Pusat Sync (lihat `pusat-sync.md`) dan menampilkan
ringkasan: status terakhir, waktu sukses terakhir, jumlah pending, konflik belum
dilihat, dan recovery/snapshot state, dengan trigger manual. UI menerjemahkan
error protokol menjadi instruksi, tanpa cursor, generation UUID, receipt hash,
atau secret.

## Keadaan dan aksesibilitas

Keadaan wajib: nilai tersimpan, sedang menyimpan, gagal simpan dengan retry yang
mempertahankan input, timezone sedang recompute, izin OS granted vs denied, dan
device belum/berhasil/gagal registrasi. Nilai di luar rentang (durasi Pomodoro,
interval) ditolak inline dengan alasan; error tidak menghapus field lain.

Kontrol dan label semantik sesuai, fokus terlihat, urutan Tab logis, Enter
menyimpan field aktif, Escape menutup picker/dialog dan fokus kembali ke pemicu.
Target implementasi kontras AA, status memakai teks/simbol selain warna, dan touch
target kontrol utama minimal 44 px. Tema mengikuti sistem atau pilihan pengguna.

## Kontrak dan gap

PRD FR-7.1 sampai 7.14; schema 3.1 (UserSettings) dan DeviceSettings lokal;
API-SPEC 9.8 dan OpenAPI UserSettings/UserSettingsMutation. Perubahan preferensi mengikuti kontrak walau preview memakai
data contoh dan simulasi.

Preview menunjukkan delapan bagian, resource ID/EN, empat durasi dengan batas,
simpan/gagal/retry, recompute zona, ringkasan sync, panduan izin Windows/Android,
registrasi serta Tentang. Picker memakai daftar canonical IANA dari
`Intl.supportedValuesOf('timeZone')` ditambah UTC; fallback browser lama hanya empat
contoh dan diberi peringatan. Implementasi harus memakai tzdb/validasi domain,
termasuk alias valid; jangan memakai daftar runtime browser sebagai allowlist server.

Tema `system`/`light`/`dark` (default `system`) kini memiliki kontrak sebagai
preferensi per-device pada DeviceSettings lokal (schema 3.2; PRD FR-7.15 dan
FR-7.6). Tema bukan bagian sembilan field UserSettings, tidak disinkronkan, dan
tidak masuk payload sync atau OpenAPI; tiap device boleh berbeda. Simpan tema
lokal seperti volume alarm, bukan pada payload UserSettings. Panduan izin bukan
binding system settings atau perubahan izin OS. Build aplikasi belum tersedia dan
ditampilkan sebagai placeholder, bukan nomor build rekaan. Splash tetap gap
terpisah.

## Routing dan batas prototype

Paket offline menghubungkan app bar ke Settings, shortcut Timer & Alarm ke
`settings.html#dg-pomodoro`, dan tombol kembali Pusat Sync ke bagian Sync. Tombol
Home, Weekly Review dan Pusat Sync membuka preview terkait. First-run onboarding
tetap berdiri sendiri sebelum shell aplikasi. Canvas memperlihatkan tujuan dalam
dialog; tidak menjalankan route native.

Setiap field user membuat patch contoh dengan satu field dan record penuh sembilan
field. Volume hanya mengubah state perangkat. Skenario gagal simpan menyimpan input
untuk retry tanpa menimpa nilai tersimpan. Memuat/gagal baca tidak menghapus input
sementara. Reset skenario/reload mengembalikan fixture. Queue, jadwal notifikasi,
recompute dan registrasi hanya simulasi browser; tidak melakukan REST/SQLite/OS.
Contoh immutable membuktikan handler tidak mengubah tanggal, occurrence, sesi
running, review completed atau reminder offsets; bukan bukti materializer native.

## Periksa saat implementasi

Ganti bahasa ID/EN tanpa string di luar resource, ubah timezone dan recompute
proyeksi tanpa menggeser occurrence lama, durasi Pomodoro batas/invalid dan sesi
running tak berubah, matikan/aktifkan notifikasi terhadap izin OS granted/denied,
mode muted menyisakan visual, ubah waktu Weekly Review tanpa mengubah review lama,
izin OS denied menampilkan shortcut, registrasi device pending/gagal, secret tidak
pernah tampil, dua tema, form ponsel, dan fokus keyboard.
