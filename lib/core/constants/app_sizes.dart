import 'package:flutter_screenutil/flutter_screenutil.dart';

/// App-wide size constants for responsive design
/// Using ScreenUtil for consistent sizing across different screen sizes
class AppSizes {
  // Border Radius
  static double borderRadiusXs = 8.r;
  static double borderRadiusSm = 12.r;
  static double borderRadiusMd = 16.r;
  static double borderRadiusLg = 20.r;
  static double borderRadiusXl = 24.r;
  static double borderRadiusCircle = 999.r;

  // Icon Sizes
  static double iconXs = 16.sp;
  static double iconSm = 20.sp;
  static double iconMd = 24.sp;
  static double iconLg = 32.sp;
  static double iconXl = 48.sp;

  // Avatar Sizes
  static double avatarSm = 40.sp;
  static double avatarMd = 48.sp;
  static double avatarLg = 60.sp;

  // Card Heights
  static double greetingCardHeight = 150.h;
  static double moodEntryCardMinHeight = 60.h;

  // Widget Dimensions
  static double emojiButtonSize = 50.sp;
  static double moodCardSidebarWidth = 4.w;
  static double moodCardSidebarHeight = 60.h;

  // Mood Label Popup (floats above a selected mood emoji)
  static double moodLabelPopupGap = 8.h;
  static double moodLabelPopupHeight = 26.h;

  // Button Heights
  static double buttonHeightSm = 40.h;
  static double buttonHeightMd = 50.h;
  static double buttonHeightLg = 60.h;

  // TextField Heights
  static double textFieldHeightSm = 40.h;
  static double textFieldHeightMd = 50.h;

  // Accessibility — minimum interactive touch target (44dp, platform HIG floor)
  static double minTouchTarget = 44.h;

  // Free-draw color palette swatches
  static double paletteSwatchSize = 34.w;
  static double paletteSwatchSizeSelected = 42.w;
  static double paletteSwatchBorderWidth = 3.w;
  static double paletteSwatchGlowBlur = 10.r;
  static double paletteSwatchGlowSpread = 1.r;
}
