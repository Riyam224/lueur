/// Layout and timing constants specific to the splash screen.
/// Sizes/offsets are expressed as fractions of the screen width/height
/// so the decorative blobs scale with any device size.
class SplashConstants {
  static const Duration navigationDelay = Duration(seconds: 3);

  // Blob diameters as a fraction of screen width
  static const double blobTopLeftSizeFraction = 0.55;
  static const double blobTopRightSizeFraction = 0.22;
  static const double blobBottomLeftSizeFraction = 0.30;
  static const double blobBottomRightSizeFraction = 0.50;
  static const double blobAccentTopSizeFraction = 0.18;
  static const double blobAccentBottomSizeFraction = 0.14;

  // Blob opacities
  static const double blobTopLeftOpacity = 0.40;
  static const double blobTopRightOpacity = 0.22;
  static const double blobBottomLeftOpacity = 0.28;
  static const double blobBottomRightOpacity = 0.55;
  static const double blobAccentTopOpacity = 0.18;
  static const double blobAccentBottomOpacity = 0.20;

  // Accent blob positions, as a fraction of screen width/height
  static const double blobAccentTopDxFraction = 0.60;
  static const double blobAccentTopDyFraction = 0.08;
  static const double blobAccentBottomDxFraction = 0.10;
  static const double blobAccentBottomDyFraction = 0.55;

  // Fraction of a blob's own size used to offset it past the screen edge
  static const double blobEdgeOffsetFactor = 0.35;

  // Vertical rhythm of the content column, as a fraction of screen height
  static const double topSpacerFraction = 0.12;
  static const double titleToTaglineSpacingFraction = 0.008;
  static const double taglineToLottieSpacingFraction = 0.06;

  // Lottie animation width as a fraction of screen width
  static const double lottieWidthFraction = 0.55;
}
