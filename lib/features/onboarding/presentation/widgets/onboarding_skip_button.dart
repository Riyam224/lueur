import 'package:flutter/material.dart';
import 'package:lueur/core/styling/app_fonts.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/features/onboarding/presentation/constants/onboarding_constants.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Pill-shaped "Skip intro" button shown in the bottom nav row on every
/// page except the last.
class OnboardingSkipButton extends StatelessWidget {
  final VoidCallback onPressed;

  const OnboardingSkipButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: context.extra.cardBackgroundColor,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(
          horizontal: OnboardingConstants.skipButtonHorizontalPadding,
          vertical: OnboardingConstants.skipButtonVerticalPadding,
        ),
      ),
      child: Text(
        AppLocalizations.of(context)!.onboardingSkip,
        style: TextStyle(
          fontFamily: AppFonts.dmSansFontName,
          fontSize: OnboardingConstants.skipButtonFontSize,
          fontWeight: FontWeight.w500,
          color: context.extra.primaryColor,
        ),
      ),
    );
  }
}
