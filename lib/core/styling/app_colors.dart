import 'package:flutter/material.dart';

class AppColors {
  // ── Lueur cozy palette (source of truth — reference these, never a raw
  // hex, anywhere else in the app) ─────────────────────────────────────────
  // Brand duo: Lavender Lilac (#B7AEDC) + Buttermilk Yellow (#FFE6A7) — the
  // dusty, storybook-cozy pair from the app's mood board. Every purple in
  // the app (light or dark mode) is the same hue/saturation as Lavender
  // Lilac, just lighter or darker, so nothing reads as a "different purple".
  static const Color lavenderLilac = Color(0xFFB7AEDC);
  static const Color buttermilkYellow = Color(0xFFFFE6A7);
  static const Color creamBackground = Color(0xFFF8F2E7);

  static const Color pastelLavenderWhite = creamBackground;
  static const Color pastelBlush = Color(0xFFFCEFD0); // warm buttermilk tint
  static const Color pastelCoral =
      buttermilkYellow; // "Great" mood, warm accent
  static const Color pastelOrchid =
      Color(0xFF6E59C5); // deeper lavender-lilac, decorative
  static const Color pastelPurple = lavenderLilac;
  static const Color pastelPeriwinkle =
      Color(0xFFD9D4ED); // lighter lavender-lilac tint — AI bubble

  // ── Sunrise palette — light theme only (gumdrop-pet reference: warm
  // peach → coral gradient, sunset-orange accents). Dark mode keeps the
  // lavender/plum palette above untouched; every constant here is only ever
  // read by the LIGHT theme tokens below. ───────────────────────────────────
  static const Color sunriseCream = Color(0xFFFFF4E9); // lightest bg
  static const Color sunrisePeachLight =
      Color(0xFFFFE9D6); // soft wash (icon bg, gradient end)
  static const Color sunrisePeach = Color(0xFFFFD9BB); // container / AI bubble
  static const Color sunriseCoral = Color(0xFFFF8A5B); // primary accent
  static const Color sunriseAmber =
      Color(0xFFFFC168); // "Great" mood / golden accent
  static const Color sunriseBorder = Color(0xFFFFE3CC);
  static const Color sunriseOnBackground = Color(0xFF3A2A1E); // headings
  static const Color sunriseSecondaryText = Color(0xFF8C6A52); // labels, hints
  static const Color sunriseButtonFill =
      Color(0xFFC24A0A); // contrast w/ white: 4.85:1
  static const Color sunriseGradientTop =
      Color(0xFFFFB37B); // celebration bg gradient top
  static const Color sunriseGreetingStart =
      Color(0xFFB23A0A); // contrast w/ white: 6.0:1
  static const Color sunriseGreetingEnd =
      Color(0xFFCC5013); // contrast w/ white: 4.45:1

  // ── Button-fill variants ─────────────────────────────────────────────────
  // pastelPurple/pastelCoral read beautifully as backgrounds, glows, and
  // decorative fills, but white text on top of them fails WCAG AA (need
  // 4.5:1). These are the same hue, darkened via the WCAG relative-luminance
  // formula until white text clears 4.5:1 — use ONLY where white/light text
  // sits directly on the fill (buttons, filled chat bubbles). Leave every
  // background/glow/decorative usage on the lighter pastel values above.
  static const Color primaryButtonFill =
      sunriseButtonFill; // contrast w/ white: 4.85:1
  static const Color accentButtonFill =
      Color(0xFF9A6F00); // contrast w/ white: 4.52:1

  // Greeting card gradient — same hue family, same contrast-safe styling,
  // for the diagonal gradient behind Luna's white greeting text. Used in
  // both light and dark mode: the card always carries white text, so it
  // always needs the darkened pair regardless of theme.
  static const Color greetingGradientStart =
      sunriseGreetingStart; // contrast w/ white: 6.0:1
  static const Color greetingGradientEnd =
      sunriseGreetingEnd; // contrast w/ white: 4.45:1

