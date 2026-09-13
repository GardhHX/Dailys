# Antislop Splash

13 September 2026. Mode **DURING**, sudah dipilih pengguna sebelumnya.
Delivery Gate **PASS untuk preview browser**, bukan startup/migration native.

## Design Read dan alasan

Startup transien mahasiswa mengikuti Dailys: ENERGY 2 / RHYTHM 2 / MOTION 1,
Segoe UI, latar netral hangat dan indigo. Identitas teks dan status menjadi satu
kelompok fokus karena Splash hanya menyiapkan state lokal. Whitespace menempatkan
kelompok tersebut di tengah; pesan gagal beralih rata kiri agar alasan dan aksi
mudah dibaca. Tidak ada kartu, modal, grafik, logo baru, tagline atau statistik.
Kontrol contoh ditempatkan di luar produk supaya Splash tidak memperoleh navigasi
tambahan. Indigo dipakai untuk retry/progress nyata pada desain, bukan dekorasi.
Frame/radius luar hanya batas representasi jendela preview, bukan kartu UI startup.
Radius tombol 6 px mengikuti token. Tidak ada shadow, animasi logo atau spinner.

## Delivery Gate

### Hard Gate

- R-02 PASS: fragmen diperiksa tanpa em dash.
- R-03 PASS: 288 responsive cases offline dan 192 canvas; overflow descendant diperiksa pada konten minimum 320 px.
- R-17 PASS: tidak ada statistik/benchmark; 60% hanya fixture opsional berlabel contoh, bukan hasil SQLite.
- R-18 PASS: tidak ada testimonial/orang fiktif.
- R-23 PASS: wordmark teks Dailys dan token tersedia; tanpa asset/navigasi baru dalam produk.
- R-24 PASS: readiness lokal contoh membuka Home/onboarding offline; canvas menampilkan label tujuan, tanpa ghost link.
- R-25 PASS: delapan pasangan teks rendered per runner memenuhi AA; status/background 6.18:1 terang dan 9.29:1 gelap.
- R-26 PASS: dua belas pilihan kondisi, bahasa/tema, panduan/tutup, retry serta readiness mempunyai handler dan diperiksa.
- R-27 PASS: normal/new install, memuat, lima keadaan gagal dan retry tersedia; tidak ada aksi reset/skip yang menyembunyikan error.
- R-28 PASS: tidak ada FAQ.
- R-32 PASS: label native, Enter retry, Escape menutup panduan, fokus kembali serta outline solid diperiksa.
- R-33 PASS: source/CSS ditulis langsung melalui patch; generator hanya membungkus sumber dan routing acuan.
- R-34 PASS: terang/gelap diuji pada seluruh ukuran, bahasa dan keadaan.
- R-35 PASS: runner offline/canvas dan paket dijalankan, click-through/retry/routing direkam; tidak ada page/console error Splash.
- R-36 PASS: tidak ada klaim benchmark atau pemulihan native; contoh rollback dinyatakan skenario contoh.
- R-37 PASS: Design Read dan dials dinyatakan sebelum source dibuat.
- R-38 PASS: konten contoh ditandai, file spec menjelaskan readiness/progress/retry simulasi.

### Purpose-Gate

- R-01 PASS: tanpa gradient; aksen untuk aksi/progress.
- R-04 PASS: tanpa icon/library dekoratif.
- R-06 PASS: Segoe UI mengikuti acuan Windows.
- R-07 PASS: tanpa pola latar.
- R-08 PASS: tanpa arrow dekoratif.
- R-09 PASS: tanpa badge marketing.
- R-10 PASS: tanpa glassmorphism.
- R-12 PASS: tanpa shadow/kartu mengambang.
- R-13 PASS: tanpa glow.
- R-14 PASS: tanpa feature cards; error memakai pesan/aksi langsung.
- R-19 PASS: tanpa motion looping; status berubah oleh interaksi prototype, bukan animasi pengisi.
- R-22 PASS: tanpa ilustrasi generik.

### Liveliness

- Dials PASS: ENERGY 2 / RHYTHM 2 / MOTION 1 eksplisit dan mengikuti DESIGN.md.
- Konsistensi PASS: satu kelompok identitas/status; state gagal berubah sesuai kebutuhan pesan dan aksi.
- Fokus PASS: wordmark/status menjadi fokus jalur normal, judul gagal/aksi menjadi fokus error.
- Whitespace PASS: memusatkan kesiapan transien; reflow mencegah pesan terpotong pada ukuran pendek/teks besar.
- Aksen PASS: indigo hanya aksi/progress, bukan seluruh latar.
- Identitas PASS: wordmark serta konteks local-first, backup, migration dan recovery timer Dailys.
- Design Read PASS: dinyatakan sebelum generasi.

### Craftsmanship dan Quality Locks

- C-1/R-31 PASS: alasan major layout/color/font/spacing tertulis dalam spec dan di atas.
- C-2 PASS: kontrol mempunyai efek; readiness/rollback/progress jujur sebagai simulasi.
- C-3/R-05 PASS: identitas/status/error berasal dari tugas startup, tanpa template landing/dashboard.
- C-4 PASS: viewport/bahasa/tema/keadaan dan empat simulasi teks 200% per runner diperiksa.
- C-5 PASS: tidak ada klaim pengguna/performa native yang dibuat-buat.
- R-11 PASS: radius mengikuti token kontrol/frame.
- R-15 PASS: CTA Coba lagi/Panduan pemulihan/Tutup panduan menyebut aksi.
- R-16 PASS: tanpa buzzword marketing.
- R-20 PASS: komposisi dan pesan startup mengikuti Dailys.
- R-21 PASS: sistem/terang/gelap bekerja; native mengikuti DeviceSettings.theme lokal sesuai kontrak terbaru.
- R-29 PASS: token semantik dengan satu indigo serta danger yang berteks.
- R-30 PASS: tidak mengkloning produk lain.

## Bukti dan batas

`qa-splash-results.json`: 288 = enam viewport 352–1440 × dua bahasa × dua tema ×
dua belas kondisi. Delapan pasangan teks, empat simulasi teks 200%, empat kondisi
data, tiga retry Enter, panduan click/close/Escape/fokus dan dua destination.
`qa-canvas-splash-results.json`: 192 = empat viewport 352–1024 × dua bahasa × dua
tema × dua belas kondisi, ditambah alur/kontras/teks yang sama. Lebar konten iframe
minimum 320 px. Simulasi teks bukan pengujian zoom/keyboard OS atau sertifikasi WCAG.

Checker skill memverifikasi status/background 6.18:1 dan 9.29:1; progress fill
terhadap bagian kosong 8.58:1 dan 9.61:1, outline/batas terhadap background 3.96:1
dan 5.75:1. Border diperiksa sebagai nonteks minimum 3:1, bukan warna body text.
Desktop/ponsel, error dan gelap ditinjau dari PNG. Paket: 40 layout/theme cases,
20 data states, empat dialog, shortcut Settings, sepuluh route utama dan dua galeri.
Enam source sebelumnya byte-identik dengan arsip v1.3.

Offline tidak melakukan HTTP/HTTPS. Canvas memakai tiga URL CDN pinned milik helper
renderer (Floating UI core/dom dan Lucide); fragment tidak memakai API/remote asset.
Tidak ada SQLite, backup, integrity check, migration, restore, OS permission, sync,
timer recovery atau benchmark native yang dijalankan. Startup ditahan sebagai
contoh untuk inspeksi; retry 220 ms serta progress 60% bukan parameter runtime.
