import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // ── Display (عناوين كبيرة — DM Serif Display italic) ─────────────────
  static TextStyle displayLarge(BuildContext context) => TextStyle(
        fontFamily: 'DMSerifDisplay',
        fontSize: _scale(context, 48),
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w400,
        color: _onBg(context),
        height: 1.1,
      );

  static TextStyle displayMedium(BuildContext context) => TextStyle(
        fontFamily: 'DMSerifDisplay',
        fontSize: _scale(context, 36),
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w400,
        color: _onBg(context),
        height: 1.2,
      );

  // ── Headline (عناوين أقسام — Nunito SemiBold) ─────────────────────────
  static TextStyle headlineLarge(BuildContext context) => TextStyle(
        fontFamily: 'Nunito',
        fontSize: _scale(context, 24),
        fontWeight: FontWeight.w600,
        color: _onBg(context),
        height: 1.3,
      );

  static TextStyle headlineMedium(BuildContext context) => TextStyle(
        fontFamily: 'Nunito',
        fontSize: _scale(context, 20),
        fontWeight: FontWeight.w600,
        color: _onBg(context),
        height: 1.3,
      );

  static TextStyle headlineSmall(BuildContext context) => TextStyle(
        fontFamily: 'Nunito',
        fontSize: _scale(context, 18),
        fontWeight: FontWeight.w600,
        color: _onBg(context),
      );

  // ── Body (نصوص عادية — Nunito Regular) ──────────────────────────────
  static TextStyle bodyLarge(BuildContext context) => TextStyle(
        fontFamily: 'Nunito',
        fontSize: _scale(context, 16),
        fontWeight: FontWeight.w400,
        color: _onBg(context),
        height: 1.6,
      );

  static TextStyle bodyMedium(BuildContext context) => TextStyle(
        fontFamily: 'Nunito',
        fontSize: _scale(context, 14),
        fontWeight: FontWeight.w400,
        color: _onBg(context),
        height: 1.5,
      );

  static TextStyle bodySmall(BuildContext context) => TextStyle(
        fontFamily: 'Nunito',
        fontSize: _scale(context, 12),
        fontWeight: FontWeight.w300,
        color: _secondaryText(context),
        height: 1.5,
      );

  // ── Label (chips, badges, captions) ───────────────────────────────────
  static TextStyle labelLarge(BuildContext context) => TextStyle(
        fontFamily: 'Nunito',
        fontSize: _scale(context, 14),
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: _onBg(context),
      );

  static TextStyle labelMedium(BuildContext context) => TextStyle(
        fontFamily: 'Nunito',
        fontSize: _scale(context, 12),
        fontWeight: FontWeight.w500,
        letterSpacing: 1.2,
        color: _secondaryText(context),
      );

  static TextStyle labelSmall(BuildContext context) => TextStyle(
        fontFamily: 'Nunito',
        fontSize: _scale(context, 10),
        fontWeight: FontWeight.w400,
        letterSpacing: 1.8,
        color: _secondaryText(context),
      );

  // ── Button ────────────────────────────────────────────────────────────
  static TextStyle button(BuildContext context) => TextStyle(
        fontFamily: 'Nunito',
        fontSize: _scale(context, 16),
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      );

  static TextStyle buttonEmphasis(BuildContext context) => TextStyle(
        fontFamily: 'Nunito',
        fontSize: _scale(context, 16),
        fontWeight: FontWeight.w700,
      );

  static TextStyle buttonOutlined(BuildContext context) => TextStyle(
        fontFamily: 'Nunito',
        fontSize: _scale(context, 14),
        fontWeight: FontWeight.w600,
      );

  // ── Form fields ───────────────────────────────────────────────────────
  static TextStyle fieldLabel(BuildContext context) => TextStyle(
        fontFamily: 'Nunito',
        fontSize: _scale(context, 12),
        fontWeight: FontWeight.w600,
        color: _onBg(context),
      );

  static TextStyle fieldInput(BuildContext context) => TextStyle(
        fontFamily: 'Nunito',
        fontWeight: FontWeight.w400,
        color: _onBg(context),
      );

  static TextStyle fieldHint(BuildContext context) => TextStyle(
        fontFamily: 'Nunito',
        fontWeight: FontWeight.w300,
        color: _secondaryText(context),
      );

  // ── Caption / link text ───────────────────────────────────────────────
  static TextStyle captionSmall(BuildContext context) => TextStyle(
        fontFamily: 'Nunito',
        fontSize: _scale(context, 12),
        fontWeight: FontWeight.w400,
        color: _secondaryText(context),
      );

  static TextStyle caption(BuildContext context) => TextStyle(
        fontFamily: 'Nunito',
        fontSize: _scale(context, 13),
        fontWeight: FontWeight.w400,
        color: _secondaryText(context),
      );

  static TextStyle captionEmphasis(BuildContext context) => TextStyle(
        fontFamily: 'Nunito',
        fontSize: _scale(context, 13),
        fontWeight: FontWeight.w700,
        color: _onBg(context),
      );

  static TextStyle strengthLabel(BuildContext context) => TextStyle(
        fontFamily: 'Nunito',
        fontSize: _scale(context, 11),
        fontWeight: FontWeight.w400,
        color: _secondaryText(context),
      );

  // ── Italic headline (auth screens) ────────────────────────────────────
  static TextStyle headlineItalic(BuildContext context) => TextStyle(
        fontFamily: 'DMSerifDisplay',
        fontSize: _scale(context, 26),
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w400,
        color: _onBg(context),
        height: 1.2,
      );

  // ── Helpers ───────────────────────────────────────────────────────────
  static double _scale(BuildContext context, double size) {
    final width = MediaQuery.sizeOf(context).width;
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