  // ── Lueur Breathing/Affirmation Palette ─────────────────────────────────
  static const Color cardBorder = lightBorder;
  static const Color breathInColor = Color(0xFFE8621A);
  static const Color breathHoldColor = Color(0xFF2D6A4F);
  static const Color breathOutColor = Color(0xFF85B7EB);

  // ── Light Theme (Sunrise — warm peach/coral, gumdrop-pet inspired) ───────
  static const Color lightBackground = sunriseCream; // Scaffold
  static const Color lightSurface = Color(0xFFFFFFFF); // Cards
  static const Color primary = sunriseCoral; // CTA buttons
  static const Color primaryContainer = sunrisePeach; // AI bubble
  static const Color lightOnBackground = sunriseOnBackground; // Headings
  static const Color lightSecondaryText = sunriseSecondaryText; // Labels, hints
  static const Color lightBorder = sunriseBorder; // Card borders
  static const Color accent = sunriseAmber; // "Great" mood

  // ── Dark Theme (same pastel family, deepened — no black/navy) ────────────
  // Structural surfaces below carry a whisper of darkMintTeal blended in —
  // a deliberate "touch of green" so dark mode reads like a cozy cabin at
  // night (plum + moss) rather than plain purple-on-black.
  static const Color darkBackground =
      Color(0xFF2B2138); // Scaffold — deep plum, not black
  static const Color darkSurface =
      Color(0xFF3E3952); // Cards — lighter plum, mint-touched
  static const Color primaryDark = pastelPurple; // Buttons, accents
  static const Color darkPrimaryContainer =
      Color(0xFF454F6C); // AI bubble bg — plum + mint touch
  static const Color darkOnBackground = pastelLavenderWhite; // Primary text
  static const Color darkSecondaryText =
      Color(0xFFC9B7D6); // Labels, hints — muted mauve
  static const Color darkBorder =
      Color(0xFF4E4A64); // Card borders — plum + mint touch
  static const Color darkTertiaryText =
      Color(0xFFB8A6C7); // Captions, tertiary labels

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
  static const Color lavender = Color(0xFFCFB9F8); // lighter Luna-purple tint

  // Mood Colors
  static const Color moodHappy = Color(0xFF4CAF50);
  static const Color moodCalm = Color(0xFF2196F3);
  static const Color moodSad = Color(0xFFFF9800);
  static const Color moodExcited = Color(0xFFFFC107);
  static const Color moodAnxious = Color(0xFFF44336);
  static const Color moodNeutral = Color(0xFF9E9E9E);

  // Utility
  static const Color shadowColor = Color(0x0D000000);
  static const Color overlayBlack = Color(0xFF000000);
  static const Color errorColor = Color(0xFFF44336);
  static const Color transparent = Colors.transparent;

  // ── Mood Selector (home screen emoji buttons) ────────────────────────────
  static const Color moodSelectorAwful =
      Color(0xFF2563EB); // Awful  — bold blue
  static const Color moodSelectorMeh = Color(0xFF525252); // Meh    — dark gray
  static const Color moodSelectorOkay =
      Color(0xFF16A34A); // Okay   — bold green
  static const Color moodSelectorGood =
      Color(0xFFD97706); // Good   — bold amber
  static const Color moodSelectorGreat =
      Color(0xFF6D28D9); // Great  — bold purple

  // ── Settings icon colors (profile settings section) ─────────────────────
  // Light mode
  static const Color settingsModeIconColorLight =
      Color(0xFF4E38A8); // lavender-lilac, deeper
  static const Color settingsModeIconBgLight = softLavender;
  static const Color settingsAboutIconColorLight = Color(0xFFD45CA0);
  static const Color settingsAboutIconBgLight = Color(0xFFFFEBF5);
  static const Color settingsPrivacyIconColorLight = Color(0xFF4CAF50);
  static const Color settingsPrivacyIconBgLight = Color(0xFFE8F5E9);

