import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/l10n/app_localizations.dart';

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
  static const int _affirmationCount = 6;
  late final int _affirmationIndex;

  String _affirmation(AppLocalizations l10n) => switch (_affirmationIndex) {
        0 => l10n.streakCelebrationAffirmations0,
        1 => l10n.streakCelebrationAffirmations1,
        2 => l10n.streakCelebrationAffirmations2,
        3 => l10n.streakCelebrationAffirmations3,
        4 => l10n.streakCelebrationAffirmations4,
        _ => l10n.streakCelebrationAffirmations5,
      };

  @override
  void initState() {
    super.initState();
    _affirmationIndex = Random().nextInt(_affirmationCount);

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
    final l10n = AppLocalizations.of(context)!;
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
                    height: 240.h,
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
                            width: 180.w,
                            height: 180.h,
                            fit: BoxFit.contain,
                            repeat: false,
                            errorBuilder: (_, __, ___) =>
                                SizedBox(width: 180.w, height: 180.h),
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
                              width: 90.w,
                              height: 90.h,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.spaceXl),
                  Text(
                    l10n.streakDaysWithLuna(widget.streakDays),
                    style: ThemeTextStyles.editorialHeadline(
                      context,
                      color: headingColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.spaceMd),
                  Text(
                    _affirmation(l10n),
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
                      child: Text(
                        l10n.streakCelebrationKeepGoingButton,
                        style: ThemeTextStyles.labelLarge(context).copyWith(
                          color: AppColors.whiteTextColor,
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
