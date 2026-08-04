import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:lueur/core/styling/app_assets.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/features/plant/presentation/widgets/sparkle_twinkle.dart';

/// Luna's illustration, staged on a soft glowing halo with twinkling
/// sparkles. [idleController] loops for the widget's whole lifetime and
/// drives the halo pulse, sparkle twinkle, and Luna's gentle idle bob —
/// independent of the one-shot bloom/fade entrance animations.
class LunaCelebrationStage extends StatelessWidget {
  const LunaCelebrationStage({
    super.key,
    required this.idleController,
    required this.bloomScale,
    required this.lunaFade,
  });

  static const _lunaSize = 170.0;
  static const _bloomSize = 160.0;
  static const _haloSize = 220.0;
  static const _bobAmplitude = 6.0;
  static const _sparklePositions = [
    Alignment(-0.85, -0.75),
    Alignment(0.9, -0.55),
    Alignment(-0.75, 0.7),
    Alignment(0.8, 0.8),
  ];

  final AnimationController idleController;
  final Animation<double> bloomScale;
  final Animation<double> lunaFade;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final haloColor = isDark
        ? AppColors.celebrationGlowDark
        : AppColors.celebrationGlowLight;

    return SizedBox(
      height: 260.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: idleController,
            builder: (context, child) {
              final pulse = 0.9 + 0.1 * sin(idleController.value * 2 * pi);
              return Transform.scale(
                scale: pulse,
                child: Container(
                  width: _haloSize.w,
                  height: _haloSize.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: haloColor,
                  ),
                ),
              );
            },
          ),
          for (final position in _sparklePositions)
            Align(
              alignment: position,
              child: SparkleTwinkle(
                controller: idleController,
                phase: _sparklePositions.indexOf(position) * 0.25,
              ),
            ),
          AnimatedBuilder(
            animation: bloomScale,
            builder: (context, child) => Transform.scale(
              scale: bloomScale.value,
              child: child,
            ),
            child: Lottie.asset(
              AppAssets.lottieBlooming,
              width: _bloomSize.w,
              height: _bloomSize.h,
              fit: BoxFit.contain,
              repeat: false,
              errorBuilder: (_, __, ___) =>
                  SizedBox(width: _bloomSize.w, height: _bloomSize.h),
            ),
          ),
          FadeTransition(
            opacity: lunaFade,
            child: AnimatedBuilder(
              animation: idleController,
              builder: (context, child) {
                final bob =
                    _bobAmplitude.h * sin(idleController.value * 2 * pi);
                return Transform.translate(
                  offset: Offset(0, bob),
                  child: child,
                );
              },
              child: Image.asset(
                AppAssets.lunaCharacter,
                width: _lunaSize.w,
                height: _lunaSize.h,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
