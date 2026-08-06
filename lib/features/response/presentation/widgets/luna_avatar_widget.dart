import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:lueur/core/styling/app_colors.dart';

/// Luna avatar with lavender border and growing plant animation
class LunaAvatarWidget extends StatelessWidget {
  const LunaAvatarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      height: 100.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.lavender.withValues(alpha: 0.4),
          width: 3.w,
        ),
      ),
      child: ClipOval(
        child: Lottie.asset(
          'assets/lottie/plant.json',
          fit: BoxFit.cover,
          repeat: true,
          animate: true,
          errorBuilder: (_, __, ___) => const Icon(Icons.spa_outlined, size: 40),
        ),
      ),
    );
  }
}
