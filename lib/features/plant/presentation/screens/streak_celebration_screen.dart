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
import 'package:lueur/core/styling/app_fonts.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/plant/domain/entities/streak_growth_stage.dart';
import 'package:lueur/features/plant/domain/entities/streak_milestone.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Celebrates a completed streak milestone with a staged entrance: the
/// flower blooms, Luna fades in centered and enlarged with a soft glow and
/// twinkling sparkles, the milestone progress bar fills in, then a
/// one-time confetti burst.
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
  static const _progressDuration = Duration(milliseconds: 700);
  static const _confettiDelay = Duration(milliseconds: 200);
  static const _idleCycleDuration = Duration(milliseconds: 2400);

  late final AnimationController _bloomController;
  late final AnimationController _lunaController;
  late final AnimationController _progressController;
  late final AnimationController _idleController;
  late final Animation<double> _bloomScale;
  late final Animation<double> _lunaFade;
  late final Animation<double> _progressFraction;
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

  String _stageLabel(AppLocalizations l10n, StreakGrowthStage stage) =>
      switch (stage) {
        StreakGrowthStage.seed => l10n.streakGrowthStageSeedLabel,
        StreakGrowthStage.sprout => l10n.streakGrowthStageSproutLabel,
        StreakGrowthStage.plant => l10n.streakGrowthStagePlantLabel,
        StreakGrowthStage.blooming => l10n.streakGrowthStageBloomingLabel,
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
    _lunaFade = CurvedAnimation(parent: _lunaController, curve: Curves.easeOut);

    _progressController = AnimationController(
      vsync: this,
      duration: _progressDuration,
    );
    _progressFraction = Tween<double>(
      begin: 0,
      end: StreakMilestone.progressToNext(widget.streakDays),
    ).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    // Loops for the rest of the screen's lifetime — gives Luna a gentle,
    // festive "alive" idle motion (bob + halo pulse + sparkle twinkle).
    _idleController = AnimationController(
      vsync: this,
      duration: _idleCycleDuration,
    );
    unawaited(_idleController.repeat());

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
    unawaited(_progressController.forward());
    await Future<void>.delayed(_lunaDuration + _confettiDelay);
    if (!mounted) return;
    _confettiController.play();
  }

  @override
  void dispose() {
    _bloomController.dispose();
    _lunaController.dispose();
    _progressController.dispose();
    _idleController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stage = StreakGrowthStage.fromStreak(widget.streakDays);

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
                          AppColors.celebrationGradientDarkStart,
                          AppColors.celebrationGradientDarkEnd,
                        ]
                      : [
                          AppColors.celebrationGradientLightStart,
                          AppColors.celebrationGradientLightEnd,
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
                      AppColors.whiteTextColor,
                      AppColors.buttermilkYellow,
                      AppColors.lavenderLilac,
                      AppColors.celebrationGradientLightStart,
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
                      SizedBox(
                        height: AppSpacing.space3Xl + AppSpacing.spaceSm,
                      ),
                      Text(
                        l10n.streakCelebrationEyebrowLabel.toUpperCase(),
                        style: ThemeTextStyles.whiteCaption(context).copyWith(
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.spaceXs),
                      Text(
                        '${widget.streakDays}',
                        style: TextStyle(
                          fontFamily: AppFonts.mainFontName,
                          fontSize: 72.sp,
                          fontWeight: FontWeight.w800,
                          height: 1.0,
                          color: AppColors.whiteTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.spaceXs),
                      Text(
                        l10n.streakDaysWithLuna(widget.streakDays),
                        style: ThemeTextStyles.whiteBody(context),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(),
                      _LunaStage(
                        idleController: _idleController,
                        bloomScale: _bloomScale,
                        lunaFade: _lunaFade,
                      ),
                      SizedBox(height: AppSpacing.spaceMd),
                      Text(
                        _stageLabel(l10n, stage),
                        style: ThemeTextStyles.whiteHeadline(context)
                            .copyWith(fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.spaceMd),
                      _MilestoneProgressBar(
                        fraction: _progressFraction,
                        semanticLabel:
                            l10n.streakCelebrationProgressSemanticLabel,
                        trackColor: isDark
                            ? AppColors.celebrationProgressTrackDark
                            : AppColors.celebrationProgressTrackLight,
                      ),
                      SizedBox(height: AppSpacing.spaceSm),
                      Text(
                        _nextMilestoneText(l10n),
                        style: ThemeTextStyles.whiteCaption(context),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(),
                      _FrostedCard(
                        child: Text(
                          _affirmation(l10n),
                          style: ThemeTextStyles.whiteBody(context),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: AppSpacing.spaceXl),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context.go(AppRoutes.home),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.whiteTextColor,
                            foregroundColor:
                                AppColors.celebrationGradientLightEnd,
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
                            style: ThemeTextStyles.labelLarge(context).copyWith(
                              color: AppColors.celebrationGradientLightEnd,
                              fontWeight: FontWeight.w700,
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

/// Luna's illustration, staged on a soft glowing halo with twinkling
/// sparkles. [idleController] loops for the widget's whole lifetime and
/// drives the halo pulse, sparkle twinkle, and Luna's gentle idle bob —
/// independent of the one-shot bloom/fade entrance animations.
class _LunaStage extends StatelessWidget {
  const _LunaStage({
    required this.idleController,
    required this.bloomScale,
    required this.lunaFade,
  });

  static const _lunaSize = 170.0;
  static const _bloomSize = 160.0;
  static const _haloSize = 220.0;
  static const _bobAmplitude = 6.0;
  static const _sparklePositions = [
    Alignment(-0.85, -0.75),
    Alignment(0.9, -0.55),
    Alignment(-0.75, 0.7),
    Alignment(0.8, 0.8),
  ];

  final AnimationController idleController;
  final Animation<double> bloomScale;
  final Animation<double> lunaFade;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final haloColor =
        isDark ? AppColors.celebrationGlowDark : AppColors.celebrationGlowLight;

    return SizedBox(
      height: 260.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: idleController,
            builder: (context, child) {
              final pulse = 0.9 + 0.1 * sin(idleController.value * 2 * pi);
              return Transform.scale(
                scale: pulse,
                child: Container(
                  width: _haloSize.w,
                  height: _haloSize.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: haloColor,
                  ),
                ),
              );
            },
          ),
          for (final position in _sparklePositions)
            Align(
              alignment: position,
              child: _SparkleTwinkle(
                controller: idleController,
                phase: _sparklePositions.indexOf(position) * 0.25,
              ),
            ),
          AnimatedBuilder(
            animation: bloomScale,
            builder: (context, child) => Transform.scale(
              scale: bloomScale.value,
              child: child,
            ),
            child: Lottie.asset(
              AppAssets.lottieBlooming,
              width: _bloomSize.w,
              height: _bloomSize.h,
              fit: BoxFit.contain,
              repeat: false,
              errorBuilder: (_, __, ___) =>
                  SizedBox(width: _bloomSize.w, height: _bloomSize.h),
            ),
          ),
          FadeTransition(
            opacity: lunaFade,
            child: AnimatedBuilder(
              animation: idleController,
              builder: (context, child) {
                final bob =
                    _bobAmplitude.h * sin(idleController.value * 2 * pi);
                return Transform.translate(
                  offset: Offset(0, bob),
                  child: child,
                );
              },
              child: Image.asset(
                AppAssets.lunaCharacter,
                width: _lunaSize.w,
                height: _lunaSize.h,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single twinkling star that fades and scales in a loop, offset by
/// [phase] so multiple sparkles don't blink in unison.
class _SparkleTwinkle extends StatelessWidget {
  const _SparkleTwinkle({required this.controller, required this.phase});

  static const _maxSize = 14.0;

  final AnimationController controller;
  final double phase;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = (controller.value + phase) % 1.0;
        final twinkle = (sin(t * 2 * pi) + 1) / 2;
        return Opacity(
          opacity: 0.25 + 0.75 * twinkle,
          child: Transform.scale(
            scale: 0.6 + 0.4 * twinkle,
            child: child,
          ),
        );
      },
      child: Icon(
        Icons.auto_awesome,
        size: _maxSize.sp,
        color: AppColors.celebrationSparkle,
      ),
    );
  }
}

/// Rounded, theme-aware progress bar showing streak progress toward the
/// next milestone.
class _MilestoneProgressBar extends StatelessWidget {
  const _MilestoneProgressBar({
    required this.fraction,
    required this.semanticLabel,
    required this.trackColor,
  });

  static const _height = 10.0;

  final Animation<double> fraction;
  final String semanticLabel;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      value: '${(fraction.value * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusCircle),
        child: SizedBox(
          height: _height.h,
          child: Stack(
            children: [
              Positioned.fill(child: ColoredBox(color: trackColor)),
              AnimatedBuilder(
                animation: fraction,
                builder: (context, _) => FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: fraction.value,
                  child: const ColoredBox(color: AppColors.whiteTextColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Frosted-glass card used to keep body copy legible on top of the
/// celebration gradient in both light and dark mode.
class _FrostedCard extends StatelessWidget {
  const _FrostedCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontalPaddingLg,
        vertical: AppSpacing.verticalPaddingMd,
      ),
      decoration: BoxDecoration(
        color: AppColors.whiteTextColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
      ),
      child: child,
    );
  }
}
