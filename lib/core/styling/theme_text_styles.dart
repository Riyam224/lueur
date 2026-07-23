import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/styling/app_fonts.dart';
import 'package:lueur/core/styling/theme_extensions.dart';

/// Theme-aware text styles that adapt to light and dark modes
/// Use these styles to ensure text is readable in both themes
class ThemeTextStyles {
  /// Emoji font fallback so any Text using these styles can render emoji
  /// even though Urbanist (the custom font) has no emoji glyphs.
  static const List<String> _emojiFallback = [
    'Apple Color Emoji',
    'Noto Color Emoji',
    'Segoe UI Emoji',
  ];

  /// Get headline large style (30sp, bold)
  static TextStyle headlineLarge(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 30.sp,
      fontWeight: FontWeight.bold,
      color: context.extra.primaryTextColor,
    );
  }

  /// Get headline medium style (24sp, bold)
  static TextStyle headlineMedium(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 24.sp,
      fontWeight: FontWeight.bold,
      color: context.extra.primaryTextColor,
    );
  }

  /// Get headline small style (20sp, w600)
  static TextStyle headlineSmall(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
      color: context.extra.primaryTextColor,
    );
  }

  /// Get title large style (18sp, bold)
  static TextStyle titleLarge(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 18.sp,
      fontWeight: FontWeight.bold,
      color: context.extra.primaryTextColor,
    );
  }

  /// Get title medium style (16sp, w600)
  static TextStyle titleMedium(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: context.extra.primaryTextColor,
    );
  }

  /// Get title small style (14sp, w600)
  static TextStyle titleSmall(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      color: context.extra.primaryTextColor,
    );
  }

  /// Get body large style (16sp, w400)
  static TextStyle bodyLarge(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
      color: context.extra.primaryTextColor,
    );
  }

  /// Get body medium style (14sp, w400)
  static TextStyle bodyMedium(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: context.extra.secondaryTextColor,
    );
  }

  /// Get body small style (13sp, w400)
  static TextStyle bodySmall(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 13.sp,
      fontWeight: FontWeight.w400,
      color: context.extra.tertiaryTextColor,
    );
  }

  /// Get label large style (16sp, w500)
  static TextStyle labelLarge(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: context.extra.primaryTextColor,
    );
  }

  /// Get label medium style (14sp, w500)
  static TextStyle labelMedium(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
      color: context.extra.primaryTextColor,
    );
  }

  /// Get label small style (12sp, w500)
  static TextStyle labelSmall(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      color: context.extra.tertiaryTextColor,
    );
  }

  /// Get caption large style (12sp, w400)
  static TextStyle captionLarge(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      color: context.extra.tertiaryTextColor,
    );
  }

  /// Get caption small style (11sp, w400)
  static TextStyle captionSmall(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 11.sp,
      fontWeight: FontWeight.w400,
      color: context.extra.tertiaryTextColor,
    );
  }

  /// Softer, more personal display style — DM Serif Display italic.
  /// Reserved for emotional/editorial moments only (Luna's home greeting,
  /// the streak celebration heading, the mood-choice prompt) — everywhere
  /// else keep using headlineMedium/headlineSmall's Nunito.
  static TextStyle editorialHeadline(
    BuildContext context, {
    double fontSize = 24,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: AppFonts.displayFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: fontSize.sp,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w400,
      height: 1.3,
      color: color ?? context.extra.primaryTextColor,
    );
  }

  // White text styles for use on colored backgrounds

  /// Get white headline style (16sp, w500) - for colored backgrounds
  static TextStyle whiteHeadline(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: context.extra.onPrimaryTextColor,
    );
  }

  /// Get white body style (14sp, w400) - for colored backgrounds
  static TextStyle whiteBody(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: context.extra.onPrimaryTextColor,
    );
  }

  /// Get white caption style (12sp, w400) - for colored backgrounds
  static TextStyle whiteCaption(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      color: context.extra.onPrimaryTextColor,
    );
  }

  /// Get white button style (16sp, w500) - for buttons
  static TextStyle whiteButton(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: context.extra.onPrimaryTextColor,
    );
  }
}
