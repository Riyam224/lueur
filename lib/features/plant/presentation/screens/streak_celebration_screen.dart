import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';

const List<String> _streakCelebrationAffirmations = [
  'A whole week of showing up for yourself. Luna noticed 🌸',
  'Seven days of choosing yourself, one thought at a time.',
  'You kept coming back — that\'s the whole secret, really.',
  'Luna is so glad you\'re still here, day after day.',
  'This is what taking care of you looks like. Keep it up.',
  'A full week, gently and honestly. That\'s worth celebrating.',
];

/// Celebrates a completed 7-day streak with a staged entrance: the flower
/// blooms, Luna pops up beside it, then a one-time confetti burst.
class StreakCelebrationScreen extends StatefulWidget {
  const StreakCelebrationScreen({required this.streakDays, super.key});

  final int streakDays;

  @override
  State<StreakCelebrationScreen> createState() =>
      _StreakCelebrationScreenState();
}

class _StreakCelebrationScreenState extends State<StreakCelebrationScreen>
    with TickerProviderStateMixin {
  static const _bloomDuration = Duration(milliseconds: 500);
  static const _lunaDelay = Duration(milliseconds: 300);
  static const _lunaDuration = Duration(milliseconds: 500);
  static const _confettiDelay = Duration(milliseconds: 200);

  late final AnimationController _bloomController;
  late final AnimationController _lunaController;
  late final Animation<double> _bloomScale;
  late final Animation<double> _lunaScale;
  late final Animation<double> _lunaOffset;
  late final ConfettiController _confettiController;
  late final String _affirmation;

  @override
  void initState() {
    super.initState();
    _affirmation = _streakCelebrationAffirmations[
        Random().nextInt(_streakCelebrationAffirmations.length)];

    _bloomController = AnimationController(
      vsync: this,
      duration: _bloomDuration,
    );
    _bloomScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _bloomController, curve: Curves.elasticOut),
    );

    _lunaController = AnimationController(
      vsync: this,
      duration: _lunaDuration,
    );
    _lunaScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _lunaController, curve: Curves.elasticOut),
    );
    _lunaOffset = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _lunaController, curve: Curves.easeOut),
    );

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    unawaited(_runEntranceSequence());
  }

  Future<void> _runEntranceSequence() async {
    unawaited(_bloomController.forward());
    await Future<void>.delayed(_lunaDelay);
    if (!mounted) return;
    unawaited(_lunaController.forward());
    await Future<void>.delayed(_lunaDuration + _confettiDelay);
    if (!mounted) return;
    _confettiController.play();
  }

  @override
  void dispose() {
    _bloomController.dispose();
    _lunaController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.journalGridBackground;
    final headingColor =
        isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground;
    final subheadingColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 24,
                gravity: 0.3,
                colors: const [
                  AppColors.primary,
                  AppColors.lavender,
                  AppColors.blushPink,
                  AppColors.primaryContainer,
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.horizontalPaddingLg,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  SizedBox(
                    height: 240,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _bloomScale,
                          builder: (context, child) => Transform.scale(
                            scale: _bloomScale.value,
                            child: child,
                          ),
                          child: Lottie.asset(
                            'assets/lottie/blooming.json',
                            width: 180,
                            height: 180,
                            fit: BoxFit.contain,
                            repeat: false,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox(width: 180, height: 180),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: AnimatedBuilder(
                            animation: _lunaController,
                            builder: (context, child) => Transform.translate(
                              offset: Offset(0, _lunaOffset.value),
                              child: Transform.scale(
                                scale: _lunaScale.value,
                                child: child,
                              ),
                            ),
                            child: Image.asset(
                              'assets/images/luna_splash.png',
                              width: 90,
                              height: 90,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.spaceXl),
                  Text(
                    '${widget.streakDays} days with Luna 🌸',
                    style: ThemeTextStyles.editorialHeadline(
                      context,
                      color: headingColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.spaceMd),
                  Text(
                    _affirmation,
                    style: ThemeTextStyles.bodyMedium(context).copyWith(
                      color: subheadingColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go(AppRoutes.home),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryButtonFill,
                        foregroundColor: AppColors.whiteTextColor,
                        padding: EdgeInsets.symmetric(
                          vertical: AppSpacing.verticalPaddingLg,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.borderRadiusLg),
                        ),
                      ),
                      child: const Text(
                        'keep going',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.spaceXl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
