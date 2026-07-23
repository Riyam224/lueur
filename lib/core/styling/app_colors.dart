import 'package:flutter/material.dart';

class AppColors {
  // ── MindEase Breathing/Affirmation Palette ───────────────────────────────
  static const Color cardBorder = lightBorder;
  static const Color breathInColor = Color(0xFFE8621A);
  static const Color breathHoldColor = Color(0xFF2D6A4F);
  static const Color breathOutColor = Color(0xFF85B7EB);

  // ── Light Theme ──────────────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF8F6FB);    // Scaffold
  static const Color lightSurface = Color(0xFFFFFFFF);       // Cards
  static const Color primary = Color(0xFF8C7FD6);            // CTA buttons
  static const Color primaryContainer = Color(0xFF5BBFA0);   // AI bubble, mint
  static const Color lightOnBackground = Color(0xFF2E2A47);  // Headings
  static const Color lightSecondaryText = Color(0xFF6B6480); // Labels, hints
  static const Color lightBorder = Color(0xFFE4DFF5);        // Card borders
  static const Color accent = Color(0xFFF2A66E);             // "Great" mood

  // ── Dark Theme (Celestials night-sky palette) ─────────────────────────────
  static const Color darkBackground = Color(0xFF12142B);     // Scaffold — deep night navy
  static const Color darkSurface = Color(0xFF1C2044);        // Cards — indigo navy
  static const Color primaryDark = Color(0xFF8C93E8);        // Buttons, accents — periwinkle
  static const Color darkPrimaryContainer = Color(0xFF262B52); // AI bubble bg — indigo container
  static const Color darkOnBackground = Color(0xFFEDEAFF);   // Primary text — pale lavender
  static const Color darkSecondaryText = Color(0xFFA7A9D6);  // Labels, hints — muted periwinkle
  static const Color darkBorder = Color(0xFF2E3268);         // Card borders
  static const Color darkTertiaryText = Color(0xFF9497C7);   // Captions, tertiary labels

  // Dark-mode accent hues lifted from the Celestials artwork's creatures/sunset
  static const Color darkMintTeal = Color(0xFF6FCFB0);
  static const Color darkSunsetPeach = Color(0xFFF2A66E);
  static const Color darkSkyBlue = Color(0xFF7FB8E8);
  static const Color darkGoldenYellow = Color(0xFFF5C86F);
  static const Color darkCoralPink = Color(0xFFE8829C);

  // ── Aliases (keep existing usages compiling) ─────────────────────────────
  static const Color cardBackground = lightSurface;

  // Text
  static const Color primaryTextColor = lightOnBackground;
  static const Color secondaryTextColor = lightSecondaryText;
  static const Color whiteTextColor = Color(0xFFFFFFFF);
  static const Color greyTextColor = Color(0xFF9E9E9E);

  // Accent
  static const Color blushPink = accent;
  static const Color lavender = Color(0xFFB4B8F0);

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

  // ── Settings icon colors (profile settings section) ─────────────────────
  // Light mode
  static const Color settingsModeIconColorLight    = Color(0xFF7C6FCD);
  static const Color settingsModeIconBgLight       = Color(0xFFEEEBFF);
  static const Color settingsAboutIconColorLight   = Color(0xFFD45CA0);
  static const Color settingsAboutIconBgLight      = Color(0xFFFFEBF5);
  static const Color settingsPrivacyIconColorLight = Color(0xFF4CAF50);
  static const Color settingsPrivacyIconBgLight    = Color(0xFFE8F5E9);

  // Dark mode (Celestials palette)
  static const Color settingsModeIconColorDark    = Color(0xFFA896F0); // lavender
  static const Color settingsModeIconBgDark        = darkPrimaryContainer;
  static const Color settingsAboutIconColorDark   = darkCoralPink;
  static const Color settingsAboutIconBgDark       = Color(0xFF3A2438); // deep plum
  static const Color settingsPrivacyIconColorDark = darkMintTeal;
  static const Color settingsPrivacyIconBgDark     = Color(0xFF1B3B33); // deep teal

  // ── Gradient background colors ───────────────────────────────────────────
  static const Color bannerGradientDarkStart  = Color(0xFF232760); // dark weekly banner — night indigo
  static const Color bannerGradientLightEnd   = Color(0xFFEDE8FF); // light weekly banner
  static const Color primaryDarkDeep          = Color(0xFF3A3D82); // greeting card dark gradient end
  static const Color softLavender             = Color(0xFFF0ECFF); // after-feeling selector chip

  // ── Brand / functional colors ────────────────────────────────────────────
  static const Color warningAmber = Color(0xFFEF9F27); // password medium strength

  // ── Onboarding wave blob backgrounds ─────────────────────────────────────
  static const Color onboardingBlobLavender = Color(0xFFEDE8FF);
  static const Color onboardingBlobMint = Color(0xFFC8EDD8);
  static const Color onboardingBlobPeach = bannerGradientLightEnd; // 0xFFFFE4D0

  // ── Breathing screen gradient (soft, calm — not saturated) ───────────────
  static const Color breathingGradientLavender = Color(0xFFC8B4F8);
  static const Color breathingGradientCream = Color(0xFFFFF8F5);
  static const Color breathingGradientPeach = Color(0xFFFFD4B8);

  // ── Onboarding UI colors ──────────────────────────────────────────────────
  static const Color onboardingAccent      = Color(0xFF8C7FD6); // CTA, active dot, skip text
  static const Color onboardingDotInactive = Color(0xFFD8D3E8); // inactive indicator dot
  static const Color onboardingHeadline    = Color(0xFF2E2A47); // page headline text
  static const Color onboardingSubtitle    = Color(0xFF6B6480); // page subtitle text
  static const Color onboardingLunaDetail  = Color(0xFFC9C3F0); // Luna eyes + smile (screen 1)
  static const Color onboardingChatDetail  = Color(0xFFA8D5C2); // chat bubble dots + line (screen 2)

  // ── Journal grid palette ──────────────────────────────────────────────────
  static const Color journalCardLavender    = Color(0xFFC9BBF0);
  static const Color journalCardMint        = Color(0xFFA9E0CE);
  static const Color journalCardPeach       = Color(0xFFFFD9C2);
  static const Color journalCardCoral       = Color(0xFFF2C4A8);
  static const Color journalGridBackground  = Color(0xFFFFF9F5);
}
