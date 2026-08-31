import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/styling/app_assets.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/features/breathing/presentation/widgets/breathing_ambient_blob.dart';

/// Concentric "ring" frame around Luna — a fixed disc, a cream padding ring,
/// and a pulsing inner circle scaled by [scale] in sync with the current phase.
class BreathingRingVisual extends StatelessWidget {
  const BreathingRingVisual({
    super.key,
    required this.scale,
    required this.ringColor,
  });

  final Animation<double> scale;
  final Color ringColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300.w,
      height: 300.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 10.h,
            left: 0,
            child: BreathingAmbientBlob(
              size: 120.w,
              color:
                  AppColors.breathingGradientLavender.withValues(alpha: 0.4),
            ),
          ),
          Positioned(
            bottom: 10.h,
            right: 0,
            child: BreathingAmbientBlob(
              size: 140.w,
              color: AppColors.breathingGradientPeach.withValues(alpha: 0.4),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 260.w,
            height: 260.w,
            decoration: BoxDecoration(shape: BoxShape.circle, color: ringColor),
          ),
          Container(
            width: 220.w,
            height: 220.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.breathingGradientCream,
            ),
          ),
          AnimatedBuilder(
            animation: scale,
            builder: (context, child) => Transform.scale(
              scale: scale.value,
              child: child,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 188.w,
              height: 188.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ringColor.withValues(alpha: 0.9),
                    ringColor.withValues(alpha: 0.55),
                  ],
                ),
              ),
              padding: EdgeInsets.all(14.w),
              child: Image.asset(AppAssets.lunaCharacter, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }
}
