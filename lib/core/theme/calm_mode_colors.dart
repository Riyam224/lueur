import 'package:flutter/material.dart';
import 'package:lueur/core/styling/app_colors.dart';

/// Shared "calm mode" dark palette — the deep navy gradient and soft glow
/// colors used by the guided breathing screen and other low-mood flows.
/// Pulls from [AppColors] so new calm-mode screens reference this instead
/// of duplicating hex values.
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
