# Verifikasi paket offline

Tanggal: 13 September 2026. Status: **PASS** untuk paket acuan desain browser.

## Paket aktif v1.4: Splash

Splash menambahkan preview startup lokal serta retry/panduan inline tanpa navigasi
produk. Paket kini memuat sebelas preview, tujuh source dan dua puluh dua PNG
pembanding desktop/ponsel. Arsip aktif `Dailys-design-v1.4.zip`; v1.3 tetap historis.

- [QA Splash offline](evidence/qa-splash-results.json): 288 responsive cases,
  delapan pasangan kontras, empat simulasi teks 200%, panduan/fokus, tiga retry
  Enter dan tujuan Home/onboarding.
- [QA Splash canvas](evidence/qa-canvas-splash-results.json): 192 responsive cases
  dengan dua bahasa/tema, kontras, teks besar dan interaksi pada iframe minimum 320 px.
- [Antislop DURING](evidence/antislop-splash.md): empat blok Delivery Gate PASS untuk
  artefak browser. Semua pekerjaan startup/progress/retry memakai contoh.
- Regresi paket: 40 layout/theme, 20 states, empat dialog, shortcut Settings,
  sepuluh route utama dan dua galeri; seluruh gambar galeri berhasil decode.
- Enam source sebelumnya byte-identik dengan v1.3. Referensi lokal/source hash
  diperiksa; ZIP diverifikasi entry, CRC dan byte oleh `pack_design.py`.
- Preview offline tanpa request remote. Canvas hanya memakai URL pinned helper
  renderer, tanpa API/asset remote dari source buatan.
- Benchmark, backup/migration/restore, lifecycle dan timer native belum dijalankan.

```powershell
node design/check_splash.cjs
node design/check_package.cjs
python design/check_links.py
python design/pack_design.py
```

## Riwayat paket v1.3: Global Settings

Global Settings menambahkan route global dari app bar, delapan bagian dengan
preferensi user/device terpisah, shortcut Pomodoro ke bagian yang sama, serta
tujuan Home/Weekly Review/Pusat Sync. Sepuluh preview, enam sumber, dua puluh PNG
pembanding desktop/ponsel. Arsip historis: `Dailys-design-v1.3.zip`.

- [QA Settings offline](evidence/qa-settings-results.json): 160 responsive cases,
  empat simulasi teks 200%, empat picker cases, 12 pasangan kontras, preferensi,
  validasi, timezone gagal/recompute, izin, registrasi dan routing.
- [QA Settings canvas](evidence/qa-canvas-settings-results.json): 80 responsive
  cases, empat simulasi teks 200%, empat picker cases, 12 pasangan kontras dan alur
  pada sandbox percakapan; konten minimum 320 px.
- [Antislop DURING](evidence/antislop-settings.md): empat blok Delivery Gate PASS
  untuk artefak browser. [Kontrak](evidence/settings-contract-check.md) menjelaskan
  kondisi tema saat QA (kini berkontrak sebagai `DeviceSettings.theme` per-device),
  system-settings native dan build metadata.
- Regresi `check_package.cjs`: 40 layout/theme, 20 states, empat dialog ponsel,
  shortcut Settings, sepuluh route utama dan dua galeri. Sync: 192 cases;
  Weekly Review: 128 cases. Screenshot pembanding diperbarui.
- Tidak ada page/console error Settings atau request remote offline. Canvas hanya
  memuat dependency pinned helper renderer; sumber tidak memakai API.
- `check_links.py` memeriksa referensi dan SHA-256 sumber. `pack_design.py`
  memeriksa entry/CRC/byte seluruh arsip. Arsip v1.0/v1.1/v1.2 tetap historis.

```powershell
node design/check_settings.cjs
python design/check_links.py
python design/pack_design.py
```

## Riwayat tambahan paket v1.2

Weekly Review ditambahkan sebagai route global dari shortcut Home. Paket memiliki
sembilan preview standalone dan satu galeri, lima sumber, sembilan layar dengan
acuan visual desktop/ponsel, serta delapan belas PNG pembanding. Saat v1.2 Settings
masih spec tertulis tanpa visual; seluruh gap native tetap berlaku. ZIP historis:
`Dailys-design-v1.2.zip`.

- [`qa-review-results.json`](evidence/qa-review-results.json): 128 layout/state/theme
  cases, 16 contrast views, 12 form promotion desktop/ponsel; jurnal, draft CRUD/
  discard, freeze, gate, workload/null estimate, retry dan routing lulus.
- [`qa-canvas-review-results.json`](evidence/qa-canvas-review-results.json): 44
  layout/text cases (40 responsive dan 4 simulasi teks 200%), tiga data conditions,
  completion/Enter/promotion di sandbox percakapan, cutoff manual dan workload kosong.
- [`laporan antislop`](evidence/antislop-weekly-review.md): Delivery Gate PASS untuk
  artefak preview dengan alasan visual, traceability dan batas bukti.
