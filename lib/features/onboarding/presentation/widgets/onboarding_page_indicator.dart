import 'package:ai_therapist_app/core/styling/app_colors.dart';
import 'package:ai_therapist_app/features/onboarding/presentation/constants/onboarding_constants.dart';
import 'package:flutter/material.dart';

/// Animated pill-dot row showing the current onboarding page.
class OnboardingPageIndicator extends StatelessWidget {
  final int pageCount;
  final int currentPage;

  const OnboardingPageIndicator({
    super.key,
    required this.pageCount,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        final isActive = index == currentPage;

        return AnimatedContainer(
          duration: OnboardingConstants.pageTransitionDuration,
          curve: OnboardingConstants.pageTransitionCurve,
          margin: const EdgeInsets.symmetric(
            horizontal: OnboardingConstants.indicatorDotGap / 2,
          ),
          width: isActive
              ? OnboardingConstants.indicatorActiveDotWidth
              : OnboardingConstants.indicatorInactiveDotSize,
          height: OnboardingConstants.indicatorDotHeight,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.onboardingAccent
                : AppColors.onboardingDotInactive,
            borderRadius: BorderRadius.circular(
              OnboardingConstants.indicatorDotHeight / 2,
            ),
          ),
        );
      }),
    );
  }
}
