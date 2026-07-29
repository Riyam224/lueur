import 'package:flutter/material.dart';
import 'package:lueur/core/styling/app_assets.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/features/onboarding/presentation/constants/onboarding_constants.dart';

/// Paints one tiny instance of every distinct card/circle color and the
/// badge shadow used across the onboarding pages, so the GPU backend
/// compiles those shader pipelines during the splash screen's idle wait
/// instead of during the first onboarding swipe (where the compile stall
/// was measured to cost 100-260ms per frame — see splash-jank profiling).
/// Must actually be painted (not `Offstage`/zero-`Opacity`, both of which
/// skip painting and therefore skip the GPU submission we're warming up),
/// so it's placed under an opaque cover in [SplashScreen] instead.
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