- Tidak ada page/console error. Standalone tidak melakukan request remote. Renderer
  canvas memuat dependency CDN pinned milik skill; fragment tidak memakai API
  atau mengambil asset remote.
- [`pack_design.py`](pack_design.py) membuat ZIP dan memverifikasi daftar entry,
  CRC, serta isi byte setiap file. Arsip v1.0/v1.1 dipertahankan sebagai snapshot.

Runner memakai Playwright/Edge headless. Contoh menjalankan pemeriksaan baru:

```powershell
node design/check_review.cjs
python design/check_links.py
python design/pack_design.py
```

Runner canvas `evidence/qa-canvas-review.cjs` menerima absolute path HTML hasil
renderer skill. Ia memeriksa child iframe; bukan bukti native Windows/Android.

## Tambahan paket v1.1

Pusat Sync, review konflik dan onboarding ditambahkan sebagai alur global, bukan
menu utama baru. Pada rilis v1.1, delapan file preview, empat source, delapan
spesifikasi visual dan enam belas gambar dipetakan manifest. ZIP v1.1 tetap snapshot
historis; gunakan v1.4 untuk handoff terbaru.

[`evidence/qa-sync-results.json`](evidence/qa-sync-results.json) mencatat 192
pemeriksaan responsif tambahan dan alur grouped resolution, recovery consent,
registration/offline onboarding. [`evidence/qa-canvas-sync-results.json`](evidence/qa-canvas-sync-results.json)
mencatat enam layout renderer percakapan. Laporan
[`antislop global`](evidence/antislop-sync-onboarding.md) menjelaskan traceability,
hasil contrast, dan batas preview. Bukti lima layar di bawah tetap terpisah.

## Paket awal v1.0

Lima halaman standalone dari fragmen canvas asli, satu galeri, lima spesifikasi,
token semantik, manifest sumber, dan screenshot desktop/ponsel. Tiga sumber asli
disalin utuh; SHA-256 disimpan pada `manifest.json`. Generator hanya menambahkan
host offline, SVG navigasi lokal, pemilihan keadaan contoh, dan routing lima layar.

## Verifikasi kemasan bersama

[`evidence/package-qa.json`](evidence/package-qa.json) dan
[`check_package.cjs`](check_package.cjs):

- 40 pemeriksaan layout/tema: lima layar × empat viewport (1440, 860, 680, 352 px)
  × dua tema. Lebar terkecil memberi konten preview 320 px setelah margin host.
- 20 keadaan data: terisi, kosong, memuat, gagal di setiap layar.
- Lima dialog pada ponsel: tambah Activity, tambah Tugas, Timer & Alarm, transaksi,
  tambah Habit; dialog terlihat, tanpa overflow horizontal, Escape menutupnya.
- Sepuluh perpindahan menu: kelima tujuan diklik pada desktop dan ponsel; halaman
  dan root yang sesuai tersedia, nav tujuan tidak disabled.
- Galeri sembilan layar pada 1440/352 px, gambar berhasil decode dan screenshot dibuat.
- Tidak ada page error JavaScript atau request HTTP/HTTPS saat pemeriksaan.
- Root dan descendant diperiksa untuk batas horizontal serta scrollWidth.

[`check_links.py`](check_links.py) memeriksa tautan lokal pada dokumen acuan dan
HTML, file manifest, serta checksum sumber. Galeri desktop/ponsel diperiksa visual.

QA menggunakan Playwright dengan Edge headless. `check_package.cjs` membutuhkan
Playwright yang tersedia pada environment QA; preview sendiri tidak membutuhkan
dependency tersebut. Untuk menjalankan ulang pada environment yang sudah memiliki
Playwright dan browser Edge:

```powershell
node design/check_package.cjs
python design/check_links.py
```

Untuk browser Playwright lain, set `DESIGN_BROWSER_CHANNEL` sesuai browser yang
tersedia. Jalankan `build_preview.py` setelah mengubah sumber. Test ini memeriksa
kemasan/routing, bukan mengulang seluruh test domain canvas.

## Bukti canvas yang dipertahankan

Laporan dan JSON asli pada `evidence/` mencatat 54 pemeriksaan Home, 96 Tugas/
Pomodoro, dan 144 Keuangan/Habit, beserta click-through masing-masing. Total 294
pemeriksaan responsif historis tersebut terpisah dari 40 pemeriksaan kemasan baru.
Screenshot produk asli dipertahankan, termasuk keadaan contoh yang dipilih saat
QA canvas; label nav screenshot lama tidak menentukan routing paket aktif.

## Batas

Preview offline tetap memakai state sementara dan tidak berbagi store antarlayar.
Tidak membuktikan implementasi Flutter/Windows/Android, SQLite, REST/sync, ledger
database atomik, alarm OS, background timer/recovery, benchmark, atau seluruh
acceptance PRD. Coverage dan perbedaan normatif ada di [`GAPS.md`](GAPS.md).
