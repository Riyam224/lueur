import 'package:flutter/material.dart';
import 'package:lueur/core/styling/app_colors.dart';

/// Shared "calm mode" dark palette — deep navy gradient + soft glow colors
/// used by breathing and other low-mood flows. Pulls from [AppColors] instead of duplicating hex values.
class CalmModeColors {
  const CalmModeColors._();

  static const List<Color> navyGradient = [
    AppColors.darkBackground,
    AppColors.darkSurface,
    AppColors.primaryDarkDeep,
  ];

  static const Color lavenderGlow = AppColors.breathingGradientLavender;
  static const Color peachGlow = AppColors.breathingGradientPeach;
  static const Color ink = AppColors.darkOnBackground;
  static const Color mutedInk = AppColors.darkSecondaryText;
}
