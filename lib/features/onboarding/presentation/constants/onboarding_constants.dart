import 'package:ai_therapist_app/core/styling/app_colors.dart';
import 'package:ai_therapist_app/core/utils/app_strings.dart';
import 'package:ai_therapist_app/features/onboarding/presentation/models/onboarding_page_data.dart';
import 'package:flutter/material.dart';

/// Layout, timing and content constants for the onboarding flow.
class OnboardingConstants {
  // ── Animation ─────────────────────────────────────────────────────────────
  static const Duration pageTransitionDuration = Duration(milliseconds: 350);
  static const Curve pageTransitionCurve = Curves.easeInOut;

  // ── Wave blob backdrop (fraction — drives CustomPainter + layout) ─────────
  static const double waveHeightFraction = 0.58;

  // ── Bottom section spacing (logical pixels) ───────────────────────────────
  static const double waveToHeadline = 36;
  static const double headlineToSubtitle = 12;
  static const double subtitleToDots = 24;
  static const double dotsToButton = 20;
  static const double buttonToBottom = 40;
  static const double pageTextHorizontalPadding = 36;
  static const double pageTitleFontSize = 28;
  static const double pageSubtitleFontSize = 14;

  // ── Skip button (logical pixels) ──────────────────────────────────────────
  static const double skipButtonFontSize = 14;
  static const double skipButtonHorizontalPadding = 16;
  static const double skipButtonVerticalPadding = 8;

  // ── Page indicator dots (logical pixels) ──────────────────────────────────
  static const double indicatorActiveDotWidth = 24;
  static const double indicatorDotHeight = 8;
  static const double indicatorInactiveDotSize = 8;
  static const double indicatorDotGap = 8;

  // ── CTA next/finish button (logical pixels) ───────────────────────────────
  static const double nextButtonSize = 64;
  static const Duration nextButtonScaleDuration = Duration(milliseconds: 150);

  // ── Skip button positioning (logical pixels from SafeArea edge) ───────────
  static const double skipButtonTopPadding = 16;
  static const double skipButtonRightPadding = 20;

  static const List<OnboardingPageData> pages = [
    OnboardingPageData(
      title: AppStrings.onboardingTitle1,
      subtitle: AppStrings.onboardingSubtitle1,
      icon: Icons.self_improvement_rounded,
      blobColor: AppColors.onboardingBlobLavender,
      variant: OnboardingIllustrationVariant.glow,
    ),
    OnboardingPageData(
      title: AppStrings.onboardingTitle2,
      subtitle: AppStrings.onboardingSubtitle2,
      icon: Icons.chat_bubble_rounded,
      blobColor: AppColors.onboardingBlobMint,
      variant: OnboardingIllustrationVariant.speechBubble,
    ),
    OnboardingPageData(
      title: AppStrings.onboardingTitle3,
      subtitle: AppStrings.onboardingSubtitle3,
      icon: Icons.eco_rounded,
      blobColor: AppColors.onboardingBlobPeach,
      variant: OnboardingIllustrationVariant.sprout,
    ),
  ];
}
