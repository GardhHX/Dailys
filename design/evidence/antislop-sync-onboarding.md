# Antislop: Pusat Sync, konflik, onboarding

Tanggal: 12 September 2026. Status: **PASS untuk artefak preview**.
Sumber aktif: `../source/dailys-sync-onboarding.html`; snapshot canvas disimpan
terpisah pada folder visualisasi percakapan. Bukan implementasi native/protokol.

## Design Read

Meneruskan acuan Dailys: mahasiswa, pekerjaan personal, Windows/Android, modern
dengan kontras tinggi. ENERGY 2 / RHYTHM 2 / MOTION 1. Netral hangat, indigo tegas,
Segoe UI, opaque surfaces; status selalu memiliki teks/native checked state.

- Sync memprioritaskan keputusan yang menunggu, bukan statistik infrastruktur.
  Banner indigo mengarahkan user ke record konflik; antrean tetap berupa daftar.
- Konflik memakai komposisi tiga versi karena keputusan membutuhkan base/lokal/
  server. Radio hanya pada kandidat; ringkasan menunjukkan keputusan atomik.
- Ledger menyertakan dampak saldo, tidak menawarkan field saldo sebagai editor.
- Onboarding memakai form dan penjelasan local-first; stepper empat tahap berasal
  dari field setup PRD, bukan pola marketing tiga langkah.
- Bidang indigo, radius 4/6/9/12, garis pemisah, dan spacing mengikuti paket.
  Shadow hanya dialog; tidak ada glass/glow/gradient/ilustrasi/dekorasi looping.
- Progress async singkat hanya simulasi tindakan; kontrol skenario berlabel contoh
  bukan bagian UI produk. Tidak menyimulasikan angka throughput/success rate.

## Traceability

| Acuan | Preview |
|---|---|
| PRD FR-7.12; API §§8.9, 9.8 | Status/sukses terakhir/pending/rejected/review/recovery/manual sync |
| PRD NFR-2–4, 9; schema §§3.3–3.4 | Offline tersedia, grouped choices, record lock sampai final |
| API §8.4; schema §18.1 | Base/local/server, safe groups, resolution ID/base, server_changed/rejection |
| API §§8.7–8.9; schema §§3.5–3.6 | Salinan sebelum staging/replacement, failure/expiry, no auto replay |
| API §8.9; schema §3.6 | Never accepted/accepted missing/superseded/manual, consent dan saldo |
| PRD FR-7.13, FR-7.1–2; API §§8.1, 9.8 | ID/EN/timezone, device register, offline lanjut, optional account |
| PRD FR-7.7–8, 7.13 | Tidak menampilkan credential; tidak meminta izin notifikasi saat setup |

## Delivery Gate

- Hard Gate PASS: R-02 fragment tanpa em dash; R-03 192 responsive cases root/
  descendant tanpa overflow; R-17/18/23/36/38 fixture berlabel dan tidak ada klaim
  runtime; R-24 navigasi global tersedia tanpa menambah primary tab; R-25 12 view/
  theme pasangan teks visible non-disabled memenuhi perhitungan AA; R-26/35 alur
  klik/form/modal/status diuji dan error JS kosong; R-27 kosong/memuat/gagal/retry
  untuk list status/review serta registration/snapshot failure; R-28 tidak ada
  FAQ; R-32 native controls, fokus radio dipertahankan, Tab/Enter/Escape; R-33 source
  ditulis langsung dengan patch, generator hanya membungkus fragment; R-34 dua
  tema; R-37 dials dan brief eksplisit.
- Purpose Gate PASS: R-01/07 bidang indigo untuk hierarchy, bukan pola latar;
  R-04 tidak ada emoji/icon dekoratif; R-06 tipografi Windows; R-08 chevron untuk
  kembali/route; R-09 status hanya-baca membawa makna; R-10/12/13 tidak ada glass/
  glow, shadow hanya modal; R-14 komposisi list/compare/form berbeda sesuai tugas;
  R-19 feedback tindakan tanpa loop; R-22 tidak ada asset ilustrasi generik.
- Liveliness PASS: dials 2/2/1, satu aksen dan motif planning Dailys; perhatian
  pada keputusan sync, perbandingan grouped conflicts, dan setup local-first.
  Whitespace membedakan keputusan dari konteks; ponsel reflow, bukan crop desktop.
- Craftsmanship/Quality Locks PASS: C-1/R-31 alasan tertulis; C-2 handler aktif dan
  status async lokal; C-3/R-05 komposisi mengikuti domain; C-4/R-21 reflow/light/
  dark/errors/modal/fokus diuji; C-5 fixture jujur dan bukti browser dibedakan dari
  native; R-11 radius bervariasi; R-15/16 CTA spesifik; R-20/30 identitas Dailys;
  R-29 palet mengikuti token bersama dan state memakai label selain warna.

## Bukti dan batas

`qa-sync-results.json`: 192 = 12 tampilan × 8 viewport 352–1440 px × 2 tema;
12 view/theme pemeriksaan teks; accepted/server_changed/rejected, all-server
discard tanpa request, offline queued, ledger impact, deterministic rejection
correction, copy-before-replace/failure/expiry, consent replay, superseded dan
ambiguous tombstone, ID/EN, timezone, offline skip, signed opening balance,
validation, registered completion dan Home route. Semua tanpa request HTTP/HTTPS.

`qa-canvas-sync-results.json`: renderer canvas, tiga layar × dua viewport, grouped
choice dan dialog Escape; tidak ada JS error. Enam PNG desktop/ponsel diperiksa.

Tidak ada backup/key/database/provisioning/snapshot/request sungguhan. Status receipt,
balance effects dan acceptance berasal dari fixture. Tidak seluruh field/entity/
rebase/cascade/restore dirancang; timezone berupa preset, lokalisasi global/native
accessibility belum penuh. Ini bukan sertifikasi WCAG atau acceptance native.
Rincian tersisa pada `../GAPS.md` dan spesifikasi tiap alur.
