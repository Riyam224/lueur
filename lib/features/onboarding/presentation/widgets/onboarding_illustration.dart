import 'package:flutter/material.dart';
import '../models/onboarding_page_data.dart';
import 'onboarding_chat_painter.dart';
import 'onboarding_luna_painter.dart';
import 'onboarding_plant_painter.dart';

/// Renders the correct CustomPaint illustration for an onboarding page.
/// No glow ring or icon wrapper — illustrations render directly on the wave.
class OnboardingIllustration extends StatelessWidget {
  final OnboardingIllustrationVariant variant;

  const OnboardingIllustration({super.key, required this.variant});

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      OnboardingIllustrationVariant.glow => CustomPaint(
          painter: const OnboardingLunaPainter(),
          size: OnboardingLunaPainter.naturalSize,
        ),
      OnboardingIllustrationVariant.speechBubble => CustomPaint(
          painter: const OnboardingChatPainter(),
          size: OnboardingChatPainter.naturalSize,
        ),
      OnboardingIllustrationVariant.sprout => CustomPaint(
          painter: const OnboardingPlantPainter(),
          size: OnboardingPlantPainter.naturalSize,
        ),
    };
  }
}
