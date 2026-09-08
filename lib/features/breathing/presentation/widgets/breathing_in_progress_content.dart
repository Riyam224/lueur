import 'package:flutter/material.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/features/breathing/domain/entities/breathing_phase.dart';
import 'package:lueur/features/breathing/presentation/cubit/breathing_state.dart';
import 'package:lueur/features/breathing/presentation/widgets/breathing_phase_dots.dart';
import 'package:lueur/features/breathing/presentation/widgets/breathing_phase_progress.dart';
import 'package:lueur/features/breathing/presentation/widgets/breathing_progress_section.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Breathing ring, phase label/dots, and progress bar shown while a
/// breathing exercise is running. The screen title lives in the app bar.
class BreathingInProgressContent extends StatelessWidget {
  const BreathingInProgressContent({
    super.key,
    required this.state,
    required this.inkColor,
    required this.scale,
  });

  final BreathingInProgress state;
  final Color inkColor;
  final Animation<double> scale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isBreatheIn = state.phase == BreathingPhase.breatheIn;
    final phaseLabel =
        isBreatheIn ? l10n.breathingPhaseIn : l10n.breathingPhaseOut;
    final ringColor = isBreatheIn
        ? AppColors.breathingGradientLavender
        : AppColors.breathingGradientPeach;

    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPaddingXl),
      child: Column(
        children: [
          const Spacer(),
          BreathingPhaseProgress(
            isBreatheIn: isBreatheIn,
            config: state.config,
            phaseLabel: phaseLabel,
            ringColor: ringColor,
            inkColor: inkColor,
            scale: scale,
          ),
          SizedBox(height: AppSpacing.spaceMd),
          BreathingPhaseDots(isBreatheIn: isBreatheIn, inkColor: inkColor),
          const Spacer(),
          BreathingProgressSection(
            totalSeconds: state.config.totalDurationSeconds,
            inkColor: inkColor,
            progressColor: ringColor,
          ),
          SizedBox(height: AppSpacing.spaceLg),
        ],
      ),
    );
  }
}
