# Keuangan

Acuan: [`../preview/keuangan.html`](../preview/keuangan.html),
[`../mockups/keuangan-desktop.png`](../mockups/keuangan-desktop.png),
[`../mockups/keuangan-mobile.png`](../mockups/keuangan-mobile.png).

## Hierarki

Judul/catat transaksi → tab Ringkasan/Transaksi/Insight/Akun/Kategori. Ringkasan
memprioritaskan bidang saldo total aktif, arus periode, rincian akun, transaksi
terbaru, dan pie pengeluaran. Nominal memiliki tanda dan tipe tertulis; transfer
tidak diberi label pemasukan/pengeluaran. Ponsel menumpuk saldo/akun/ledger/chart.

## Interaksi dan aturan

- Modal income/expense: numpad Rupiah, nominal positif integer, tipe, kategori
  sesuai tipe, akun aktif, tanggal, catatan opsional. Detail menyediakan edit dan
  hapus dengan konfirmasi.
- Transfer modal: sumber berbeda dari tujuan. Create/edit/delete membalik efek
  lama lalu menerapkan efek baru pada dua akun secara atomik pada implementasi.
- Saldo berasal dari opening + retained ledger. Opening hanya dapat dikoreksi
  sebelum ada retained ledger; setelah itu target saldo membuat adjustment
  selisih. Delta nol tidak membuat record. Adjustment tidak diedit/dihapus biasa.
- Arsip akun mengeluarkannya dari total aktif/picker; histori tetap ada. Saldo
  nonzero diperlihatkan sebelum konfirmasi arsip.
- List transaksi memakai filter akun/kategori/tipe/rentang tanggal; prev/next bulan.
- Pie hanya expense, kategori berwarna stabil dengan legenda nominal. Tren
  income/expense 12 bulan memasukkan bulan nol, menyediakan angka tiap bulan;
  transfer/adjustment dikecualikan. Label periode pie dan tren berbeda jika perlu.
- Kategori income/expense terpisah; seed sesuai PRD. Custom kategori dapat
  ditambahkan dan diarsipkan/diaktifkan kembali pada contoh.

## Kontrak dan gap

PRD FR-4.1–4.17; schema §§11–12; API-SPEC §9.6. Nilai contoh bukan saldo awal
pengguna. Browser ledger tidak membuktikan transaction database. Edit/hapus
resource yang belum digunakan dan editor kategori lengkap masih gap.

## Periksa saat implementasi

Saldo negatif/nol, akun arsip, nominal invalid/besar, transfer satu akun,
edit/delete dua sisi saldo, immutable opening, koreksi delta nol, adjustment
excluded, filter tanpa hasil, kategori arsip, bulan nol, dua tema/modal ponsel.
