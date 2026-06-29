import 'package:flutter/material.dart';

/// Which illustration treatment to render inside a page's wave blob.
enum OnboardingIllustrationVariant { glow, speechBubble, sprout }

/// Content for a single onboarding page: title, subtitle, illustration icon,
/// the wave blob background color and which illustration treatment to use.
class OnboardingPageData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color blobColor;
  final OnboardingIllustrationVariant variant;

  const OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.blobColor,
    required this.variant,
  });
}
