import 'package:ai_therapist_app/features/onboarding/presentation/models/onboarding_page_data.dart';
import 'package:ai_therapist_app/features/onboarding/presentation/widgets/onboarding_chat_painter.dart';
import 'package:ai_therapist_app/features/onboarding/presentation/widgets/onboarding_luna_painter.dart';
import 'package:ai_therapist_app/features/onboarding/presentation/widgets/onboarding_plant_painter.dart';
import 'package:flutter/material.dart';

/// Renders the correct CustomPaint illustration for an onboarding page.
/// No glow ring or icon wrapper — illustrations render directly on the wave.
class OnboardingIllustration extends StatelessWidget {
  final OnboardingIllustrationVariant variant;

  const OnboardingIllustration({super.key, required this.variant});

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      OnboardingIllustrationVariant.glow => const CustomPaint(
          painter: OnboardingLunaPainter(),
          size: OnboardingLunaPainter.naturalSize,
        ),
      OnboardingIllustrationVariant.speechBubble => const CustomPaint(
          painter: OnboardingChatPainter(),
          size: OnboardingChatPainter.naturalSize,
        ),
      OnboardingIllustrationVariant.sprout => const CustomPaint(
          painter: OnboardingPlantPainter(),
          size: OnboardingPlantPainter.naturalSize,
        ),
    };
  }
}
