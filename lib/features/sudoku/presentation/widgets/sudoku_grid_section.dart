import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_cubit.dart';
import 'package:lueur/features/sudoku/presentation/widgets/sudoku_grid_widget.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// The 9x9 grid plus a frosted "Paused" overlay shown while the game is
/// paused.
class SudokuGridSection extends StatelessWidget {
  const SudokuGridSection({
    super.key,
    required this.isPaused,
    required this.onCellTap,
  });

  final bool isPaused;
  final void Function(int row, int col) onCellTap;

  @override
  Widget build(BuildContext context) {
    final extra = context.extra;

    return Stack(
      children: [
        SudokuGridWidget(
          state: context.read<SudokuCubit>().state,
          onCellTap: onCellTap,
        ),
        if (isPaused)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  color: extra.cardBackgroundColor!.withValues(alpha: 0.7),
                  alignment: Alignment.center,
                  child: Text(
                    AppLocalizations.of(context)!.sudokuPausedLabel,
                    style: ThemeTextStyles.titleMedium(context),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
