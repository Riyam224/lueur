import 'package:flutter/material.dart';
import 'package:lueur/core/styling/app_assets.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/features/onboarding/presentation/constants/onboarding_constants.dart';

/// Pre-compiles onboarding's shader pipelines during splash's idle wait
/// (measured 100-260ms/frame stall). Must actually be painted — `Offstage`/zero-`Opacity` would skip the GPU submission this relies on.
class SplashShaderWarmup extends StatelessWidget {
  const SplashShaderWarmup({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = OnboardingConstants.pages(context);

    return Wrap(
      children: [
        for (final page in pages) ...[
          _WarmupSwatch(color: page.cardColor, borderRadius: OnboardingConstants.cardBorderRadius),
          _WarmupSwatch(color: page.circleColor, shape: BoxShape.circle),
        ],
        const _WarmupBadgeShadow(),
        Image.asset(AppAssets.lunaCharacter, width: 2, height: 2),
      ],
    );
  }
}

class _WarmupSwatch extends StatelessWidget {
  final Color color;
  final double? borderRadius;
  final BoxShape shape;

  const _WarmupSwatch({
    required this.color,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 2,
      height: 2,
      decoration: BoxDecoration(
        color: color,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle && borderRadius != null
            ? BorderRadius.circular(borderRadius!)
            : null,
      ),
    );
  }
}

class _WarmupBadgeShadow extends StatelessWidget {
  const _WarmupBadgeShadow();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 2,
      height: 2,
      decoration: const BoxDecoration(
        color: AppColors.whiteTextColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: AppColors.shadowColor, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
    );
  }
}
