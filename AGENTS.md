# Acuan kerja Dailys

Untuk implementasi UI, baca `DESIGN.md`, `design/README.md`, lalu spesifikasi
layar terkait di `design/screens/`. Preview aktif ada di `design/preview/index.html`;
gambar pembanding ada di `design/mockups/`. Panduan prompt ada di
`design/VIBECODE-PROMPT.md`.

Pertahankan komposisi, hierarki, warna, tipografi, dan pola interaksi pada acuan
tersebut. Gunakan `design/tokens.json` untuk token bersama. Jangan membuat arah
visual baru untuk layar yang sudah memiliki preview kecuali tugas pengguna
meminta perubahan desain.

Otoritas kontrak tetap `PRD → schema → API-SPEC → OpenAPI → desain`. Baca
`design/GAPS.md` sebelum menganggap suatu flow sudah lengkap. Preview memakai
data contoh dan state browser sementara, bukan kode produksi atau bukti runtime
native. Implementasi harus memakai kontrak domain sebenarnya, bukan menyalin
fixture, tanggal tetap, atau rumus sederhana dari mockup.

Untuk perubahan UI, bandingkan hasil desktop/ponsel dan terang/gelap dengan acuan,
periksa overflow descendant, fokus keyboard, serta keadaan kosong/memuat/gagal.
Laporkan bagian yang selesai dan gap yang masih ada secara terpisah.
