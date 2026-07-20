class AppAssets {
  static const emojisPath = 'assets/emojis/';

  // ── Mood type illustrations (assets/illustrations/) ────────────────────
  // All ship as PNG with a transparent background (the original SVGs/PNGs
  // baked their "transparent" background in as an opaque checkerboard).
  static const illustrationsPath = 'assets/illustrations/';
  static const String illustrationHappy = '${illustrationsPath}happy.png';
  static const String illustrationSad = '${illustrationsPath}sad.png';
  static const String illustrationAngry = '${illustrationsPath}angry.png';
  static const String illustrationAnxious = '${illustrationsPath}anxious.png';
  static const String illustrationCalm = '${illustrationsPath}calm.png';
  static const String illustrationExcited = '${illustrationsPath}excited.png';
  static const String illustrationGrateful = '${illustrationsPath}grateful.png';
  static const String illustrationHopeful = '${illustrationsPath}hopeful.png';
  static const String illustrationLonely = '${illustrationsPath}lonely.png';
  static const String illustrationNeutral = '${illustrationsPath}neutral.png';
  static const String illustrationScared = '${illustrationsPath}scared.png';
  static const String illustrationBurnout = '${illustrationsPath}burnout.png';
  static const String illustrationContentPeaceful =
      '${illustrationsPath}content_peaceful.png';

  // Additional Emotion Emojis (expanded emotion tracking)
  static const String emojiStressed = '${emojisPath}stressed.png';
  static const String emojiFrustrated = '${emojisPath}frustrated.png';
  static const String emojiHopeful = '${emojisPath}hopeful.png';
  static const String emojiLonely = '${emojisPath}lonely.png';
  static const String emojiGrateful = '${emojisPath}grateful.png';
  static const String emojiOverwhelmed = '${emojisPath}overwhelmed.png';
  static const String emojiNeutral = '${emojisPath}neutral.png';
  static const String emojiWorried = '${emojisPath}worried.png';
  static const String emojiRelaxed = '${emojisPath}relaxed.png';
  static const String emojiContent = '${emojisPath}content.png';
  static const String emojiSurprised = '${emojisPath}surprised.png';
  static const String emojiProud = '${emojisPath}proud.png';
  static const String emojiEmbarrassed = '${emojisPath}embarrassed.png';

  // Greeting Emojis
  static const String greetingMorning = '${emojisPath}flower.png';
  static const String greetingAfternoon = '${emojisPath}sun.png';
  static const String greetingEvening = '${emojisPath}moon.png';

  // Action Icons
  static const String actionChat = '${emojisPath}chat.png';
  static const String actionHistory = '${emojisPath}book.png';

  // Luna character illustration — genuinely transparent PNG (luna_source.png
  // bakes an opaque checkerboard into its background instead). Use this
  // everywhere Luna's mascot needs to appear.
  static const String lunaCharacter = 'assets/images/luna_splash.png';

  // Brand icons
  static const String googleLogo = 'assets/icons/google_logo.svg';

  // Lottie animations
  static const String lottiePlant        = 'assets/lottie/plant.json';
  static const String lottiePlantSprout  = 'assets/lottie/plant_sprout.json';
  static const String lottieBlooming     = 'assets/lottie/blooming.json';
}
