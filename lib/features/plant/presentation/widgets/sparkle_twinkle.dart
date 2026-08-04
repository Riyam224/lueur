import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/styling/app_colors.dart';

/// A single twinkling star that fades and scales in a loop, offset by
/// [phase] so multiple sparkles don't blink in unison.
class SparkleTwinkle extends StatelessWidget {
  const SparkleTwinkle({
    super.key,
    required this.controller,
    required this.phase,
  });

  static const _maxSize = 14.0;

  final AnimationController controller;
  final double phase;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = (controller.value + phase) % 1.0;
        final twinkle = (sin(t * 2 * pi) + 1) / 2;
        return Opacity(
          opacity: 0.25 + 0.75 * twinkle,
          child: Transform.scale(
            scale: 0.6 + 0.4 * twinkle,
            child: child,
          ),
        );
      },
      child: Icon(
        Icons.auto_awesome,
        size: _maxSize.sp,
        color: AppColors.celebrationSparkle,
      ),
    );
  }
}
