import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/plant/domain/entities/streak_growth_stage.dart';
import 'package:lueur/features/plant/presentation/utils/streak_celebration_animations.dart';
import 'package:lueur/features/plant/presentation/utils/streak_celebration_copy.dart';
import 'package:lueur/features/plant/presentation/widgets/luna_celebration_stage.dart';
import 'package:lueur/features/plant/presentation/widgets/milestone_progress_bar.dart';
import 'package:lueur/features/plant/presentation/widgets/streak_celebration_background.dart';
import 'package:lueur/features/plant/presentation/widgets/streak_celebration_footer.dart';
import 'package:lueur/features/plant/presentation/widgets/streak_celebration_header.dart';
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
  late final StreakCelebrationAnimations _animations;
  late final int _affirmationIndex;

  @override
  void initState() {
    super.initState();
    _affirmationIndex = Random().nextInt(StreakCelebrationCopy.affirmationCount);
    _animations = StreakCelebrationAnimations(
      vsync: this,
      streakDays: widget.streakDays,
    );
    unawaited(_animations.runEntranceSequence(isMounted: () => mounted));
  }

  @override
  void dispose() {
    _animations.dispose();
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
          StreakCelebrationBackground(isDark: isDark),
          SafeArea(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _animations.confettiController,
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
                      StreakCelebrationHeader(
                        streakDays: widget.streakDays,
                        eyebrowLabel: l10n.streakCelebrationEyebrowLabel,
                        subtitle: l10n.streakDaysWithLuna(widget.streakDays),
                      ),
                      const Spacer(),
                      LunaCelebrationStage(
                        burstController: _animations.burstController,
                        bloomScale: _animations.bloomScale,
                        lunaFade: _animations.lunaFade,
                      ),
                      SizedBox(height: AppSpacing.spaceMd),
                      Text(
                        StreakCelebrationCopy.stageLabel(l10n, stage),
                        style: ThemeTextStyles.whiteHeadline(context)
                            .copyWith(fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.spaceMd),
                      MilestoneProgressBar(
                        fraction: _animations.progressFraction,
                        semanticLabel:
                            l10n.streakCelebrationProgressSemanticLabel,
                        trackColor: isDark
                            ? AppColors.celebrationProgressTrackDark
                            : AppColors.celebrationProgressTrackLight,
                      ),
                      SizedBox(height: AppSpacing.spaceSm),
                      Text(
                        StreakCelebrationCopy.nextMilestoneText(
                          l10n,
                          widget.streakDays,
                        ),
                        style: ThemeTextStyles.whiteCaption(context),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(),
                      StreakCelebrationFooter(
                        affirmation: StreakCelebrationCopy.affirmation(
                          l10n,
                          _affirmationIndex,
                        ),
                        buttonLabel: l10n.streakCelebrationKeepGoingButton,
                        onKeepGoing: () => context.go(AppRoutes.home),
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
