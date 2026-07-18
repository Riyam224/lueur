import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lueur_app/core/styling/app_colors.dart';
import 'package:lueur_app/features/onboarding/presentation/constants/onboarding_constants.dart';
import 'package:lueur_app/features/onboarding/presentation/models/onboarding_page_data.dart';
import 'package:lueur_app/features/onboarding/presentation/widgets/onboarding_illustration.dart';
import 'package:lueur_app/features/onboarding/presentation/widgets/onboarding_wave_painter.dart';

/// Wave-blob backdrop + illustration + title + subtitle for a single
/// onboarding page.
class OnboardingPageView extends StatelessWidget {
  final OnboardingPageData data;

  const OnboardingPageView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final waveHeight =
            constraints.maxHeight * OnboardingConstants.waveHeightFraction;

        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: OnboardingWavePainter(color: data.blobColor),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: waveHeight,
              child: Center(
                child: OnboardingIllustration(variant: data.variant),
              ),
            ),
            Positioned(
              top: waveHeight,
              left: 0,
              right: 0,
              bottom: 0,
              child: _OnboardingText(data: data),
            ),
          ],
        );
      },
    );
  }
}

class _OnboardingText extends StatelessWidget {
  final OnboardingPageData data;

  const _OnboardingText({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        OnboardingConstants.pageTextHorizontalPadding,
        OnboardingConstants.waveToHeadline,
        OnboardingConstants.pageTextHorizontalPadding,
        0,
      ),
      child: Column(
        children: [
          Text(
            data.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: OnboardingConstants.pageTitleFontSize,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              color: AppColors.onboardingHeadline,
              height: 1.2,
            ),
          ),
          const SizedBox(height: OnboardingConstants.headlineToSubtitle),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: OnboardingConstants.pageSubtitleFontSize,
              fontWeight: FontWeight.w400,
              color: AppColors.onboardingSubtitle,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
