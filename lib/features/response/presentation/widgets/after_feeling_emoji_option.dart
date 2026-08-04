import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/app_fonts.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/features/response/presentation/widgets/mood_asset_image.dart';

/// One tappable emoji option in the after-feeling selector row.
class AfterFeelingEmojiOption extends StatelessWidget {
  const AfterFeelingEmojiOption({
    super.key,
    required this.asset,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String asset;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        width: 64.w,
        height: 72.h,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.transparent,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MoodAssetImage(asset: asset, size: 36.w),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.mainFontName,
                fontSize: 10.sp,
                color: isSelected
                    ? AppColors.primary
                    : context.extra.secondaryTextColor!,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
