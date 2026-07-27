import 'dart:ui' as ui;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/core/utils/app_strings.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_cubit.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_state.dart';
import 'package:lueur/features/sudoku/presentation/widgets/sudoku_grid_widget.dart';
import 'package:lueur/features/sudoku/presentation/widgets/sudoku_number_pad_widget.dart';

/// A calm, simple 9x9 sudoku — one of Luna's offerings for a rough moment.
class SudokuScreen extends StatefulWidget {
  const SudokuScreen({super.key});

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  static String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(1, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _leave(BuildContext context) {
    context.read<SudokuCubit>().recordUnfinishedIfNeeded();
    context.pop();
  }

  void _showHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.sudokuHowToPlayTitle),
        content: const Text(
          AppStrings.sudokuHowToPlayMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(AppStrings.sudokuGotIt),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave(context);
      },
      child: Scaffold(
        body: SafeArea(
          child: BlocConsumer<SudokuCubit, SudokuState>(
            listener: (context, state) {
              if (state.status == SudokuStatus.won) {
                _confettiController.play();
              }
            },
            builder: (context, state) {
              final extra = context.extra;
              return Stack(
                alignment: Alignment.topCenter,
                children: [
                  ConfettiWidget(
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
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.horizontalPaddingLg,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => _leave(context),
                              icon: const Icon(Icons.arrow_back_ios_new_rounded),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => _showHelp(context),
                              icon: const Icon(Icons.help_outline_rounded),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_horiz_rounded),
                              onSelected: (_) => context.read<SudokuCubit>().start(),
                              itemBuilder: (context) => const [
                                PopupMenuItem(value: 'new', child: Text(AppStrings.sudokuNewGameMenuItem)),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(AppStrings.sudokuDifficultyEasy, style: ThemeTextStyles.bodyMedium(context)),
                            SizedBox(width: AppSpacing.spaceMd),
                            Text(
                              'Mistakes: ${state.mistakes}/${SudokuCubit.maxMistakes}',
                              style: ThemeTextStyles.bodyMedium(context).copyWith(
                                color: state.mistakes > 0
                                    ? AppColors.errorColor
                                    : extra.secondaryTextColor,
                              ),
                            ),
                            SizedBox(width: AppSpacing.spaceMd),
                            Text(
                              _formatDuration(state.elapsedSeconds),
                              style: ThemeTextStyles.bodyMedium(context).copyWith(
                                color: extra.secondaryTextColor,
                              ),
                            ),
                            SizedBox(width: AppSpacing.spaceSm),
                            IconButton(
                              onPressed: () => context.read<SudokuCubit>().togglePause(),
                              icon: Icon(
                                state.isPaused
                                    ? Icons.play_arrow_rounded
                                    : Icons.pause_rounded,
                                size: 20,
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.spaceMd),
                        Stack(
                          children: [
                            SudokuGridWidget(
                              state: state,
                              onCellTap: (row, col) =>
                                  context.read<SudokuCubit>().selectCell(row, col),
                            ),
                            if (state.isPaused)
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: BackdropFilter(
                                    filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                    child: Container(
                                      color: extra.cardBackgroundColor!.withValues(
                                        alpha: 0.7,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        AppStrings.sudokuPausedLabel,
                                        style: ThemeTextStyles.titleMedium(context),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.space2Xl),
                        SudokuNumberPadWidget(
                          mode: state.mode,
                          canUndo: state.canUndo,
                          autoCandidateMode: state.autoCandidateMode,
                          values: state.values,
                          onModeChanged: (mode) =>
                              context.read<SudokuCubit>().setMode(mode),
                          onUndo: () => context.read<SudokuCubit>().undo(),
                          onNumberTap: (n) =>
                              context.read<SudokuCubit>().inputNumber(n),
                          onClearTap: () =>
                              context.read<SudokuCubit>().clearSelectedCell(),
                          onAutoCandidateModeChanged: (enabled) => context
                              .read<SudokuCubit>()
                              .toggleAutoCandidateMode(enabled),
                        ),
                        if (state.status == SudokuStatus.won) ...[
                          SizedBox(height: AppSpacing.space2Xl),
                          Text(
                            AppStrings.sudokuWonMessage,
                            style: ThemeTextStyles.titleMedium(context),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppSpacing.spaceMd),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => context.go(AppRoutes.home),
                                  child: const Text(AppStrings.sudokuDoneButton),
                                ),
                              ),
                              SizedBox(width: AppSpacing.spaceMd),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => context.read<SudokuCubit>().start(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryButtonFill,
                                    foregroundColor: AppColors.whiteTextColor,
                                  ),
                                  child: const Text(AppStrings.sudokuPlayAgainButton),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (state.status == SudokuStatus.lost) ...[
                          SizedBox(height: AppSpacing.space2Xl),
                          Text(
                            AppStrings.sudokuLostMessage,
                            style: ThemeTextStyles.titleMedium(context),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppSpacing.spaceMd),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => context.go(AppRoutes.home),
                                  child: const Text(AppStrings.sudokuDoneButton),
                                ),
                              ),
                              SizedBox(width: AppSpacing.spaceMd),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => context.read<SudokuCubit>().start(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryButtonFill,
                                    foregroundColor: AppColors.whiteTextColor,
                                  ),
                                  child: const Text(AppStrings.sudokuTryAgainButton),
                                ),
                              ),
                            ],
                          ),
                        ],
                        SizedBox(height: AppSpacing.spaceXl),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
