# Audit UI sesudah perbaikan

Tanggal: 14 September 2026. Acuan: DESIGN.md, design/README.md, spesifikasi layar, CSS sumber preview, mockup, tokens.json, dan GAPS.md. Perubahan working tree yang sudah ada dipertahankan.

## Perbaikan selesai

| Bagian | Hasil |
|---|---|
| Tipografi | Judul ponsel 28 px; Home compact 26 px; angka tanggal 17 px; pilihan mode Home 12 px; heading tindak lanjut 13 px. Heading jumlah tugas/modal tugas dan mata kuliah 20 px; filter 13 px; input/dropdown modal 16 px; label onboarding 12 px, timezone 16 px, teks panel informasi 12 px. Ukuran lokal mengikuti CSS, tanpa mengganti seluruh text theme. |
| Modal | Activity, Tugas, Mata kuliah dan CourseNote menggunakan header/body/footer dengan body bergulir, label di luar input, Tutup dan Batal. Enter pada judul menyimpan; Escape mengikuti route dialog. Gagal simpan mempertahankan input. |
| Checklist tugas | Opsional pada tambah/edit. Task dan checklist disimpan dalam satu transaksi. ID dan status selesai item lama dipertahankan; item baru mendapat ID baru, item dihapus memakai tombstone. Kegagalan baca mengunci Simpan tetapi pengguna dapat membatalkan atau retry. |
| Home | Metadata kategori/status membungkus tanpa ellipsis. Geometri desktop lebar mengikuti override sumber: rail 166, companion 290, padding horizontal 38/vertikal 32 dan gap 38. Companion ditumpuk pada lebar <=680, sesuai CSS Home. Strip tanggal ponsel tetap empat dan tiga kolom sesuai override CSS. |
| Settings | Sidebar tersembunyi <=736, lebar 170 pada ukuran <=960; delapan bagian. Label sumber pengguna/perangkat dan keterangan batas integrasi. Status sedang menyimpan/tersimpan/gagal/retry per field; draft gagal tidak hilang; tema/bahasa diterapkan setelah commit. Rentang angka dan penolakan invalid tersedia inline. |
| Copy | Pesan fitur belum tersedia tidak lagi menampilkan nama tabel/identifier teknis. Tidak mengklaim sinkronisasi, izin OS atau pengingat sudah bekerja. |
| Splash | Judul ponsel 28 px; failure rata kiri dengan lebar maksimum 480 dan panduan pemulihan inline. Panduan tidak menjalankan reset/restore atau mengklaim backup telah dibuat. |
| Acuan mingguan | Spesifikasi, sumber, preview, mockup dan token mengikuti grid tujuh hari dengan gulir horizontal pada ponsel sesuai instruksi pengguna. Manifest hash diperbarui. |

## Validasi

- Analisis Flutter: tidak ada masalah.
- Suite penuh: 122 tes lulus, 3 dilewati untuk fitur yang belum tersedia. Sesudah perubahan akhir, 14 tes matriks widget lintas ukuran/tema dengan pemeriksaan descendant lulus; tiga tes Home/ukuran 736 px lulus setelah penyamaan breakpoint CSS.
- Pengujian tambahan membuktikan checklist mempertahankan ID/done dan rollback ketika draft invalid; Settings mempertahankan draft gagal dan menerapkan locale hanya setelah retry sukses.
- Widget: 320, 440, 736, 860, 1408 px; terang/gelap; ID/EN dan teks 200%; kosong/memuat/gagal, modal dan fokus. Pemeriksaan batas descendant mengecualikan isi scroll horizontal yang disengaja serta box overlay indikator slider internal Flutter; box overlay ini bukan batas label yang dilukis.
- Acuan browser: 40 kombinasi layout/tema, 20 keadaan, 4 modal ponsel dan route lintas layar lulus. Home weekly diperiksa terpisah agar lebar grid hanya melampaui viewport di dalam area scroll. 289 referensi lokal dan 7 hash sumber valid.
- Native Windows: aplikasi QA dari kode proyek menggunakan database in-memory terpisah. Home/Tugas/modal Tugas/Settings terlihat langsung. Tema gelap berhasil disimpan dengan status di dekat field; jendela sekitar 392 px menampilkan Settings tanpa sidebar dan grid Home horizontal. Sesi QA ditutup; aplikasi Debug pengguna dan datanya tidak diubah.
- Build Windows release produksi dibuat kembali setelah QA. Output: build/windows/x64/runner/Release/dailys.exe.

## Gap yang tetap ada

- Bobot 650/750 pada CSS tidak identik dengan FontWeight diskret dan font Segoe UI statis Flutter. Ukuran font diperbaiki; kesamaan bobot/interpolasi font secara pixel belum terjamin.
- Timebox, Habit, Weekly Review, Sync/registrasi, binding izin/notifikasi/volume OS dan materializer/recovery lengkap tetap gap domain yang sudah ada. Pesan unavailable tidak dianggap implementasi fitur tersebut.
- Audit native bukan pengujian semua state. CourseNote, onboarding dan failure Splash diperiksa melalui kode/widget; Android/perangkat ponsel fisik belum diuji. Batas angka inline dan penyesuaian breakpoint Home terakhir diverifikasi melalui widget/build, bukan pengulangan seluruh sesi native.
- Render widget memuat Segoe UI regular untuk pengujian; gambar widget bukan bukti bobot font native. Audit ini tidak menyatakan kesamaan pixel penuh pada fitur yang sumber domainnya belum tersedia.
