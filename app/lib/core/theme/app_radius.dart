/// Token radius — diverifikasi 23 Agu 2026 lewat `getComputedStyle()` pada
/// `Dailys Desktop (standalone).html`. `md` DIREVISI dari 12 → 14: ternyata
/// stat card & kanban tile pakai radius yang SAMA dengan tombol (14px),
/// bukan 12px terpisah seperti draft sebelumnya — cuma 1 skala radius utama
/// dipakai di hampir semua tempat.
class AppRadius {
  AppRadius._();

  static const double sm = 8; // Input field, logo box sidebar — dikonfirmasi dari file desain
  static const double md = 14; // Card, kanban tile, stat box, banner — dikonfirmasi dari file desain
  static const double button = 14; // Tombol primary & outline — dikonfirmasi dari file desain
  static const double lg = 20; // Modal bottom sheet (top corners) — belum ada file desain utk modal, estimasi
  // Nav item aktif di sidebar — dikonfirmasi 10px, BUKAN pill/capsule penuh
  // seperti draft sebelumnya (item selebar 206px tapi radius cuma 10px).
  static const double navPill = 10;
  static const double full = 999; // Progress bar, avatar, elemen benar-benar bulat
}
