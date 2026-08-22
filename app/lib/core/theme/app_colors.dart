import 'package:flutter/material.dart';

/// Token warna — sumbernya `Dailys Desktop (standalone).html` (export
/// statis dari Claude Design, root project). **Catatan metodologi penting**
/// (23 Agu 2026): ekstraksi awal pakai `getComputedStyle()` lewat DOM
/// ternyata TIDAK BISA DIPERCAYA untuk warna — bundler ini merender lewat
/// mekanisme kustom ("sc-host"/shadow tree) yang bikin `getComputedStyle`
/// balikin nilai yang beda dari yang benar-benar dirender (dibuktikan:
/// `getComputedStyle(body).backgroundColor` bilang terang `#F3F2F2`,
/// padahal screenshot asli halamannya jelas **gelap**). Setelah dicek pakai
/// screenshot sungguhan (bukan DOM introspection), file desain ini ternyata
/// me-render **mode gelap**, konsisten dengan screenshot yang sebelumnya
/// dikirim user langsung di chat.
///
/// Jadi token di bawah dibagi 2 tingkat kepercayaan:
/// - `*Dark`: dikonfirmasi visual dari screenshot asli (hue & lightness
///   relatif akurat, tapi hex exact tetap estimasi mata krn tidak ada
///   color-picker/pixel sampling yang tersedia di tool ini).
/// - `*Light`: angka mentah dari `getComputedStyle()` (mungkin representasi
///   varian terang dari `light-dark()` CSS yang tidak ke-resolve benar di
///   automation ini) — dipakai krn masih lebih baik dari tebakan buta, TAPI
///   belum pernah benar-benar terlihat dirender, jadi **kurang bisa
///   dipercaya dibanding sebelumnya diklaim**. Verifikasi ulang kalau ada
///   cara melihat mode terang file ini secara visual.
/// Jangan hardcode hex di widget manapun, selalu referensi dari sini.
class AppColors {
  AppColors._();

  // Primary & Surface (Dark) — warna paling dipercaya karena dicocokkan ke
  // screenshot asli (bg gelap hangat, bukan abu netral #121212 seperti
  // draft sebelumnya).
  static const Color primaryDark = Color(0xFFEC3013);
  static const Color surfaceDark = Color(0xFF1C1A19);
  static const Color surfaceVariantDark = Color(0xFF2A2827);
  static const Color primaryContainerDark = Color(0xFF4A1810);
  static const Color primaryContainerBorderDark = Color(0xFF6B2A1C);
  // accentOnContainerDark — warna aksen yang dipakai DI ATAS
  // `primaryContainerDark`. Nilainya diambil dari ramp aksen file desain
  // (`--color-accent-400: #ff9783`), bukan tebakan: file itu mendefinisikan
  // 1 ramp accent-100..900, dan pasangan gelap yang masuk akal untuk
  // "aksen di atas fill aksen" adalah cerminan posisi ramp-nya (light pakai
  // ujung gelap #EC3013/#AE1800 di atas fill terang, dark pakai ujung
  // terang di atas fill gelap #4A1810 ≈ accent-900 #4d170e).
  // `primary` (#EC3013) di atas #4A1810 cuma ~3:1 — terlalu tipis untuk
  // teks kecil; #FF9783 di atas #4A1810 ≈ 6:1.
  static const Color accentOnContainerDark = Color(0xFFFF9783);

  // Primary & Surface (Light) — dari getComputedStyle() di
  // `Dailys Desktop (standalone).html` (lihat catatan kepercayaan di atas).
  // `primaryLight` beda dari `#DD280F` yang dipakai sesi sebelumnya —
  // kemungkinan lebih akurat (diambil dari file, bukan screenshot/tebakan),
  // tapi belum pernah dilihat dirender langsung.
  static const Color primaryLight = Color(0xFFEC3013);
  // primaryContainerLight = bg banner konflik versi terang (#FFF2EF).
  // primaryContainerBorderLight = border banner (#FFC4B8).
  static const Color primaryContainerLight = Color(0xFFFFF2EF);
  static const Color primaryContainerBorderLight = Color(0xFFFFC4B8);
  static const Color surfaceLight = Color(0xFFF3F2F2);
  // surfaceVariant = bg stat card & kanban tile, dikonfirmasi #EAE9E9.
  static const Color surfaceVariantLight = Color(0xFFEAE9E9);
  // outline = border tombol outline/stat card, computed style-nya
  // "onSurface @ 40% alpha" — di sini di-flatten ke hex solid di atas bg
  // #F3F2F2 (≈ #9F9D9D) karena token di kode ini dipakai sebagai warna
  // solid, bukan alpha compositing.
  static const Color outlineLight = Color(0xFF9F9D9D);
  static const Color outlineDark = Color(0xFF3A3A3A);
  // onSurface = warna teks utama, dikonfirmasi #201E1D (bukan hitam murni
  // #111111 seperti sebelumnya).
  static const Color onSurfaceLight = Color(0xFF201E1D);
  static const Color onSurfaceDark = Color(0xFFEDEDED);
  // onSurfaceMuted = subtitle/label/timestamp, computed style-nya
  // "onSurface @ 50–55% alpha" (2 nilai alpha dipakai gantian di file
  // desain, dianggap 1 token — bedanya tak terlihat mata). Di-flatten ke
  // hex solid di atas bg #F3F2F2 ≈ #7F7D7D.
  static const Color onSurfaceMutedLight = Color(0xFF7F7D7D);
  static const Color onSurfaceMutedDark = Color(0xFF9A9A9A);

  // Alias tanpa suffix — dipakai widget yang tidak butuh varian light/dark
  // eksplisit (mis. warna semantic yang sama di kedua tema).
  static const Color primary = primaryLight;

