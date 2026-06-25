import 'package:flutter/material.dart';

/// Custom theme extension for additional app colors
/// Provides theme-aware colors that change between light and dark modes
class AppExtraColors extends ThemeExtension<AppExtraColors> {
  // Primary colors
  final Color? primaryColor;
  final Color? primaryLightColor;
  final Color? primaryDarkColor;

  // Background colors
  final Color? cardBackgroundColor;
  final Color? surfaceColor;

  // Text colors
  final Color? primaryTextColor;
  final Color? secondaryTextColor;
  final Color? tertiaryTextColor;
  final Color? onPrimaryTextColor;

  // Mood colors
  final Color? moodHappy;
  final Color? moodSad;
  final Color? moodCalm;
  final Color? moodExcited;
  final Color? moodAnxious;
  final Color? moodNeutral;

  // Border colors
  final Color? borderColor;
  final Color? dividerColor;

  // Shadow color
  final Color? shadowColor;

  // Settings icon colors (profile settings section)
  final Color? settingsModeIconColor;
  final Color? settingsModeIconBg;
  final Color? settingsAboutIconColor;
  final Color? settingsAboutIconBg;
  final Color? settingsPrivacyIconColor;
  final Color? settingsPrivacyIconBg;

  AppExtraColors({
    required this.primaryColor,
    required this.primaryLightColor,
    required this.primaryDarkColor,
    required this.cardBackgroundColor,
    required this.surfaceColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.tertiaryTextColor,
    required this.onPrimaryTextColor,
    required this.moodHappy,
    required this.moodSad,
    required this.moodCalm,
    required this.moodExcited,
    required this.moodAnxious,
    required this.moodNeutral,
    required this.borderColor,
    required this.dividerColor,
    required this.shadowColor,
    required this.settingsModeIconColor,
    required this.settingsModeIconBg,
    required this.settingsAboutIconColor,
    required this.settingsAboutIconBg,
    required this.settingsPrivacyIconColor,
    required this.settingsPrivacyIconBg,
  });

  @override
  AppExtraColors copyWith({
    Color? primaryColor,
    Color? primaryLightColor,
    Color? primaryDarkColor,
    Color? cardBackgroundColor,
    Color? surfaceColor,
    Color? primaryTextColor,
    Color? secondaryTextColor,
    Color? tertiaryTextColor,
    Color? onPrimaryTextColor,
    Color? moodHappy,
    Color? moodSad,
    Color? moodCalm,
    Color? moodExcited,
    Color? moodAnxious,
    Color? moodNeutral,
    Color? borderColor,
    Color? dividerColor,
    Color? shadowColor,
    Color? settingsModeIconColor,
    Color? settingsModeIconBg,
    Color? settingsAboutIconColor,
    Color? settingsAboutIconBg,
    Color? settingsPrivacyIconColor,
    Color? settingsPrivacyIconBg,
  }) {
    return AppExtraColors(
      primaryColor: primaryColor ?? this.primaryColor,
      primaryLightColor: primaryLightColor ?? this.primaryLightColor,
      primaryDarkColor: primaryDarkColor ?? this.primaryDarkColor,
      cardBackgroundColor: cardBackgroundColor ?? this.cardBackgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      primaryTextColor: primaryTextColor ?? this.primaryTextColor,
      secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
      tertiaryTextColor: tertiaryTextColor ?? this.tertiaryTextColor,
      onPrimaryTextColor: onPrimaryTextColor ?? this.onPrimaryTextColor,
      moodHappy: moodHappy ?? this.moodHappy,
      moodSad: moodSad ?? this.moodSad,
      moodCalm: moodCalm ?? this.moodCalm,
      moodExcited: moodExcited ?? this.moodExcited,
      moodAnxious: moodAnxious ?? this.moodAnxious,
      moodNeutral: moodNeutral ?? this.moodNeutral,
      borderColor: borderColor ?? this.borderColor,
      dividerColor: dividerColor ?? this.dividerColor,
      shadowColor: shadowColor ?? this.shadowColor,
      settingsModeIconColor: settingsModeIconColor ?? this.settingsModeIconColor,
      settingsModeIconBg: settingsModeIconBg ?? this.settingsModeIconBg,
      settingsAboutIconColor: settingsAboutIconColor ?? this.settingsAboutIconColor,
      settingsAboutIconBg: settingsAboutIconBg ?? this.settingsAboutIconBg,
      settingsPrivacyIconColor: settingsPrivacyIconColor ?? this.settingsPrivacyIconColor,
      settingsPrivacyIconBg: settingsPrivacyIconBg ?? this.settingsPrivacyIconBg,
    );
  }

  @override
  AppExtraColors lerp(ThemeExtension<AppExtraColors>? other, double t) {
    if (other is! AppExtraColors) return this;

    return AppExtraColors(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t),
      primaryLightColor: Color.lerp(primaryLightColor, other.primaryLightColor, t),
      primaryDarkColor: Color.lerp(primaryDarkColor, other.primaryDarkColor, t),
      cardBackgroundColor: Color.lerp(cardBackgroundColor, other.cardBackgroundColor, t),
      surfaceColor: Color.lerp(surfaceColor, other.surfaceColor, t),
      primaryTextColor: Color.lerp(primaryTextColor, other.primaryTextColor, t),
      secondaryTextColor: Color.lerp(secondaryTextColor, other.secondaryTextColor, t),
      tertiaryTextColor: Color.lerp(tertiaryTextColor, other.tertiaryTextColor, t),
      onPrimaryTextColor: Color.lerp(onPrimaryTextColor, other.onPrimaryTextColor, t),
      moodHappy: Color.lerp(moodHappy, other.moodHappy, t),
      moodSad: Color.lerp(moodSad, other.moodSad, t),
      moodCalm: Color.lerp(moodCalm, other.moodCalm, t),
      moodExcited: Color.lerp(moodExcited, other.moodExcited, t),
      moodAnxious: Color.lerp(moodAnxious, other.moodAnxious, t),
      moodNeutral: Color.lerp(moodNeutral, other.moodNeutral, t),
      borderColor: Color.lerp(borderColor, other.borderColor, t),
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t),
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t),
      settingsModeIconColor: Color.lerp(settingsModeIconColor, other.settingsModeIconColor, t),
      settingsModeIconBg: Color.lerp(settingsModeIconBg, other.settingsModeIconBg, t),
      settingsAboutIconColor: Color.lerp(settingsAboutIconColor, other.settingsAboutIconColor, t),
      settingsAboutIconBg: Color.lerp(settingsAboutIconBg, other.settingsAboutIconBg, t),
      settingsPrivacyIconColor: Color.lerp(settingsPrivacyIconColor, other.settingsPrivacyIconColor, t),
      settingsPrivacyIconBg: Color.lerp(settingsPrivacyIconBg, other.settingsPrivacyIconBg, t),
    );
  }
}
