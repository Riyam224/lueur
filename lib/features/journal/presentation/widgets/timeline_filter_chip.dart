import 'package:flutter/material.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';

/// Small pill-shaped selectable chip used by the timeline's mood/month
/// filter rows.
class TimelineFilterChip extends StatelessWidget {
  const TimelineFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final extra = context.extra;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMd,
          vertical: AppSpacing.spaceXs,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.16)
              : extra.cardBackgroundColor,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusCircle),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : extra.borderColor ?? AppColors.cardBorder,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: ThemeTextStyles.labelSmall(context).copyWith(
              color: selected ? AppColors.primary : extra.secondaryTextColor,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
