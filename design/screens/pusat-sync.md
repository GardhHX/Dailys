# Pusat Sync dan pemulihan

Acuan: [`../preview/pusat-sync.html`](../preview/pusat-sync.html),
[`../mockups/pusat-sync-desktop.png`](../mockups/pusat-sync-desktop.png),
[`../mockups/pusat-sync-mobile.png`](../mockups/pusat-sync-mobile.png).

## Tempat dan hierarki

Settings → Pusat Sync. Ini route global, bukan tab utama keenam. Header menyediakan
kembali dan Sync sekarang. Banner keputusan menjadi fokus jika ada konflik;
berikutnya status sync, sukses terakhir, lalu Antrean/Perangkat/Riwayat. Kolom
pendamping menjelaskan konteks perangkat dan penyimpanan lokal. Ponsel menumpuk
konten; jumlah dan kondisi memakai label, bukan titik warna saja.

Data contoh: tiga perubahan pending, dua konflik, satu rejection, dua perangkat.
Angka berasal dari fixture preview berlabel dan bukan statistik pengguna.

## Keadaan dan tindakan

| State domain/kondisi | Presentasi | Tindakan |
|---|---|---|
| success/idle tanpa antrean | Tersinkron, sukses terakhir, antrean kosong | Sync manual tetap tersedia |
| pending/review_required | Banner review belum selesai, antrean dan record ditahan | Tinjau konflik; sync record lain tetap tersedia |
| syncing | Menyinkronkan, CTA disabled selama request aktif | Tidak membuat request ganda |
| offline | Perubahan tersimpan lokal, menunggu koneksi | Core app tetap tersedia |
| timeout/5xx | Server belum dapat dihubungi, data lokal tetap ada | Retry transient dengan identitas/body yang sama |
| deterministic rejected | Perlu diperbaiki, alasan dan langkah spesifik | Perbaikan memakai change ID baru; bukan blind retry |
| registrasi gagal | Registrasi perangkat tertunda | Daftarkan perangkat saat koneksi tersedia; offline tetap bisa |
| DEVICE_REVOKED | Akses sync dicabut | Tidak mencoba membuka revoked device dengan registrasi ulang biasa; provisioning oleh pengelola tepercaya |
| generation/epoch/cursor/base tidak tersedia | Pemulihan diperlukan | Hentikan sync biasa, amankan lokal, registrasi/session sesuai kontrak, snapshot dan review |
| status lokal gagal dibaca | Status belum dapat dibaca | Retry pembacaan tanpa menghapus antrean |

UI produk menampilkan instruksi, bukan error protokol mentah, cursor, generation
UUID, bearer key, receipt hash atau log berisi secret. Nama kode pada tabel ini
merupakan pemetaan implementasi, bukan copy layar.

## Antrean

Menunggu dikirim mempunyai jenis, judul, dan ringkasan perubahan. Detail menjelaskan
bahwa hasil lokal sudah disimpan. Satu request aktif per entity; body dibekukan
ketika dikirim, edit berikutnya menjadi draft. Accepted/pull tidak boleh menimpa
draft yang lebih baru. Membuka konflik tidak menyelesaikan review.

Perlu diperbaiki mencantumkan alasan domain. Contoh kategori transaksi diarsipkan
membuka modal kategori aktif; perbaikan menjadi perubahan baru, menjaga nominal/
akun contoh. Editor umum untuk seluruh jenis rejection masih memerlukan desain.

## Pemulihan: salinan → snapshot → review

1. Tahan write lokal sementara; read tetap tersedia dari data lama. Buat salinan
   terenkripsi domain/base/outbox/konflik/jurnal dengan manifest/hash terverifikasi.
2. Ambil frozen pages ke staging, verifikasi count/byte/ID, lalu replace seluruh
   synced state secara atomik. Tidak merge halaman parsial ke state aktif.
   DeviceSettings dan secret lokal tetap; UserSettings mengikuti snapshot.
3. Complete session dan lanjutkan pull dari watermark. Write dibuka kecuali record
   dalam review. Gagal/expired tidak menghapus data lama, salinan atau jurnal.
4. Tampilkan kandidat `never_accepted`, `accepted_missing`, `superseded`,
   `manual_review`. Receipt ambigu tidak masuk never_accepted. Superseded tidak
   direplay; manual_review diperiksa satu per satu, bukan checkbox massal.
5. Persetujuan replay menampilkan jumlah, jenis, perbandingan dan dampak saldo.
   Tidak ada replay otomatis, termasuk never_accepted. Mutation baru memakai
   base target terbaru dan lineage lokal. Parent/tombstone memerlukan tindakan
   eksplisit; efek transaksi yang sudah ada tidak digandakan.

Salinan dipertahankan sampai semua kandidat selesai dan minimal 30 hari; jurnal
v1.0 tidak dibersihkan otomatis. Preview mensimulasikan hasil snapshot/replay;
tidak membuat backup, key, staging database, session, atau request sebenarnya.

## Kontrak

PRD FR-7.12, NFR-2–6, NFR-9–10; schema §§3.2–3.8, 18.1–18.2, 19;
API-SPEC §§8.1, 8.4, 8.7–8.9, 9.8. Retry/generation/revocation mengikuti kontrak
tersebut walaupun progress preview memakai langkah pendek.
