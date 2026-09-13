# Antislop Global Settings

13 September 2026. Mode **DURING**, sudah dipilih pengguna pada percakapan ini.
Delivery Gate **PASS untuk preview browser**, bukan implementasi native.

## Design Read dan alasan

Pengaturan personal mahasiswa mengikuti Dailys yang sudah tersedia:
ENERGY 2 / RHYTHM 2 / MOTION 1, netral hangat, indigo, Segoe UI dan kontras tinggi.
Desktop memakai daftar bagian kiri dan satu panel isi; ponsel menumpuk delapan
bagian dalam urutan draft. Pembagian ini membantu menemukan preferensi tanpa
menambah tab utama. Label lintas perangkat/lokal menjelaskan sumber data.
Status simpan dekat kontrol membantu menangani field yang gagal tanpa kehilangan
input. Aksen dipakai untuk pilihan aktif dan akses Pusat Sync; bukan latar dekoratif.
Tidak ada chart, avatar, ilustrasi, skor, slogan atau kartu fitur pengisi.
Radius 4/6/9/12 mengikuti token, permukaan opaque, shadow hanya pada dialog.

[Pemeriksaan kontrak](settings-contract-check.md) memetakan sembilan field user,
izin/volume lokal, zona, sesi running dan Weekly Review. Kontrak tema serta binding
OS ditandai sebagai gap. Semua data diberi label contoh.

## Delivery Gate

### Hard Gate: PASS

| Aturan | Bukti |
|---|---|
| R-02 | Sumber diperiksa tanpa em dash |
| R-03 | 160 responsive cases offline dan 80 canvas; overflow root/descendant diperiksa, konten minimum 320 px |
| R-17, R-18 | Semua angka berlabel contoh; tidak ada tren pengguna/testimonial |
| R-23 | Token, komposisi Dailys dan lima menu dipertahankan; wordmark teks |
| R-24 | 22 route global dan dua shortcut Pomodoro diuji; canvas menunjukkan tujuan dan tombol kembali |
| R-25 | 12 pasangan warna rendered per runner memenuhi 4.5:1. Checker skill memeriksa delapan pasangan token; border kontrol memenuhi 3:1 |
| R-26 | Save, retry, validasi, picker, bahasa, tema, izin, registrasi dan sync mempunyai handler yang diuji |
| R-27 | Kosong/memuat/gagal baca, gagal simpan, invalid, denied, registrasi gagal dan recovery tersedia; input dipertahankan |
| R-28 | Tidak ada FAQ |
| R-32 | Label native, Tab/fokus terlihat, Enter menyimpan field, Escape menutup dialog dan mengembalikan fokus; empat picker/theme/width cases per runner |
| R-33 | Source/CSS ditulis langsung melalui patch; generator membungkus sumber, tidak mengedit source/CSS via replacement |
| R-34 | Terang/gelap diuji pada seluruh viewport/state dan picker |
| R-35 | Runner offline/canvas serta regresi paket/sync/review dijalankan; tidak ada page/console error pada Settings |
| R-36 | Tidak ada klaim keamanan/performa/native yang tidak diuji |
| R-37 | Design Read dan dials dinyatakan sebelum generasi |
| R-38 | Fixture, simulasi dan batas native dijelaskan |

### Purpose-Gate: PASS

- R-01 PASS: aksen memberi prioritas, tanpa gradient.
- R-04 PASS: tidak ada library/icon dekoratif pada fragment.
- R-06 PASS: Segoe UI mengikuti Windows.
- R-07 PASS: tidak ada pola latar.
- R-08 PASS: chevron hanya untuk kembali.
- R-09 PASS: label hanya sumber/state.
- R-10 PASS: tidak ada glass.
- R-12 PASS: shadow hanya elevasi dialog.
- R-13 PASS: tidak ada glow.
- R-14 PASS: baris pengaturan berkelompok sesuai tipe kontrol.
- R-19 PASS: feedback fokus, hover dan teks; tanpa gerak looping.
- R-22 PASS: tidak ada ilustrasi generik.

### Liveliness: PASS

Dials mengikuti DESIGN.md. Hierarki judul bagian, baris kontrol, field durasi,
informasi perangkat dan ringkasan Sync berbeda menurut fungsi. Whitespace memisahkan
bagian dan status tanpa filler. Indigo menandai pilihan/aksi; teks menjelaskan
status. Identitas layar berasal dari waktu lokal, fase Pomodoro, Minggu review,
preferensi lintas perangkat serta sync offline Dailys. Design Read dicatat dahulu.

### Craftsmanship dan Quality Locks: PASS

- C-1/R-31 PASS: alasan visual dan copy tertulis.
- C-2 PASS: seluruh aksi memiliki efek/tujuan.
- C-3/R-05 PASS: delapan bagian berasal dari draft.
- C-4 PASS: tema, state, viewport, keyboard, picker dan empat simulasi teks 200% per runner diperiksa.
- C-5 PASS: fixture berlabel.
- R-11 PASS: radius bervariasi.
- R-15 PASS: CTA menyebut aksi.
- R-16 PASS: tanpa buzzword marketing.
- R-20 PASS: komposisi sesuai pengaturan personal.
- R-21 PASS: system/light/dark tersedia.
- R-29 PASS: token semantik dengan danger/success berteks.
- R-30 PASS: arah Dailys dipertahankan.

## Bukti dan batas

- `qa-settings-results.json`: 160 = delapan viewport 352–1440 × dua tema ×
  sepuluh keadaan/skenario; empat simulasi teks 200%, empat picker cases,
  12 pasangan teks rendered, preferensi dan 22 route/two Pomodoro shortcuts.
- `qa-canvas-settings-results.json`: 80 = empat viewport 352–1024 × dua tema ×
  sepuluh keadaan/skenario; lebar konten iframe 320–992. Empat simulasi teks 200%,
  empat picker cases, 12 pasangan teks dan alur form pada sandbox percakapan.
- Checker skill: muted/surface 6.80:1 terang dan 8.19:1 gelap;
  button accent 9.44:1 dan 8.81:1. Border/surface 4.36:1 dan 5.07:1 diuji sebagai
  komponen nonteks dengan minimum 3:1; warna border tidak dipakai untuk body text.
  Danger/danger surface 6.68:1 dan 8.38:1.
- Desktop, ponsel dan gelap ditinjau secara visual. Regresi paket 40 layout/theme,
  20 data states, empat dialog ponsel dan shortcut Settings; Sync 192 cases,
  Weekly Review 128 cases. Screenshot pembanding diperbarui dari preview aktif.
- Preview offline tidak melakukan HTTP/HTTPS. Renderer canvas hanya memakai tiga
  URL CDN pinned milik helper (Floating UI core/dom dan Lucide); fragment tidak
  melakukan API atau memuat dependency remote.

Simulasi teks bukan browser/OS zoom atau sertifikasi WCAG lengkap. Native keyboard,
permission, system-settings shortcut, audio, SQLite, tzdb server, outbox dan
recompute materializer belum diimplementasikan. Pergantian halaman/skenario mereset
fixture; tema belum mempunyai kontrak penyimpanan. Jangan menyalin rumus sederhana,
angka, tanggal, device identity atau daftar contoh sebagai perilaku produksi.
