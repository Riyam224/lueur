/// Layout and timing constants specific to the splash screen.
/// Sizes/offsets are expressed as fractions of the screen width/height
/// so the decorative blobs and plant scene scale with any device size.
class SplashConstants {
  static const Duration navigationDelay = Duration(seconds: 3);

  // Blob diameters as a fraction of screen width
  static const double blobOneSizeFraction = 0.65; // top-left, bleeds off-screen
  static const double blobTwoSizeFraction = 0.30; // upper-right, smaller
  static const double blobThreeSizeFraction = 0.60; // lower-right, large

  // Blob opacities
  static const double blobOneOpacity = 0.55;
  static const double blobTwoOpacity = 0.55;
  static const double blobThreeOpacity = 0.18;

  // Fraction of a blob's own size used to offset it past the screen edge
  static const double blobEdgeOffsetFactor = 0.35;

  // Vertical rhythm of the content column, as a fraction of screen height
  static const double topSpacerFraction = 0.16;
  static const double titleToTaglineSpacingFraction = 0.012;
  static const double taglineToSceneSpacingFraction = 0.07;
  static const double sceneToCaptionSpacingFraction = 0.018;

  // Plant scene sizing
  static const double potHeightFraction = 0.11; // fraction of screen width

  // Typography hierarchy
  static const double titleFontSize = 58; // "Lueur" — DM Serif Display italic
  static const double taglineFontSize = 14; // "a little light for you"
  static const double captionFontSize = 11.5; // "grow a little every day"
  static const double taglineLetterSpacing = 2.5;

  // Staggered fade-in — background/logo fade first, plant+Luna scene
  // follows ~150ms later. No scale, bounce, or looping per the brand's
  // animation-restraint rule.
  static const Duration entranceDuration = Duration(milliseconds: 450);
  static const double logoFadeEnd = 300 / 450;
  static const double sceneFadeStart = 150 / 450;
}
