/// Layout and timing constants specific to the splash screen.
class SplashConstants {
  static const Duration navigationDelay = Duration(seconds: 3);

  // Luna's eye diameter as a fraction of screen width.
  static const double eyeSizeFraction = 0.11;

  // Single fade-in only — no scale, bounce, or looping.
  static const Duration fadeInDuration = Duration(milliseconds: 500);
}
