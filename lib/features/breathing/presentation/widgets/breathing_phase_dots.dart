import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/styling/app_colors.dart';

/// Two-dot indicator showing which breathing phase (in/out) is active.
class BreathingPhaseDots extends StatelessWidget {
  const BreathingPhaseDots({
    super.key,
    required this.isBreatheIn,
    required this.inkColor,
  });

  final bool isBreatheIn;
  final Color inkColor;

  Widget _dot(bool active) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        width: active ? 20.w : 8.w,
        height: 8.w,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : inkColor.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusXs),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [_dot(isBreatheIn), _dot(!isBreatheIn)],
    );
  }
}
