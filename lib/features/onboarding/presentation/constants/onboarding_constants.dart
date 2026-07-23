import 'package:flutter/material.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/utils/app_strings.dart';
import 'package:lueur/features/onboarding/presentation/models/onboarding_page_data.dart';

/// Layout, timing and content constants for the onboarding flow.
class OnboardingConstants {
  // ── Animation ─────────────────────────────────────────────────────────────
  static const Duration pageTransitionDuration = Duration(milliseconds: 350);
  static const Curve pageTransitionCurve = Curves.easeInOut;

  // ── Card (fractions of the page size) ─────────────────────────────────────
  static const double cardHorizontalMarginFraction = 0.06;
  static const double cardTopMarginFraction = 0.04;
  static const double cardBorderRadius = 32;
  static const double circleSizeFraction = 0.56;
  static const double circleTopFraction = 0.08;
  static const double lunaSizeFraction = 0.4;
  static const double badgeSize = 44;

  // ── Parallax (how much the off-screen pages scale/fade/slide) ─────────────
  static const double parallaxScaleFalloff = 0.15;
  static const double parallaxOpacityFalloff = 0.5;
  static const double parallaxTextSlide = 30;

  // ── Bottom text block (logical pixels) ─────────────────────────────────────
  static const double circleToHeadline = 28;
  static const double headlineToSubtitle = 12;
  static const double pageTextHorizontalPadding = 32;
  static const double pageTitleFontSize = 26;
  static const double pageSubtitleFontSize = 14;

  // ── Skip button (logical pixels) ──────────────────────────────────────────
  static const double skipButtonFontSize = 14;
  static const double skipButtonHorizontalPadding = 16;
  static const double skipButtonVerticalPadding = 8;

  // ── Bottom nav row (back/forward arrows + skip) ────────────────────────────
  static const double navArrowButtonSize = 48;
  static const double navArrowGap = 12;
  static const double navRowBottomPadding = 28;
  static const double navRowHorizontalPadding = 32;
  static const Duration navArrowScaleDuration = Duration(milliseconds: 150);

  static const List<OnboardingPageData> pages = [
    OnboardingPageData(
      title: AppStrings.onboardingTitle1,
      subtitle: AppStrings.onboardingSubtitle1,
      badgeIcon: Icons.self_improvement_rounded,
      cardColor: AppColors.pastelBlush,
      circleColor: AppColors.pastelCoral,
    ),
    OnboardingPageData(
      title: AppStrings.onboardingTitle2,
      subtitle: AppStrings.onboardingSubtitle2,
      badgeIcon: Icons.chat_bubble_rounded,
      cardColor: AppColors.pastelPeriwinkle,
      circleColor: AppColors.pastelPurple,
    ),
    OnboardingPageData(
      title: AppStrings.onboardingTitle3,
      subtitle: AppStrings.onboardingSubtitle3,
      badgeIcon: Icons.eco_rounded,
      cardColor: AppColors.pastelLavenderWhite,
      circleColor: AppColors.pastelOrchid,
    ),
  ];
}
