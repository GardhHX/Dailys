# Dailys Documentation Index

**Versi:** 1.0  
**Terakhir diperbarui:** 13 September 2026

README ini menjadi pintu masuk dokumentasi Dailys.

Untuk implementasi UI, mulai dari [`DESIGN.md`](DESIGN.md) dan
[`galeri preview offline`](design/preview/index.html). Paket desain aktif memuat
Home, Tugas, Pomodoro, Keuangan, dan Habit, dengan screenshot desktop/ponsel,
token bersama, spesifikasi layar, dan [prompt vibecoding](design/VIBECODE-PROMPT.md).
Preview dapat dibuka langsung di browser tanpa instalasi.

Paket desain v1.4 juga memuat [Pusat Sync](design/screens/pusat-sync.md),
[review konflik](design/screens/review-konflik.md),
[onboarding](design/screens/onboarding.md), dan
[Weekly Review](design/screens/weekly-review.md), serta
[Global Settings](design/screens/settings.md), dan [Splash](design/screens/splash.md).
Keenamnya adalah alur global; jumlah tab utama tetap lima.
Arsip handoff aktif: `Dailys-design-v1.4.zip`.

## Urutan otoritas

Urutan otoritas untuk kontrak produk v1.0:

`PRD → schema → API-SPEC → OpenAPI → desain fitur`

1. [`PRD-Aplikasi-Produktivitas-Mahasiswa.md`](PRD-Aplikasi-Produktivitas-Mahasiswa.md)
   menetapkan scope, requirement, dan acceptance criteria produk.
2. [`schema.md`](schema.md) menetapkan entity, field, constraint, lifecycle, dan
   invariant data.
3. [`API-SPEC.md`](API-SPEC.md) menetapkan perilaku endpoint, error, idempotency,
   serta protokol sync.
4. [`openapi.yaml`](openapi.yaml) menetapkan bentuk request dan response yang
   dapat divalidasi mesin.
5. Dokumen desain fitur menetapkan presentasi visual dan interaksi tanpa mengubah
   requirement atau kontrak data/API:
   - [`DESIGN.md`](DESIGN.md) untuk arah visual dan aturan bersama;
   - [`Home`](design/screens/home.md), [`Tugas`](design/screens/tugas.md),
     [`Pomodoro`](design/screens/pomodoro.md),
     [`Keuangan`](design/screens/keuangan.md), dan [`Habit`](design/screens/habit.md)
     untuk komposisi dan interaksi layar;
   - [`manifest desain`](design/manifest.json) untuk pemetaan preview aktif.
   Coverage dan penyederhanaan dicatat pada [`design/GAPS.md`](design/GAPS.md).

Dokumen yang lebih rendah tidak boleh memperluas scope atau melemahkan invariant
dokumen di atasnya. Tim wajib memperbaiki seluruh dokumen yang bertentangan dalam
perubahan yang sama. Tim tidak boleh memakai urutan ini untuk membiarkan
kontradiksi tetap tersimpan.

## Dokumen pendukung

| Dokumen | Fungsi | Otoritas asal |
|---|---|---|
| [`ERD.md`](ERD.md) | Ringkasan visual relasi entity | `schema.md` |
| [`OPERATIONS.md`](OPERATIONS.md) | Backup, disaster recovery, benchmark NFR, dan release drill | PRD bagian NFR serta kontrak sync |
| [`design/mockups/`](design/mockups/) | Delapan belas gambar desktop/ponsel | Dokumen desain fitur terkait |
| [`design/preview/index.html`](design/preview/index.html) | Delapan desain interaktif offline | `DESIGN.md` dan spesifikasi layar |

Jika ERD berbeda dari schema, tim memperbaiki ERD. Jika prosedur operasional
membutuhkan perubahan produk, tim mengubah PRD lebih dahulu.

## Pemilik dokumen

| Dokumen | Pemilik keputusan | Reviewer wajib |
|---|---|---|
| PRD | Product owner | Tech lead dan design owner |
| schema | Data/backend owner | Client owner |
| API-SPEC dan OpenAPI | Backend/API owner | Client owner |
| [`DESIGN.md`](DESIGN.md) dan [`design/screens/`](design/screens/) | Design owner | Product owner dan client owner |
| OPERATIONS | Release/operations owner | Backend owner dan client owner |

