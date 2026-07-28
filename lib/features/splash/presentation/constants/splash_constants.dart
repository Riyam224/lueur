/// Layout and timing constants specific to the splash screen.
class SplashConstants {
  static const Duration navigationDelay = Duration(seconds: 3);

  // Luna illustration width as a fraction of screen width.
  static const double lunaSizeFraction = 0.42;

  static const double titleFontSize = 34; // "Lueur" — bold, Luna-colored
  static const double taglineFontSize = 14; // "a little light for you"

  static const double lunaToTitleGap = 20;
  static const double titleToTaglineGap = 6;

  // Single fade-in only — no scale, bounce, or looping.
  static const Duration fadeInDuration = Duration(milliseconds: 500);
}
