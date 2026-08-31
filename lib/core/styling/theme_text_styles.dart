import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/styling/app_fonts.dart';
import 'package:lueur/core/styling/theme_extensions.dart';

class ThemeTextStyles {
  /// Emoji font fallback so any Text using these styles can render emoji
  /// even though Urbanist (the custom font) has no emoji glyphs.
  static const List<String> _emojiFallback = [
    'Apple Color Emoji',
    'Noto Color Emoji',
    'Segoe UI Emoji',
  ];

  static TextStyle headlineLarge(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 30.sp,
      fontWeight: FontWeight.bold,
      color: context.extra.primaryTextColor,
    );
  }

  static TextStyle headlineMedium(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 24.sp,
      fontWeight: FontWeight.bold,
      color: context.extra.primaryTextColor,
    );
  }

  static TextStyle headlineSmall(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
      color: context.extra.primaryTextColor,
    );
  }

  static TextStyle titleLarge(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 18.sp,
      fontWeight: FontWeight.bold,
      color: context.extra.primaryTextColor,
    );
  }

  static TextStyle titleMedium(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: context.extra.primaryTextColor,
    );
  }

  static TextStyle titleSmall(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      color: context.extra.primaryTextColor,
    );
  }

  static TextStyle bodyLarge(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
      color: context.extra.primaryTextColor,
    );
  }

  static TextStyle bodyMedium(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: context.extra.secondaryTextColor,
    );
  }

  static TextStyle bodySmall(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 13.sp,
      fontWeight: FontWeight.w400,
      color: context.extra.tertiaryTextColor,
    );
  }

  static TextStyle labelLarge(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: context.extra.primaryTextColor,
    );
  }

  static TextStyle labelMedium(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
      color: context.extra.primaryTextColor,
    );
  }

  static TextStyle labelSmall(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      color: context.extra.tertiaryTextColor,
    );
  }

  static TextStyle captionLarge(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      color: context.extra.tertiaryTextColor,
    );
  }

  static TextStyle captionSmall(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 11.sp,
      fontWeight: FontWeight.w400,
      color: context.extra.tertiaryTextColor,
    );
  }

  /// Softer, more personal display style — DM Serif Display italic. Reserved
  /// for emotional/editorial moments only (home greeting, streak celebration, mood-choice prompt); use Nunito elsewhere.
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

  static TextStyle whiteHeadline(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: context.extra.onPrimaryTextColor,
    );
  }

  static TextStyle whiteBody(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: context.extra.onPrimaryTextColor,
    );
  }

  static TextStyle whiteCaption(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      color: context.extra.onPrimaryTextColor,
    );
  }

  static TextStyle whiteButton(BuildContext context) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: context.extra.onPrimaryTextColor,
    );
  }

  static TextStyle navLabel(
    BuildContext context, {
    required bool isActive,
    required Color color,
  }) {
    return TextStyle(
      fontFamily: AppFonts.mainFontName,
      fontFamilyFallback: _emojiFallback,
      fontSize: 11.sp,
      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
      color: color,
    );
  }
}
