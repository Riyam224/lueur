import 'package:flutter/material.dart';

/// Content for a single onboarding page: title, subtitle, the card's
/// background color, the darker circle color behind Luna, and a small
/// theme badge icon shown next to her.
class OnboardingPageData {
  final String title;
  final String subtitle;
  final IconData badgeIcon;
  final Color cardColor;
  final Color circleColor;

  const OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.badgeIcon,
    required this.cardColor,
    required this.circleColor,
  });
}