  // Dark mode (Celestials palette)
  static const Color settingsModeIconColorDark = lavenderLilac; // Luna purple
  static const Color settingsModeIconBgDark = darkPrimaryContainer;
  static const Color settingsAboutIconColorDark = darkCoralPink;
  static const Color settingsAboutIconBgDark = Color(0xFF3A2438); // deep plum
  static const Color settingsPrivacyIconColorDark = darkMintTeal;
  static const Color settingsPrivacyIconBgDark = Color(0xFF1B3B33); // deep teal

  // ── Gradient background colors ───────────────────────────────────────────
  static const Color bannerGradientDarkStart =
      Color(0xFF3D2E52); // dark weekly banner — deep plum
  static const Color softLavender = sunrisePeachLight; // near-white warm wash
  static const Color bannerGradientLightEnd =
      softLavender; // light weekly banner
  static const Color primaryDarkDeep =
      Color(0xFF4A3F72); // greeting card dark gradient end

  // ── Brand / functional colors ────────────────────────────────────────────
  static const Color warningAmber =
      Color(0xFFEF9F27); // password medium strength

  // ── Onboarding wave blob backgrounds ─────────────────────────────────────
  static const Color onboardingBlobLavender = softLavender;
  static const Color onboardingBlobMint = Color(0xFFC8EDD8);
  static const Color onboardingBlobPeach = bannerGradientLightEnd; // 0xFFF0EDFA

  // ── Breathing screen gradient (soft, calm — not saturated) ───────────────
  static const Color breathingGradientLavender = Color(0xFFBFB7E1);
  static const Color breathingGradientCream = Color(0xFFFFF8F5);
  static const Color breathingGradientPeach = Color(0xFFFFD4B8);

  // ── Onboarding UI colors ──────────────────────────────────────────────────
  static const Color onboardingAccent =
      Color(0xFF4E38A8); // CTA, active dot, skip text — lavender-lilac
  static const Color onboardingDotInactive =
      Color(0xFFD8D3E8); // inactive indicator dot
  static const Color onboardingLunaDetail =
      Color(0xFFCFC9E8); // Luna eyes + smile (screen 1)
  static const Color onboardingChatDetail =
      Color(0xFFA8D5C2); // chat bubble dots + line (screen 2)

  // ── Journal grid palette ──────────────────────────────────────────────────
  static const Color journalCardLavender = Color(0xFFC4BDE3);
  static const Color journalCardMint = Color(0xFFA9E0CE);
  static const Color journalCardPeach = Color(0xFFFFD9C2);
  static const Color journalCardCoral = Color(0xFFF2C4A8);
  static const Color journalCardYellow = Color(0xFFF5E1A4); // happy
  static const Color journalCardGreen = Color(0xFFBFE3B4); // hopeful
  static const Color journalCardPink = Color(0xFFF2C6D9); // grateful/loved
  static const Color journalCardBlue = Color(0xFFBCD6EE); // sad
  static const Color journalGridBackground = sunriseCream;

  // ── Streak celebration gradient (festive violet, both themes) ───────────
  static const Color celebrationGradientLightStart =
      Color(0xFFB6A9F2); // soft lavender-violet
  static const Color celebrationGradientLightEnd =
      Color(0xFF6E5CD9); // deep periwinkle-violet
  static const Color celebrationGradientDarkStart =
      Color(0xFF362A55); // deep plum-violet
  static const Color celebrationGradientDarkEnd =
      Color(0xFF1F1830); // near-black violet
  static const Color celebrationGlowLight =
      Color(0x66FFFFFF); // Luna halo, light mode
  static const Color celebrationGlowDark =
      Color(0x4DCFB9F8); // Luna halo, dark mode
  static const Color celebrationSparkle = buttermilkYellow; // twinkle accent
  static const Color celebrationProgressTrackLight = Color(0x33FFFFFF);
  static const Color celebrationProgressTrackDark = Color(0x33000000);
}
