import 'package:flutter/material.dart';

class AppColors {
  // ── Lueur pastel palette (source of truth — reference these, never a raw
  // hex, anywhere else in the app) ─────────────────────────────────────────
  static const Color pastelLavenderWhite = Color(0xFFF4E7F8);
  static const Color pastelBlush         = Color(0xFFF2DDDC);
  static const Color pastelCoral         = Color(0xFFF6BCBA);
  static const Color pastelOrchid        = Color(0xFFE3AADD);
  static const Color pastelPurple        = Color(0xFFC8A8E9);
  static const Color pastelPeriwinkle    = Color(0xFFC3C7F4);

  // ── Button-fill variants ─────────────────────────────────────────────────
  // pastelPurple/pastelCoral read beautifully as backgrounds, glows, and
  // decorative fills, but white text on top of them fails WCAG AA (measured
  // 2.05:1 and 1.64:1 — need 4.5:1). These are the same hue, darkened via
  // the WCAG relative-luminance formula until white text clears 4.5:1 —
  // use ONLY where white/light text sits directly on the fill (buttons,
  // filled chat bubbles). Leave every background/glow/decorative usage on
  // the lighter pastel values above.
  static const Color primaryButtonFill = Color(0xFF9658D5); // contrast w/ white: 4.51:1
  static const Color accentButtonFill  = Color(0xFFE32C26); // contrast w/ white: 4.51:1

  // ── Lueur Breathing/Affirmation Palette ─────────────────────────────────
  static const Color cardBorder = lightBorder;
  static const Color breathInColor = Color(0xFFE8621A);
  static const Color breathHoldColor = Color(0xFF2D6A4F);
  static const Color breathOutColor = Color(0xFF85B7EB);

  // ── Light Theme ──────────────────────────────────────────────────────────
  static const Color lightBackground = pastelLavenderWhite;  // Scaffold
  static const Color lightSurface = Color(0xFFFFFFFF);       // Cards
  static const Color primary = pastelPurple;                 // CTA buttons
  static const Color primaryContainer = pastelPeriwinkle;    // AI bubble
  static const Color lightOnBackground = Color(0xFF2E2A47);  // Headings
  static const Color lightSecondaryText = Color(0xFF6B6480); // Labels, hints
  static const Color lightBorder = Color(0xFFEEDFF2);        // Card borders
  static const Color accent = pastelCoral;                   // "Great" mood

  // ── Dark Theme (same pastel family, deepened — no black/navy) ────────────
  static const Color darkBackground = Color(0xFF2B2138);     // Scaffold — deep plum, not black
  static const Color darkSurface = Color(0xFF3A2C4A);        // Cards — lighter plum
  static const Color primaryDark = pastelPurple;             // Buttons, accents
  static const Color darkPrimaryContainer = Color(0xFF3F3D63); // AI bubble bg — deep periwinkle
  static const Color darkOnBackground = pastelLavenderWhite; // Primary text
  static const Color darkSecondaryText = Color(0xFFC9B7D6);  // Labels, hints — muted mauve
  static const Color darkBorder = Color(0xFF4A3B5C);         // Card borders
  static const Color darkTertiaryText = Color(0xFFB8A6C7);   // Captions, tertiary labels

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
  static const Color bannerGradientDarkStart  = Color(0xFF3D2E52); // dark weekly banner — deep plum
  static const Color bannerGradientLightEnd   = Color(0xFFEDE8FF); // light weekly banner
  static const Color primaryDarkDeep          = Color(0xFF4A3F72); // greeting card dark gradient end
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
