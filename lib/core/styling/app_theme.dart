import 'package:ai_therapist_app/core/styling/app_colors.dart';
import 'package:ai_therapist_app/core/styling/app_extra_colors.dart';
import 'package:ai_therapist_app/core/styling/app_fonts.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.lightBackground,
    fontFamily: AppFonts.mainFontName,

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryContainer,
      secondary: AppColors.primaryContainer,   // mint — AI bubble
      tertiary: AppColors.accent,              // pink — "Great" mood
      onSecondary: AppColors.whiteTextColor,
      onSurface: AppColors.lightOnBackground,
      outline: AppColors.lightBorder,
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.lightOnBackground),
      displayMedium: TextStyle(color: AppColors.lightOnBackground),
      displaySmall: TextStyle(color: AppColors.lightOnBackground),
      headlineLarge: TextStyle(color: AppColors.lightOnBackground),
      headlineMedium: TextStyle(color: AppColors.lightOnBackground),
      headlineSmall: TextStyle(color: AppColors.lightOnBackground),
      titleLarge: TextStyle(color: AppColors.lightOnBackground),
      titleMedium: TextStyle(color: AppColors.lightOnBackground),
      titleSmall: TextStyle(color: AppColors.lightOnBackground),
      bodyLarge: TextStyle(color: AppColors.lightOnBackground),
      bodyMedium: TextStyle(color: AppColors.lightOnBackground),
      bodySmall: TextStyle(color: AppColors.lightSecondaryText),
      labelLarge: TextStyle(color: AppColors.lightOnBackground),
      labelMedium: TextStyle(color: AppColors.lightSecondaryText),
      labelSmall: TextStyle(color: AppColors.lightSecondaryText),
    ),

    iconTheme: const IconThemeData(color: AppColors.lightOnBackground),

    cardColor: AppColors.lightSurface,

    extensions: [
      AppExtraColors(
        primaryColor: AppColors.primary,
        primaryLightColor: AppColors.primaryContainer,
        primaryDarkColor: AppColors.primaryDark,
        cardBackgroundColor: AppColors.lightSurface,
        surfaceColor: AppColors.lightSurface,
        primaryTextColor: AppColors.lightOnBackground,
        secondaryTextColor: AppColors.lightSecondaryText,
        tertiaryTextColor: AppColors.lightSecondaryText,
        onPrimaryTextColor: AppColors.whiteTextColor,
        moodHappy: AppColors.moodHappy,
        moodSad: AppColors.moodSad,
        moodCalm: AppColors.moodCalm,
        moodExcited: AppColors.moodExcited,
        moodAnxious: AppColors.moodAnxious,
        moodNeutral: AppColors.moodNeutral,
        borderColor: AppColors.lightBorder,
        dividerColor: AppColors.lightBorder,
        shadowColor: AppColors.shadowColor,
        settingsModeIconColor: AppColors.settingsModeIconColorLight,
        settingsModeIconBg: AppColors.settingsModeIconBgLight,
        settingsAboutIconColor: AppColors.settingsAboutIconColorLight,
        settingsAboutIconBg: AppColors.settingsAboutIconBgLight,
        settingsPrivacyIconColor: AppColors.settingsPrivacyIconColorLight,
        settingsPrivacyIconBg: AppColors.settingsPrivacyIconBgLight,
        blobColorOne: AppColors.lavender,
        blobColorTwo: AppColors.primaryContainer,
        blobColorThree: AppColors.softLavender,
      ),
    ],
  );

  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.darkBackground,
    fontFamily: AppFonts.mainFontName,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDark,
      primaryContainer: AppColors.darkPrimaryContainer,
      secondary: AppColors.lavender,
      surface: AppColors.darkSurface,
      onPrimary: AppColors.whiteTextColor,
      onSecondary: AppColors.whiteTextColor,
      onSurface: AppColors.darkOnBackground,
      outline: AppColors.darkBorder,
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.darkOnBackground),
      displayMedium: TextStyle(color: AppColors.darkOnBackground),
      displaySmall: TextStyle(color: AppColors.darkOnBackground),
      headlineLarge: TextStyle(color: AppColors.darkOnBackground),
      headlineMedium: TextStyle(color: AppColors.darkOnBackground),
      headlineSmall: TextStyle(color: AppColors.darkOnBackground),
      titleLarge: TextStyle(color: AppColors.darkOnBackground),
      titleMedium: TextStyle(color: AppColors.darkOnBackground),
      titleSmall: TextStyle(color: AppColors.darkOnBackground),
      bodyLarge: TextStyle(color: AppColors.darkOnBackground),
      bodyMedium: TextStyle(color: AppColors.darkOnBackground),
      bodySmall: TextStyle(color: AppColors.darkSecondaryText),
      labelLarge: TextStyle(color: AppColors.darkOnBackground),
      labelMedium: TextStyle(color: AppColors.darkSecondaryText),
      labelSmall: TextStyle(color: AppColors.darkSecondaryText),
    ),

    iconTheme: const IconThemeData(color: AppColors.darkOnBackground),

    cardColor: AppColors.darkSurface,

    extensions: [
      AppExtraColors(
        primaryColor: AppColors.primaryDark,
        primaryLightColor: AppColors.darkPrimaryContainer,
        primaryDarkColor: AppColors.primaryDark,
        cardBackgroundColor: AppColors.darkSurface,
        surfaceColor: AppColors.darkBackground,
        primaryTextColor: AppColors.darkOnBackground,
        secondaryTextColor: AppColors.darkSecondaryText,
        tertiaryTextColor: AppColors.darkTertiaryText,
        onPrimaryTextColor: AppColors.whiteTextColor,
        moodHappy: AppColors.darkMintTeal,
        moodSad: AppColors.darkSunsetPeach,
        moodCalm: AppColors.darkSkyBlue,
        moodExcited: AppColors.darkGoldenYellow,
        moodAnxious: AppColors.darkCoralPink,
        moodNeutral: AppColors.darkSecondaryText,
        borderColor: AppColors.darkBorder,
        dividerColor: AppColors.darkBorder,
        shadowColor: const Color(0x1AFFFFFF),
        settingsModeIconColor: AppColors.settingsModeIconColorDark,
        settingsModeIconBg: AppColors.settingsModeIconBgDark,
        settingsAboutIconColor: AppColors.settingsAboutIconColorDark,
        settingsAboutIconBg: AppColors.settingsAboutIconBgDark,
        settingsPrivacyIconColor: AppColors.settingsPrivacyIconColorDark,
        settingsPrivacyIconBg: AppColors.settingsPrivacyIconBgDark,
        blobColorOne: AppColors.primaryDark,
        blobColorTwo: AppColors.darkMintTeal,
        blobColorThree: AppColors.darkCoralPink,
      ),
    ],
  );
}
