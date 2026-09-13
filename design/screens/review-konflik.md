# Review konflik

Acuan: [`../preview/review-konflik.html`](../preview/review-konflik.html),
[`../mockups/review-konflik-desktop.png`](../mockups/review-konflik-desktop.png),
[`../mockups/review-konflik-mobile.png`](../mockups/review-konflik-mobile.png).

## Hierarki dan layout

Pusat Sync → daftar review → detail satu record. Daftar menampilkan entity, judul,
jumlah kelompok, status dan label hanya-baca. Detail menampilkan versi **awal**,
**lokal**, **server**, kemudian pilihan per kelompok, bagian aman, dampak bila
transaksi, dan ringkasan keputusan. Versi awal hanya pembanding, tidak selectable.

Desktop memakai tiga kolom per kelompok. Pada lebar menengah versi awal melebar
di atas lokal/server; pada ponsel ketiganya menumpuk dengan urutan yang sama.
Radio native berlabel “Pakai lokal/server”; penanda dipilih mempunyai teks,
checked state dan warna. Tidak ada pilihan berdasarkan waktu “terbaru”.

## Unit pilihan

| Entity contoh | Kelompok | Pilihan atomik |
|---|---|---|
| Tugas | schedule | Deadline dan seluruh reminder bersama |
| Tugas | deskripsi | Singleton deskripsi lengkap |
| Transaksi | ledger | Akun/tujuan/kategori/nominal/tipe/arah adjustment/tanggal bersama |

Kelompok aman tetap digabung. Field identitas/immutable/server-owned/saldo/cache
streak/derived Activity bukan editor bebas. Picker tidak menawarkan nilai ketiga
atau textarea untuk mengubah kandidat saat review. Invariant domain tetap berlaku.

Pilihan semua kelompok konflik “server” masih dapat menghasilkan resolusi baru
jika kelompok aman berisi perubahan lokal. **Pakai seluruh versi server** merupakan
tindakan terpisah, dengan konfirmasi membuang seluruh mutation lokal termasuk
kelompok aman; sesudah refresh server, review boleh discarded tanpa request baru.

## Status review dan hasil

- `pending_review`: opening tidak menutup; pilihan belum menjadi mutation.
- Tinjau keputusan menampilkan pilihan setiap kelompok sebelum konfirmasi.
- `submitted`: keputusan masuk antrean lokal; record tetap ditahan. Offline tidak
  mengubahnya menjadi resolved. Record lain tetap dapat dipakai.
- Server accepted → `resolved`. New change ID, resolution_of notice formal, dan
  base_server_revision tepat pada reviewed_server_revision. Kelompok aman tetap
  sesuai hasil merge; tidak menerapkan sebagian kandidat yang konflik.
- Server changed → review baru, pilihan kelompok terdampak dibatalkan. Jangan
  melakukan merge otomatis kedua kali. Keputusan berikutnya memakai change ID baru.
- Rejection invariant → review tetap terbuka, alasan terlihat, pilihan bisa
  diperiksa/diperbaiki; tidak membuka edit record seolah resolusi berhasil.
- Refresh sebelum keputusan dapat menghasilkan draft review lokal dari base baru;
  draft belum pernah dikirim tidak mempunyai resolution_of formal.

Lock bersifat lokal pada record/aksi cascade/materializer yang menyentuhnya,
bukan lock server saat user berpikir. Timer running tetap menghitung tampilan;
mutation transisi sesi konflik ditahan.

## Dampak transaksi contoh

Server mempunyai expense bank Rp40.000. Lokal memilih expense tunai Rp45.000.
Mengganti ledger memberi bank +Rp40.000, tunai −Rp45.000, total −Rp5.000 terhadap
saldo server. Ini selisih, bukan saldo final pengguna. Efek lama dibalik dan
efek baru diterapkan atomik; angka saldo bukan pilihan field review.

## Kontrak dan gap

PRD NFR-4, FR-7.12; schema §§3.3–3.4, 18.1; API-SPEC §§8.4, 8.9.
Preview mempunyai fixture upsert Tugas/Transaksi, server_changed dan invariant
rejection. Detail stale delete/explicit restore, parent cascade, command timer/
Timebox, derived records, notice rebase dan konflik lintas entity belum seluruhnya
memiliki acuan visual. Jangan memakai dua contoh ini sebagai allowlist domain.
