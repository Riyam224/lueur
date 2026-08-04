import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/styling/app_colors.dart';

/// Rounded, theme-aware progress bar showing streak progress toward the
/// next milestone.
class MilestoneProgressBar extends StatelessWidget {
  const MilestoneProgressBar({
    super.key,
    required this.fraction,
    required this.semanticLabel,
    required this.trackColor,
  });

  static const _height = 10.0;

  final Animation<double> fraction;
  final String semanticLabel;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      value: '${(fraction.value * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusCircle),
        child: SizedBox(
          height: _height.h,
          child: Stack(
            children: [
              Positioned.fill(child: ColoredBox(color: trackColor)),
              AnimatedBuilder(
                animation: fraction,
                builder: (context, _) => FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: fraction.value,
                  child: const ColoredBox(color: AppColors.whiteTextColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
