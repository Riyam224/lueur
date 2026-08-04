import 'package:flutter/material.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_colors.dart';

/// Frosted-glass card used to keep body copy legible on top of the
/// celebration gradient in both light and dark mode.
class FrostedCard extends StatelessWidget {
  const FrostedCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontalPaddingLg,
        vertical: AppSpacing.verticalPaddingMd,
      ),
      decoration: BoxDecoration(
        color: AppColors.whiteTextColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
      ),
      child: child,
    );
  }
}
