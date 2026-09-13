# Global Settings: pemeriksaan draft dan kontrak

13 September 2026. Draft `screens/settings.md` dibandingkan dengan PRD FR-7.1–14,
schema 3.1, API-SPEC 9.8 dan OpenAPI UserSettings/UserSettingsMutation.
Hasil: pengelompokan dan interaksi utama mengikuti kontrak. Visual ditambahkan,
tanpa mengubah PRD, schema, API-SPEC atau OpenAPI.

| Acuan | Keputusan desain |
|---|---|
| Sembilan field UserSettings; PUT partial, response penuh; tidak dapat dihapus | Simpan per field, status dekat kontrol, retry mempertahankan input, tidak ada hapus preferensi |
| language id/en | Resource kedua bahasa pada seluruh delapan bagian dan dialog |
| IANA timezone | Picker searchable berbasis daftar canonical runtime ditambah UTC; fallback berlabel, validasi server/tzdb tetap normatif |
| Zona tidak menggeser tanggal/Instant/occurrence lama | Status recompute; fixture lama dipertahankan. Nilai zona yang gagal simpan tetap terlihat dan bisa dicoba kembali |
| focus 1–180; short 1–60; long 1–120; interval 2–12 | Empat field bilangan bulat dengan alasan invalid inline; snapshot sesi running tetap |
| notifications_enabled bukan izin OS; sound/muted | Preferensi user terpisah dari status izin perangkat; muted mempertahankan visual, nonaktif membatalkan trigger contoh |
| Weekly Review default Minggu 09:00:00 | Kontrol local time dengan detik; hari tetap, review completed/cutoff tidak berubah |
| DeviceSettings lokal dan dipertahankan snapshot | Volume/izin/registrasi ditampilkan terpisah dan tidak masuk patch user |
| Pusat Sync global | Ringkasan pending/konflik/last success/recovery dan route ke flow yang sudah tersedia |

Tiga hal pada draft membutuhkan batas yang jelas:

1. **Tema:** belum ada kontrak penyimpanan pada empat dokumen normatif. Kontrol
   sistem/terang/gelap hanya contoh visual. Tidak ditambahkan ke UserSettings atau
   diasumsikan sebagai field DeviceSettings.
2. **Shortcut izin OS:** canvas menunjukkan panduan Windows/Android dan hasil
   pemeriksaan contoh. Binding system settings dan permission native harus dibuat
   saat implementasi; tidak ada permission request ketika membuka layar ini.
3. **Tentang:** versi acuan produk 1.0 berasal dari dokumen. Build aplikasi belum
   tersedia; gunakan metadata build nyata pada implementasi.

Tidak ada credential UI. Registrasi, queue, angka notifikasi dan recompute merupakan
simulasi, bukan bukti transaksi SQLite, materializer, alarm OS atau protokol sync.
Runtime timezone browser bukan allowlist seluruh alias yang diterima server.
Navigasi halaman preview mereset fixture; native harus mempertahankan sesi/domain.
