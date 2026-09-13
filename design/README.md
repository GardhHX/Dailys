# Paket desain Dailys

Pintu masuk: [`../DESIGN.md`](../DESIGN.md). Buka
[`preview/index.html`](preview/index.html) langsung di browser modern. Paket ini
bisa disalin ke komputer lain; semua asset dan halaman memakai path relatif dan
tidak mengambil font, script, atau gambar dari internet.

## Isi

| Lokasi | Pemakaian |
|---|---|
| `../DESIGN.md` | Arah visual, otoritas, token ringkas, aturan bersama |
| `../AGENTS.md` | Pintu masuk untuk coding agent |
| [`VIBECODE-PROMPT.md`](VIBECODE-PROMPT.md) | Prompt implementasi siap salin |
| [`tokens.json`](tokens.json) | Token semantik terang/gelap |
| [`screens/home.md`](screens/home.md) | Home, Timebox, Next deadline, Habits |
| [`screens/tugas.md`](screens/tugas.md) | Tugas, mata kuliah, CourseNote |
| [`screens/pomodoro.md`](screens/pomodoro.md) | Timer, sesi, statistik |
| [`screens/keuangan.md`](screens/keuangan.md) | Saldo, ledger, akun, kategori, insight |
| [`screens/habit.md`](screens/habit.md) | Target hari, streak, kalender, izin |
| [`screens/pusat-sync.md`](screens/pusat-sync.md) | Status, antrean, perangkat dan salinan/snapshot/recovery |
| [`screens/review-konflik.md`](screens/review-konflik.md) | Pilihan kelompok, dampak saldo dan resolusi |
| [`screens/onboarding.md`](screens/onboarding.md) | Setup bahasa/timezone, registrasi/offline dan akun opsional |
| [`screens/weekly-review.md`](screens/weekly-review.md) | Jurnal, ringkasan, kandidat, draft/promotion, gate planning dan beban tujuh hari |
| [`screens/settings.md`](screens/settings.md) | Preferensi tersinkron/perangkat, Pomodoro, notifikasi, Pusat Sync dan Tentang |
| [`screens/splash.md`](screens/splash.md) | Buka database, migration, recovery timer dan rute keluar (spec; preview/mockup belum ada) |
| [`GAPS.md`](GAPS.md) | Coverage, penyederhanaan, desain yang belum tersedia |
| [`preview/index.html`](preview/index.html) | Galeri sepuluh desain; menu utama tetap lima |
| `mockups/` | Dua puluh PNG pembanding desktop/ponsel; tambahan gelap Settings |
| `source/` | Enam fragmen HTML dari canvas percakapan |
| `evidence/` | Analisis, laporan antislop, hasil dan skrip QA preview asli |
| [`manifest.json`](manifest.json) | Pemetaan layar/file dan SHA-256 sumber |
| [`build_preview.py`](build_preview.py) | Generator halaman offline dari sumber |
| [`check_package.cjs`](check_package.cjs) dan [`check_links.py`](check_links.py) | Verifikasi kemasan/routing dan referensi lokal |
| [`check_sync.cjs`](check_sync.cjs) | Reflow dan alur sync/konflik/onboarding |
| [`check_review.cjs`](check_review.cjs) | Reflow, jurnal, freeze, draft/promotion, gate dan workload Weekly Review |
| [`check_settings.cjs`](check_settings.cjs) | Reflow, preferensi, validasi, izin, registrasi, fokus, kontras dan routing Settings; menerima path renderer canvas opsional |
| [`pack_design.py`](pack_design.py) | Membuat ZIP portable dan memeriksa CRC serta byte semua file |
| [`PACKAGE-QA.md`](PACKAGE-QA.md) | Hasil verifikasi paket offline |

Preview offline menambahkan toolbar acuan, kontrol keadaan data, icon SVG lokal,
dan routing antarlayar. Komposisi dan handler domain fragmen asli dipertahankan.
Pergantian halaman/reload mengembalikan state contoh; masing-masing fragmen tidak
berbagi database. Ini acuan implementasi, bukan aplikasi lima tab yang persisten.

Toolbar acuan di atas shell, galeri, dan pesan reset bukan bagian UI produk.
Jangan menyalin bagian tersebut ke aplikasi. Kontrol tema di dalam shell tetap
bagian contoh visual. Global Settings tersedia dengan kontrak user/device terpisah;
tema berkontrak sebagai preferensi per-device pada DeviceSettings lokal (schema 3.2;
PRD FR-7.15), tidak disinkronkan dan tidak masuk UserSettings.

## Bangun ulang

Python 3 standar, tanpa dependency tambahan:

```powershell
python design/build_preview.py
```

Edit sumber dan spesifikasi terkait terlebih dahulu, kemudian bangun ulang.
Jangan hanya mengedit HTML generated. Screenshot dan bukti QA historis tidak
otomatis berubah; hasilkan ulang setelah perubahan desain lalu perbarui manifest
dan laporan. Skrip QA asli di `evidence/` masih mencatat environment saat canvas
dibuat, termasuk path renderer/runtime; skrip itu bukan runner portable paket ini.

Arsip aktif `Dailys-design-v1.3.zip` di workspace berisi dokumentasi kontrak, arahan
agent, dan folder desain lengkap. Untuk berbagi, kirim ZIP dan minta penerima
membuka `design/preview/index.html` setelah ekstraksi.

Pada alur global, selector Layar contoh/Skenario sync/Hasil resolusi/Hasil snapshot
adalah kontrol prototype. Tidak termasuk Settings produksi. ZIP v1.0 adalah
snapshot paket lima layar sebelumnya; v1.1 menambah sync/konflik/onboarding.
v1.2 menambah Weekly Review. Gunakan v1.3 untuk handoff dengan Global Settings.
Selector skenario Settings dan keadaan Weekly Review
merupakan kontrol prototype; reload/pergantian skenario mengembalikan fixture.
