# First-run onboarding

Acuan: [`../preview/onboarding.html`](../preview/onboarding.html),
[`../mockups/onboarding-desktop.png`](../mockups/onboarding-desktop.png),
[`../mockups/onboarding-mobile.png`](../mockups/onboarding-mobile.png).

## Empat tahap

1. **Bahasa & waktu.** Pilihan ID/EN dan IANA timezone. Preview memberi lima opsi
   contoh; implementasi memakai picker IANA lengkap dan default device yang valid.
2. **Perangkat.** Nama/platform dan registrasi dengan ID instalasi yang sama saat
   retry. Status pending/success/failure jelas. Gagal tidak memblokir tahap lanjut;
   “Lanjutkan offline” menuju setup berikutnya. Revoked memerlukan reprovision,
   bukan registrasi biasa untuk menghidupkan akses lama.
3. **Akun pertama, opsional.** Nama akun, jenis cash/bank/ewallet/custom dan saldo
   awal integer Rupiah. User dapat melewati; akun dibuat nanti melalui Keuangan.
4. **Ringkasan & mulai.** Bahasa/timezone, perangkat/status registrasi, akun atau
   “buat nanti”. Completion membuka Today tanpa menunggu VPS.

Desktop memakai form dan bidang indigo yang menjelaskan local/sync. Ponsel
menumpuk, form tetap dahulu, stepper menjadi dua kolom agar label terbaca.
Back mempertahankan draft; progress memakai label/angka/check selain warna.
Nama/platform contoh dipakai untuk mengeksplorasi dua target platform; aplikasi
native mendeteksi platform, bukan meminta user mengganti identitas OS secara bebas.

## Local-first, bukan login gate

Bahasa/timezone masuk UserSettings; device identity, status/cursor sync dan secret
lokal tidak digabung ke UserSettings. Setup menyiapkan seed kategori Activity dan
Keuangan secara idempotent. Fresh local kosong tidak membuat recovery copy kosong;
instalasi yang mempunyai data mengikuti prosedur salinan sebelum replacement.

Tidak ada form API key atau tampilan credential. Registrasi di preview adalah
simulasi singkat; provisioning secure-storage nyata tetap pekerjaan native.
Retry registration memakai device_id/body yang sama, bukan ID baru tiap tekan.

## Notifikasi dan awal aplikasi

Tidak meminta izin notifikasi saat splash/onboarding. Izin diminta ketika user
pertama mengaktifkan reminder atau Pomodoro. Preferensi user berbeda dari izin OS.
Splash membuka database/migration/recovery timer dan tidak menunggu network.
Fresh install tidak membuat Weekly Review parsial; review wajib pertama mengikuti
trigger Minggu sesuai PRD FR-8.12.

Paket offline menghubungkan tombol akhir ke Home contoh; di canvas langkah akhir
memberi informasi tujuan setup. State contoh tidak benar-benar membuat akun,
UserSettings, device registration atau seed database. Sebagian copy global di luar
form tetap Indonesia; lokalisasi release penuh dan screen-reader native masih gap.

## Kontrak dan verifikasi

PRD FR-7.1–2, 7.5–8, 7.13, FR-8.12, NFR-2/NFR-9;
schema §§3.1–3.2, 11; API-SPEC §§8.1, 9.8. Verifikasi ID/EN, timezone, input kosong/
whitespace, nominal invalid, akun dilewati, registrasi gagal, completion offline,
back/draft, retry identity, ponsel/keyboard dan Home landing.
