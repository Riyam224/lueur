import 'package:flutter/material.dart';
import 'package:lueur/core/styling/app_colors.dart';

/// Full-bleed gradient behind the streak celebration content, theme-aware.
class StreakCelebrationBackground extends StatelessWidget {
  const StreakCelebrationBackground({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    AppColors.celebrationGradientDarkStart,
                    AppColors.celebrationGradientDarkEnd,
                  ]
                : [
                    AppColors.celebrationGradientLightStart,
                    AppColors.celebrationGradientLightEnd,
                  ],
          ),
        ),
      ),
    );
  }
}
