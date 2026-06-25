import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // ── Display (عناوين كبيرة — DM Serif Display italic) ─────────────────
  static TextStyle displayLarge(BuildContext context) =>
      GoogleFonts.dmSerifDisplay(
        fontSize: _scale(context, 48),
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w400,
        color: _onBg(context),
        height: 1.1,
      );

  static TextStyle displayMedium(BuildContext context) =>
      GoogleFonts.dmSerifDisplay(
        fontSize: _scale(context, 36),
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w400,
        color: _onBg(context),
        height: 1.2,
      );

  // ── Headline (عناوين أقسام — DM Sans medium) ─────────────────────────
  static TextStyle headlineLarge(BuildContext context) => GoogleFonts.dmSans(
        fontSize: _scale(context, 24),
        fontWeight: FontWeight.w500,
        color: _onBg(context),
        height: 1.3,
      );

  static TextStyle headlineMedium(BuildContext context) => GoogleFonts.dmSans(
        fontSize: _scale(context, 20),
        fontWeight: FontWeight.w500,
        color: _onBg(context),
        height: 1.3,
      );

  static TextStyle headlineSmall(BuildContext context) => GoogleFonts.dmSans(
        fontSize: _scale(context, 18),
        fontWeight: FontWeight.w500,
        color: _onBg(context),
      );

  // ── Body (نصوص عادية — DM Sans regular) ──────────────────────────────
  static TextStyle bodyLarge(BuildContext context) => GoogleFonts.dmSans(
        fontSize: _scale(context, 16),
        fontWeight: FontWeight.w400,
        color: _onBg(context),
        height: 1.6,
      );

  static TextStyle bodyMedium(BuildContext context) => GoogleFonts.dmSans(
        fontSize: _scale(context, 14),
        fontWeight: FontWeight.w400,
        color: _onBg(context),
        height: 1.5,
      );

  static TextStyle bodySmall(BuildContext context) => GoogleFonts.dmSans(
        fontSize: _scale(context, 12),
        fontWeight: FontWeight.w300,
        color: _secondaryText(context),
        height: 1.5,
      );

  // ── Label (chips, badges, captions) ───────────────────────────────────
  static TextStyle labelLarge(BuildContext context) => GoogleFonts.dmSans(
        fontSize: _scale(context, 14),
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: _onBg(context),
      );

  static TextStyle labelMedium(BuildContext context) => GoogleFonts.dmSans(
        fontSize: _scale(context, 12),
        fontWeight: FontWeight.w400,
        letterSpacing: 1.2,
        color: _secondaryText(context),
      );

  static TextStyle labelSmall(BuildContext context) => GoogleFonts.dmSans(
        fontSize: _scale(context, 10),
        fontWeight: FontWeight.w300,
        letterSpacing: 1.8,
        color: _secondaryText(context),
      );

  // ── Button ────────────────────────────────────────────────────────────
  static TextStyle button(BuildContext context) => GoogleFonts.dmSans(
        fontSize: _scale(context, 16),
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      );

  // ── Helpers ───────────────────────────────────────────────────────────
  static double _scale(BuildContext context, double size) {
    final width = MediaQuery.sizeOf(context).width;
    // base width = 390 (iPhone 14)
    return size * (width / 390).clamp(0.85, 1.2);
  }

  static Color _onBg(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground;
  }

  static Color _secondaryText(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
  }
}
