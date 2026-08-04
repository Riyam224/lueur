import 'package:flutter/material.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_cubit.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Difficulty label, mistakes counter, elapsed timer, and pause toggle.
class SudokuHeaderStats extends StatelessWidget {
  const SudokuHeaderStats({
    super.key,
    required this.mistakes,
    required this.elapsedSeconds,
    required this.isPaused,
    required this.onTogglePause,
  });

  final int mistakes;
  final int elapsedSeconds;
  final bool isPaused;
  final VoidCallback onTogglePause;

  static String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(1, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final extra = context.extra;
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            l10n.sudokuDifficultyEasy,
            overflow: TextOverflow.ellipsis,
            style: ThemeTextStyles.bodyMedium(context),
          ),
        ),
        SizedBox(width: AppSpacing.spaceMd),
        Flexible(
          child: Text(
            l10n.sudokuMistakesLabel(mistakes, SudokuCubit.maxMistakes),
            overflow: TextOverflow.ellipsis,
            style: ThemeTextStyles.bodyMedium(context).copyWith(
              color:
                  mistakes > 0 ? AppColors.errorColor : extra.secondaryTextColor,
            ),
          ),
        ),
        SizedBox(width: AppSpacing.spaceMd),
        Flexible(
          child: Text(
            _formatDuration(elapsedSeconds),
            overflow: TextOverflow.ellipsis,
            style: ThemeTextStyles.bodyMedium(context).copyWith(
              color: extra.secondaryTextColor,
            ),
          ),
        ),
        SizedBox(width: AppSpacing.spaceSm),
        IconButton(
          onPressed: onTogglePause,
          icon: Icon(
            isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            size: AppSizes.iconSm,
          ),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}
