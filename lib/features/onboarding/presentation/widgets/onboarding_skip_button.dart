import 'package:ai_therapist_app/core/styling/app_colors.dart';
import 'package:ai_therapist_app/core/utils/app_strings.dart';
import 'package:ai_therapist_app/features/onboarding/presentation/constants/onboarding_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pill-shaped "Skip intro" button shown top-right on pages 1 and 2.
class OnboardingSkipButton extends StatelessWidget {
  final VoidCallback onPressed;

  const OnboardingSkipButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: AppColors.lightBackground,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(
          horizontal: OnboardingConstants.skipButtonHorizontalPadding,
          vertical: OnboardingConstants.skipButtonVerticalPadding,
        ),
      ),
      child: Text(
        AppStrings.onboardingSkip,
        style: GoogleFonts.dmSans(
          fontSize: OnboardingConstants.skipButtonFontSize,
          fontWeight: FontWeight.w500,
          color: AppColors.onboardingAccent,
        ),
      ),
    );
  }
}
