import 'package:flutter/material.dart';

class AppColors {
  // ── MindEase Breathing/Affirmation Palette ───────────────────────────────
  static const Color cardBorder = Color(0xFFFFD4B0);
  static const Color breathInColor = Color(0xFFE8621A);
  static const Color breathHoldColor = Color(0xFF2D6A4F);
  static const Color breathOutColor = Color(0xFF85B7EB);

  // ── Light Theme ──────────────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFFFF8F5);    // Scaffold
  static const Color lightSurface = Color(0xFFFFF0E8);       // Cards
  static const Color primary = Color(0xFFE8621A);            // CTA buttons
  static const Color primaryContainer = Color(0xFF5BBFA0);   // AI bubble, mint
  static const Color lightOnBackground = Color(0xFF2D2016);  // Headings
  static const Color lightSecondaryText = Color(0xFF7A5038); // Labels, hints
  static const Color lightBorder = Color(0xFFFFD4B8);        // Card borders
  static const Color accent = Color(0xFFFF7096);             // "Great" mood

  // ── Dark Theme ───────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF16132A);     // Scaffold
  static const Color darkSurface = Color(0xFF1E1A35);        // Cards
  static const Color primaryDark = Color(0xFF7C5CDB);        // Buttons, accents
  static const Color darkPrimaryContainer = Color(0xFF221D3E); // AI bubble bg
  static const Color darkOnBackground = Color(0xFFEDE9FE);   // Primary text
  static const Color darkSecondaryText = Color(0xFF6B6490);  // Labels, hints
  static const Color darkBorder = Color(0xFF2D2850);         // Card borders

  // ── Aliases (keep existing usages compiling) ─────────────────────────────
  static const Color cardBackground = lightSurface;

  // Text
  static const Color primaryTextColor = lightOnBackground;
  static const Color secondaryTextColor = lightSecondaryText;
  static const Color whiteTextColor = Color(0xFFFFFFFF);
  static const Color greyTextColor = Color(0xFF9E9E9E);

  // Accent
  static const Color blushPink = accent;
  static const Color lavender = Color(0xFFC8B4F8);

  // Mood Colors
  static const Color moodHappy = Color(0xFF4CAF50);
  static const Color moodCalm = Color(0xFF2196F3);
  static const Color moodSad = Color(0xFFFF9800);
  static const Color moodExcited = Color(0xFFFFC107);
  static const Color moodAnxious = Color(0xFFF44336);
  static const Color moodNeutral = Color(0xFF9E9E9E);

  // Utility
  static const Color shadowColor = Color(0x0D000000);
  static const Color errorColor = Color(0xFFF44336);

  // ── Mood Selector (home screen emoji buttons) ────────────────────────────
  static const Color moodSelectorAwful = Color(0xFF2563EB);   // Awful  — bold blue
  static const Color moodSelectorMeh   = Color(0xFF525252);   // Meh    — dark gray
  static const Color moodSelectorOkay  = Color(0xFF16A34A);   // Okay   — bold green
  static const Color moodSelectorGood  = Color(0xFFD97706);   // Good   — bold amber
  static const Color moodSelectorGreat = Color(0xFF6D28D9);   // Great  — bold purple

  // ── Mood SVG tint colors (colorFilter for mood SVG icons) ────────────────
  static const Color moodAwfulSvg  = breathOutColor;          // soft blue
  static const Color moodMehSvg    = Color(0xFF6C5CE7);       // purple
  static const Color moodOkaySvg   = Color(0xFF18A887);       // mint teal
  static const Color moodGoodSvg   = Color(0xFF9180E8);       // lavender
  static const Color moodGreatSvg  = Color(0xFFE84393);       // pink

  // ── Settings icon colors (profile settings section) ─────────────────────
  // Light mode
  static const Color settingsModeIconColorLight    = Color(0xFF7C6FCD);
  static const Color settingsModeIconBgLight       = Color(0xFFEEEBFF);
  static const Color settingsAboutIconColorLight   = Color(0xFFD45CA0);
  static const Color settingsAboutIconBgLight      = Color(0xFFFFEBF5);
  static const Color settingsPrivacyIconColorLight = Color(0xFF4CAF50);
  static const Color settingsPrivacyIconBgLight    = Color(0xFFE8F5E9);

  // Dark mode
  static const Color settingsModeIconColorDark    = Color(0xFFA89CFF);
  static const Color settingsModeIconBgDark        = Color(0xFF2D2750);
  static const Color settingsAboutIconColorDark   = Color(0xFFE87FC0);
  static const Color settingsAboutIconBgDark       = Color(0xFF3D2438);
  static const Color settingsPrivacyIconColorDark = Color(0xFF66BB6A);
  static const Color settingsPrivacyIconBgDark     = Color(0xFF1E3B23);

  // ── Gradient background colors ───────────────────────────────────────────
  static const Color bannerGradientDarkStart  = Color(0xFF2A2250); // dark weekly banner
  static const Color bannerGradientLightEnd   = Color(0xFFFFE4D0); // light weekly banner
  static const Color primaryDarkDeep          = Color(0xFF3D2B8E); // greeting card dark gradient end
  static const Color softLavender             = Color(0xFFF0ECFF); // after-feeling selector chip

  // ── Brand / functional colors ────────────────────────────────────────────
  static const Color warningAmber = Color(0xFFEF9F27); // password medium strength

  // ── Onboarding wave blob backgrounds ─────────────────────────────────────
  static const Color onboardingBlobLavender = Color(0xFFEDE8FF);
  static const Color onboardingBlobMint = Color(0xFFC8EDD8);
  static const Color onboardingBlobPeach = bannerGradientLightEnd; // 0xFFFFE4D0

  // ── Onboarding UI colors ──────────────────────────────────────────────────
  static const Color onboardingAccent      = Color(0xFFE8825A); // CTA, active dot, skip text
  static const Color onboardingDotInactive = Color(0xFFD4C5BC); // inactive indicator dot
  static const Color onboardingHeadline    = Color(0xFF3B2A1A); // page headline text
  static const Color onboardingSubtitle    = Color(0xFF6B5B4E); // page subtitle text
  static const Color onboardingLunaDetail  = Color(0xFFC9C3F0); // Luna eyes + smile (screen 1)
  static const Color onboardingChatDetail  = Color(0xFFA8D5C2); // chat bubble dots + line (screen 2)
}
