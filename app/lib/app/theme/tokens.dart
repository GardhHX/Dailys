import 'package:flutter/widgets.dart';

/// Design tokens transcribed from `design/tokens.json`. Do not invent new
/// colors/spacing here — add to the JSON source and mirror the value (AGENTS.md:
/// "Gunakan design/tokens.json untuk token bersama").
class AppColorTokens {
  const AppColorTokens({
    required this.background,
    required this.surface,
    required this.text,
    required this.textMuted,
    required this.divider,
    required this.controlBorder,
    required this.accent,
    required this.onAccent,
    required this.selectedSurface,
    required this.danger,
    required this.dangerSurface,
    required this.success,
    required this.successSurface,
    required this.ochre,
  });

  final Color background;
  final Color surface;
  final Color text;
  final Color textMuted;
  final Color divider;
  final Color controlBorder;
  final Color accent;
  final Color onAccent;
  final Color selectedSurface;
  final Color danger;
  final Color dangerSurface;
  final Color success;
  final Color successSurface;
  final Color ochre;

  static const light = AppColorTokens(
    background: Color(0xfff5f4f0),
    surface: Color(0xffffffff),
    text: Color(0xff20212b),
    textMuted: Color(0xff595a68),
    divider: Color(0xffdcdce2),
    controlBorder: Color(0xff777887),
    accent: Color(0xff3538a0),
    onAccent: Color(0xffffffff),
    selectedSurface: Color(0xffeeeefa),
    danger: Color(0xff9e2c30),
    dangerSurface: Color(0xfffff1ef),
    success: Color(0xff266044),
    successSurface: Color(0xffedf5ef),
    ochre: Color(0xff77501a),
  );

  static const dark = AppColorTokens(
    background: Color(0xff17181e),
    surface: Color(0xff22232c),
    text: Color(0xfff4f4fa),
    textMuted: Color(0xffb9bbc9),
    divider: Color(0xff454651),
    controlBorder: Color(0xff9092a2),
    accent: Color(0xffb7b9ff),
    onAccent: Color(0xff191a4c),
    selectedSurface: Color(0xff323347),
    danger: Color(0xffffb3b6),
    dangerSurface: Color(0xff3a2529),
    success: Color(0xffa2dfbb),
    successSurface: Color(0xff22372c),
    ochre: Color(0xffe4c690),
  );
}

/// Spacing scale (px) from `design/tokens.json` `spacingPx`.
class AppSpacing {
  const AppSpacing._();
  static const double xxs = 4;
  static const double xs = 6;
  static const double sm = 8;
  static const double smd = 10;
  static const double md = 12;
  static const double lg = 16;
  static const double lgx = 18;
  static const double xl = 20;
  static const double xlx = 22;
  static const double xxl = 24;
  static const double xxlx = 26;
  static const double xxxl = 28;
  static const double huge = 32;
}

/// Corner radii (px) from `design/tokens.json` `radiusPx`.
class AppRadius {
  const AppRadius._();
  static const double denseCell = 3;
  static const double status = 4;
  static const double control = 6;
  static const double card = 9;
  static const double dialog = 12;
}

/// `interaction.minimumPrimaryTargetPx` — minimum touch target for primary
/// controls across every screen spec.
const double kMinimumPrimaryTargetPx = 44;

const String kFontFamilyWindows = 'Segoe UI';
