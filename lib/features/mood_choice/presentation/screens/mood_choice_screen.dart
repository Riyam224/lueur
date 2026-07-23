// lib/features/mood_choice/presentation/screens/mood_choice_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_text_styles.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/core/theme/calm_mode_colors.dart';

class MoodChoiceScreen extends StatelessWidget {
  final String emoji;
  final String thoughts;

  const MoodChoiceScreen({
    super.key,
    required this.emoji,
    this.thoughts = '',
  });

  void _goToBreathing(BuildContext context) {
    context.push(
      AppRoutes.breathing,
      extra: {'emoji': emoji, 'thoughts': thoughts},
    );
  }

  void _goToFreeDraw(BuildContext context) {
    context.push(
      AppRoutes.freeDraw,
      extra: {'emoji': emoji, 'thoughts': thoughts},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: CalmModeColors.navyGradient,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.horizontalPaddingXl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSpacing.space3Xl),
                Text(
                  'rough day, huh?',
                  style: ThemeTextStyles.bodySmall(context).copyWith(
                    color: CalmModeColors.mutedInk,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: AppSpacing.spaceXs),
                Text(
                  'whatever feels right right now',
                  style: AppTextStyles.displayMedium(context).copyWith(
                    color: CalmModeColors.ink,
                  ),
                ),
                SizedBox(height: AppSpacing.space3Xl),
                _MoodChoiceCard(
                  title: 'breathe with luna',
                  subtitle: 'a slow, guided moment',
                  glowColor: CalmModeColors.lavenderGlow,
                  onTap: () => _goToBreathing(context),
                ),
                SizedBox(height: AppSpacing.spaceLg),
                _MoodChoiceCard(
                  title: 'free draw',
                  subtitle: 'no pressure, just color',
                  glowColor: CalmModeColors.peachGlow,
                  onTap: () => _goToFreeDraw(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MoodChoiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color glowColor;
  final VoidCallback onTap;

  const _MoodChoiceCard({
    required this.title,
    required this.subtitle,
    required this.glowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.spaceXl),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    glowColor.withValues(alpha: 0.9),
                    glowColor.withValues(alpha: 0.35),
                  ],
                ),
              ),
            ),
            SizedBox(width: AppSpacing.spaceLg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ThemeTextStyles.bodyLarge(context).copyWith(
                      color: CalmModeColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppSpacing.spaceXs),
                  Text(
                    subtitle,
                    style: ThemeTextStyles.bodySmall(context).copyWith(
                      color: CalmModeColors.mutedInk,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
