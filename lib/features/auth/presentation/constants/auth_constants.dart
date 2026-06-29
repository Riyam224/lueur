import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Layout constants for the login/register screens that have no exact
/// match in the shared [AppSizes] / [AppSpacing] scales.
class AuthConstants {
  // ── Avatar ────────────────────────────────────────────────────────────
  static double avatarSize = 88.sp;
  static double avatarPadding = 14.r;

  // ── Vertical rhythm (logical pixels, screen-scaled) ──────────────────
  static double topSpacing = 52.h;
  static double avatarToTitleSpacing = 100.h;
  static double titleToSubtitleSpacing = 6.h;
  static double googleToFooterSpacing = 20.h;

  // ── Fields ────────────────────────────────────────────────────────────
  static double fieldBorderRadius = 14.r;
  static double fieldBorderWidth = 1.5;
  static double fieldBorderWidthFocused = 2;

  // ── Buttons ───────────────────────────────────────────────────────────
  static double ctaButtonHeight = 56.h;
  static double googleButtonHeight = 52.h;
  static double dividerThickness = 1;

  // ── Password strength meter ───────────────────────────────────────────
  static double strengthBarHeight = 3.h;
  static double strengthBarRadius = 2.r;
  static double strengthBarToLabelSpacing = 4.h;

  // ── Password strength thresholds ──────────────────────────────────────
  static const int passwordShortLength = 6;
  static const int passwordMediumLength = 10;
  static const double passwordStrengthWeak = 0.33;
  static const double passwordStrengthMedium = 0.66;
  static const double passwordStrengthStrong = 1.0;
}
