import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_text_styles.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/breathing/domain/entities/breathing_config_entity.dart';
import 'package:lueur/features/breathing/presentation/cubit/breathing_cubit.dart';
import 'package:lueur/features/breathing/presentation/cubit/breathing_state.dart';
import 'package:lueur/features/breathing/presentation/widgets/breathing_ring_visual.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Flower ring, phase label, and seconds countdown for the current breathing
/// phase. Scoped to `elapsedSeconds` via [BlocSelector] so the once-per-second
/// tick only rebuilds this subtree, not the whole in-progress screen (which
/// only rebuilds on phase changes — see `BreathingScreen`'s `buildWhen`).
class BreathingPhaseProgress extends StatelessWidget {
  const BreathingPhaseProgress({
    super.key,
    required this.isBreatheIn,
    required this.config,
    required this.phaseLabel,
    required this.ringColor,
    required this.inkColor,
    required this.scale,
  });

  final bool isBreatheIn;
  final BreathingConfigEntity config;
  final String phaseLabel;
  final Color ringColor;
  final Color inkColor;
  final Animation<double> scale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocSelector<BreathingCubit, BreathingState, int>(
      selector: (state) =>
          state is BreathingInProgress ? state.elapsedSeconds : 0,
      builder: (context, elapsedSeconds) {
        final positionInCycle = elapsedSeconds % config.cycleSeconds;
        final phaseDuration =
            isBreatheIn ? config.breatheInSeconds : config.breatheOutSeconds;
        final phaseElapsed = isBreatheIn
            ? positionInCycle
            : positionInCycle - config.breatheInSeconds;
        final phaseProgress = (phaseElapsed / phaseDuration).clamp(0.0, 1.0);
        final phaseRemaining =
            (phaseDuration - phaseElapsed).clamp(0, phaseDuration).toInt();

        return Column(
          children: [
            BreathingRingVisual(
              scale: scale,
              ringColor: ringColor,
              phaseProgress: phaseProgress,
            ),
            SizedBox(height: AppSpacing.spaceXl),
            Text(
              phaseLabel,
              key: ValueKey(phaseLabel),
              style: AppTextStyles.displayMedium(context).copyWith(
                color: inkColor,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.spaceXs),
            Text(
              l10n.breathingPhaseSecondsRemaining(phaseRemaining),
              style: ThemeTextStyles.bodySmall(context).copyWith(
                color: inkColor.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}
