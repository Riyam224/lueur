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
import 'package:lueur/core/styling/app_assets.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/app_extra_colors.dart';
import 'package:lueur/core/styling/app_text_styles.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/plant/domain/entities/streak_milestone.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Celebrates a completed streak milestone with a staged entrance: the
/// flower blooms, Luna fades in centered and enlarged, then a one-time
/// confetti burst.
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
  late final Animation<double> _lunaFade;
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

  String _nextMilestoneText(AppLocalizations l10n) {
    final next = StreakMilestone.next(widget.streakDays);
    if (next == null) return l10n.streakCelebrationAllMilestonesReached;
    return l10n.streakCelebrationNextMilestone(next.days - widget.streakDays);
  }

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
    _lunaFade = CurvedAnimation(parent: _lunaController, curve: Curves.easeOut);

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
    final extraColors = Theme.of(context).extension<AppExtraColors>()!;
    final subheadingColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [
                          AppColors.bannerGradientDarkStart,
                          AppColors.primaryDarkDeep,
                        ]
                      : [
                          AppColors.sunriseGradientTop,
                          AppColors.bannerGradientLightEnd,
                        ],
                ),
              ),
            ),
          ),
          SafeArea(
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
                      SizedBox(height: AppSpacing.spaceLg),
                      Text(
                        '${widget.streakDays}',
                        style: AppTextStyles.displayLarge(context).copyWith(
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w800,
                          fontSize: 72.sp,
                          color: extraColors.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.spaceXs),
                      Text(
                        l10n.streakDaysWithLuna(widget.streakDays),
                        style: ThemeTextStyles.headlineSmall(context)
                            .copyWith(color: extraColors.primaryTextColor),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(),
                      SizedBox(
                        height: 260.h,
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
                                width: 160.w,
                                height: 160.h,
                                fit: BoxFit.contain,
                                repeat: false,
                                errorBuilder: (_, __, ___) =>
                                    SizedBox(width: 160.w, height: 160.h),
                              ),
                            ),
                            FadeTransition(
                              opacity: _lunaFade,
                              child: Image.asset(
                                AppAssets.lunaCharacter,
                                width: 170.w,
                                height: 170.h,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSpacing.spaceXl),
                      Text(
                        _affirmation(l10n),
                        style: ThemeTextStyles.bodyMedium(context).copyWith(
                          color: subheadingColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.spaceSm),
                      Text(
                        _nextMilestoneText(l10n),
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          color: extraColors.secondaryTextColor,
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
                              borderRadius: BorderRadius.circular(
                                AppSizes.borderRadiusLg,
                              ),
                            ),
                          ),
                          child: Text(
                            l10n.streakCelebrationKeepGoingButton,
                            style: ThemeTextStyles.labelLarge(context)
                                .copyWith(
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
        ],
      ),
    );
  }
}