Nama orang dapat berubah. Release checklist harus mencatat siapa yang menjalankan
setiap peran.

## Aturan perubahan

1. Perubahan scope dimulai di PRD. Tim memperbarui schema, API-SPEC, OpenAPI,
   DESIGN, ERD, dan OPERATIONS jika perubahan menyentuh dokumen tersebut.
2. Semua dokumen kontrak rilis harus memakai versi produk yang sama. OpenAPI
   memakai bentuk semver, misalnya `1.0.0`, untuk produk `1.0`.
3. OpenAPI v1.0 hanya memuat endpoint yang didukung pada v1.0. Rencana future
   tetap berada di PRD atau schema dan tidak muncul sebagai route aktif.
4. Endpoint public yang deprecated wajib mencantumkan versi mulai deprecated,
   tanggal deprecation RFC 9745, versi penghapusan, replacement, serta header
   deprecation pada response.
5. Pull request dokumentasi wajib lulus pemeriksaan link lokal, parsing YAML,
   referensi OpenAPI, operation ID unik, dan sinkronisasi discriminator sync.
6. Tim menambahkan keputusan kontrak ke changelog PRD. OPERATIONS menyimpan bukti
   benchmark dan restore drill sebagai artefak rilis, bukan di dalam repository
   dokumentasi ini.
7. Semua perubahan masuk lewat branch + Pull Request; tidak ada push langsung ke
   `main`. Konvensi penamaan branch dan langkahnya ada di [`CONTRIBUTING.md`](CONTRIBUTING.md).

## Status v1.0

Proyek ini berada pada tahap dokumentasi. Belum ada kode aplikasi, backend,
migration, atau hasil pengujian runtime. Seluruh fitur berstatus `direncanakan`.
Target v1.0 tetap Windows dan Android; Windows dimulai lebih dahulu.

| Tahap | Fokus | Status |
|---|---|---|
| M0 | Penyelarasan kontrak | Dokumentasi direvisi; validasi struktural lulus |
| M1 | Activity + Tugas lokal di Windows | Direncanakan |
| M2 | Android, sync dua perangkat, konflik dan recovery | Direncanakan |
| M3 | Pomodoro + Timebox | Direncanakan |
| M4 | Habit kemudian Keuangan | Direncanakan |
| M5 | Weekly Review, seluruh acceptance dan NFR v1.0 | Direncanakan |

Kriteria selesai dan keputusan produk berada pada
[PRD bagian 3.1](PRD-Aplikasi-Produktivitas-Mahasiswa.md#31-tahapan-implementasi-dan-bukti-selesai).
[API bagian 8](API-SPEC.md#8-sync-protocol) menetapkan merge tiga versi, review
konflik, dan recovery. [OPERATIONS](OPERATIONS.md) membedakan gate pengembangan,
milestone, dan rilis.

Tidak ada keputusan produk terbuka yang menghalangi M0. Pemilik pekerjaan mengisi
bukti berikut ketika tersedia: repository/commit untuk status `diimplementasikan`,
artefak test beserta platform untuk `diverifikasi`, serta log benchmark dan restore
untuk rilis. Jangan menaikkan status berdasarkan kelengkapan dokumentasi saja.

Revisi dokumentasi kontrak mencakup Markdown dan OpenAPI. `DESIGN.md` menyimpan
arah visual aktif dari preview 12 September 2026. Paket desain belum mencakup
seluruh layar global; design owner tetap perlu merancang presentasi review/recovery
sebelum gate UI M2. Bukti browser preview tidak menaikkan status implementasi native.

## Pemeriksaan revisi dokumentasi

Pemeriksaan lokal revisi 6 September 2026 mencakup parsing YAML tanpa duplicate
key, operation ID unik, schema dan referensi internal, pemetaan entity sync,
katalog kelompok merge, tautan Markdown, dan konsistensi jumlah entity ERD.
Hasilnya: 64 path, 97 operation, 199 component schema, 19 tipe entity sync,
serta 32 entity/table v1.0 pada ERD. Enam dokumen Markdown dalam scope tidak
memiliki tautan lokal yang putus.
Pemeriksaan ini tidak menjalankan aplikasi, migration, database server,
benchmark, atau restore drill.
