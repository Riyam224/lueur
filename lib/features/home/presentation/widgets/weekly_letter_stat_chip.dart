import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';

/// Small pill showing one weekly-letter stat (entry count, streak, or
/// dominant mood emoji).
class WeeklyLetterStatChip extends StatelessWidget {
  const WeeklyLetterStatChip({
    super.key,
    required this.label,
    this.icon,
    this.isEmoji = false,
  });

  final String label;
  final IconData? icon;
  final bool isEmoji;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkBackground.withValues(alpha: 0.5)
            : AppColors.lightSurface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusCircle),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12.sp, color: AppColors.primary),
            SizedBox(width: AppSpacing.spaceXs),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: isEmoji
                  ? TextStyle(
                      fontSize: 13.sp,
                      fontFamilyFallback: const [
                        'Apple Color Emoji',
                        'Noto Color Emoji',
                      ],
                    )
                  : ThemeTextStyles.labelSmall(context).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
