import 'package:flutter/material.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/styling/app_colors.dart';

/// Dismissible, fading, gradient card shell shared by the weekly letter
/// banner's loading and loaded states.
class WeeklyLetterShell extends StatelessWidget {
  const WeeklyLetterShell({
    super.key,
    required this.fadeAnimation,
    required this.onDismissed,
    required this.child,
  });

  final Animation<double> fadeAnimation;
  final VoidCallback onDismissed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: fadeAnimation,
      child: Dismissible(
        key: const ValueKey('weekly_letter_banner'),
        onDismissed: (_) => onDismissed(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [AppColors.bannerGradientDarkStart, AppColors.darkSurface]
                  : [AppColors.lightSurface, AppColors.bannerGradientLightEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