  // 2.3 Semantic Status — File desain monokromatik (1 aksen merah +
  // grayscale). `danger` tetap menunjuk ke `primary` (dipakai utk tombol
  // hapus/teks overdue, konsisten dgn dugaan sebelumnya, belum ada bukti
  // sebaliknya). `warning` DIREVISI: ikon segitiga di banner konflik
  // ternyata pakai merah lebih gelap #AE1800, BUKAN sama dengan primary —
  // dikonfirmasi lewat getComputedStyle() pada svg path ikon warning.
  static const Color success = primaryLight;
  static const Color warning = Color(0xFFAE1800);
  static const Color danger = primaryLight;

  // ---- Helper theme-aware ----
  // Token di atas sebagian besar punya varian Light/Dark terpisah, tapi
  // tidak semuanya muat di slot `ColorScheme` bawaan Material (border
  // banner & warna aksen-di-atas-container tidak punya slot). 3 helper di
  // bawah dipakai widget supaya tidak ada lagi hex mode-terang yang
  // di-hardcode di feature widget — akar bug "banner/kartu bentrok tidak
  // terbaca di dark mode" (23 Agu 2026): fill-nya terang statis, tapi
  // teksnya ikut tema (jadi putih di atas putih).

  /// Border banner konflik / kartu ber-fill `primaryContainer`.
  static Color primaryContainerBorderOf(Brightness brightness) =>
      brightness == Brightness.dark
          ? primaryContainerBorderDark
          : primaryContainerBorderLight;

  /// Warna aksen (teks/ikon/badge) yang diletakkan DI ATAS
  /// `colorScheme.primaryContainer`. Di light tetap `primary` seperti
  /// sebelumnya — cuma dark yang berubah, supaya tampilan mode terang yang
  /// sudah dikonfirmasi user tidak ikut bergeser.
  static Color accentOnPrimaryContainerOf(Brightness brightness) =>
      brightness == Brightness.dark ? accentOnContainerDark : primary;

  /// Ikon peringatan (segitiga) di atas `primaryContainer`. Di light tetap
  /// `warning` (#AE1800, dikonfirmasi dari file desain); di dark warna itu
  /// nyaris tak terlihat di atas #4A1810, jadi dipakai ujung terang ramp.
  static Color warningOf(Brightness brightness) =>
      brightness == Brightness.dark ? accentOnContainerDark : warning;
  static const Color info = onSurfaceMutedLight;

  // 2.4 Prioritas Tugas (FR-6.2) — disederhanakan jadi 1 gaya (fill
  // primary_container + teks primary) utk ketiga level, dibedakan lewat
  // teks label saja. Belum ada file desain utk layar Tugas untuk
  // diverifikasi ulang — nilai ini masih estimasi dari sesi sebelumnya.
  static const Color priorityLow = primaryLight;
  static const Color priorityMedium = primaryLight;
  static const Color priorityHigh = primaryLight;

  // 2.4b Kategori Activity/Timebox (FR-1.2, FR-3.10) — DIREVISI 23 Agu
  // 2026: dikonfirmasi lewat getComputedStyle() bahwa SEMUA ikon kategori
  // di kanban tile (Tugas/Kuliah/Sosial/Olahraga/Personal/Istirahat) pakai
  // warna identik (`onSurfaceMuted`), TANPA pengecualian — bukan lagi aksen
  // warna berbeda per kategori seperti draft sebelumnya. Kategori dibedakan
  // murni lewat bentuk ikon + teks label. Map di bawah **tidak lagi dipakai
  // untuk warna ikon Activity/Timebox** (lihat `kategoriIcon` di
  // `app_kategori_icons.dart` utk ikonnya) — disimpan hanya sebagai
  // referensi/basis palet generik (Section 2.6).
  static const Map<String, Color> kategoriDefault = {
    'Kuliah': Color(0xFF3D5AFE),
    'Tugas': Color(0xFFFF7A45),
    'Personal': Color(0xFF8B6BD8),
    'Istirahat': Color(0xFF4FB0A5),
    'Sosial': Color(0xFFF2578F),
    'Olahraga': Color(0xFF5CB85C),
  };

  static Color kategoriColor(String kategori) => kategoriDefault[kategori] ?? primary;

  // 2.5 Kategori Keuangan Predefined (FR-4.3)
  static const Map<String, Color> keuanganKategoriDefault = {
    'Belanja': Color(0xFF8B6BD8),
    'Hiburan': Color(0xFFF2578F),
    'Makanan': Color(0xFFFF7A45),
    'Kendaraan': Color(0xFF3D8BFF),
    'Pulsa': Color(0xFF4FB0A5),
    'Rokok': Color(0xFF6B6E7C),
    'Tagihan': Color(0xFFE0A62E),
  };

  /// 2.6 — Palet warna generik untuk entity yang butuh warna bebas-pilih
  /// (bukan kategori activity) — mis. Mata Kuliah (FR-6.18), Habit
  /// (FR-5.14). Diambil dari kombinasi warna kategori + beberapa variasi,
  /// disimpan sebagai hex string ("#RRGGBB") di database sesuai schema.md.
  static const List<Color> palette = [
    Color(0xFF3D5AFE),
    Color(0xFFFF7A45),
    Color(0xFF8B6BD8),
    Color(0xFF4FB0A5),
    Color(0xFFF2578F),
    Color(0xFF5CB85C),
    Color(0xFFE0A62E),
    Color(0xFF3D8BFF),
    Color(0xFF6B6E7C),
  ];

  static String colorToHex(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  static Color hexToColor(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    final value = int.tryParse(cleaned, radix: 16);
    return value == null ? primary : Color(0xFF000000 | value);
  }
}
