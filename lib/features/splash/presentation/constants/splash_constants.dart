/// Layout and timing constants specific to the splash screen.
class SplashConstants {
  // Minimum time the splash stays up — just enough for the fade-in
  // (500ms) to read as intentional, not an arbitrary multi-second hold.
  static const Duration navigationDelay = Duration(milliseconds: 1200);

  // Luna illustration width as a fraction of screen width.
  static const double lunaSizeFraction = 0.42;

  static const double titleFontSize = 34; // "Lueur" — bold, Luna-colored
  static const double taglineFontSize = 14; // "a little light for you"

  static const double lunaToTitleGap = 20;
  static const double titleToTaglineGap = 6;

  // Single fade-in only — no scale, bounce, or looping.
  static const Duration fadeInDuration = Duration(milliseconds: 500);
}
