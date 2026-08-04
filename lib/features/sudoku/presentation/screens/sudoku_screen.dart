import 'dart:ui' as ui;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_cubit.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_state.dart';
import 'package:lueur/features/sudoku/presentation/widgets/sudoku_grid_widget.dart';
import 'package:lueur/features/sudoku/presentation/widgets/sudoku_number_pad_widget.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Slice of [SudokuState] the mistakes/timer/pause row needs. Scoping the
/// rebuild to just this record means the ticking timer (`elapsedSeconds`,
/// emitted once per second) no longer forces the 9x9 grid or number pad to
/// rebuild.
typedef _HeaderSlice = (int mistakes, int elapsedSeconds, bool isPaused);

/// Slice of [SudokuState] the grid actually renders. `values`/`given`/
/// `conflicts`/`candidates` keep the same list reference from `copyWith`
/// whenever they aren't the field being updated, so comparing this record by
/// value skips a grid rebuild on unrelated state changes (e.g. the timer).
typedef _GridSlice = (
  List<List<int>>,
  List<List<bool>>,
  List<List<bool>>,
  List<List<Set<int>>>,
  int?,
  int?,
  bool,
);

/// Slice of [SudokuState] the number pad needs.
typedef _NumberPadSlice = (
  SudokuInputMode mode,
  bool canUndo,
  bool autoCandidateMode,
  List<List<int>> values,
);

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
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.sudokuHowToPlayTitle),
        content: Text(
          l10n.sudokuHowToPlayMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.sudokuGotIt),
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
          child: BlocListener<SudokuCubit, SudokuState>(
            listenWhen: (previous, current) => previous.status != current.status,
            listener: (context, state) {
              if (state.status == SudokuStatus.won) {
                _confettiController.play();
              }
            },
            child: Stack(
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
                SingleChildScrollView(
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
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'new',
                                child: Text(AppLocalizations.of(context)!.sudokuNewGameMenuItem),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Scoped to (mistakes, elapsedSeconds, isPaused) so the
                      // once-per-second timer tick only rebuilds this row,
                      // not the grid or number pad below.
                      BlocSelector<SudokuCubit, SudokuState, _HeaderSlice>(
                        selector: (state) => (state.mistakes, state.elapsedSeconds, state.isPaused),
                        builder: (context, header) {
                          final (mistakes, elapsedSeconds, isPaused) = header;
                          final extra = context.extra;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  AppLocalizations.of(context)!.sudokuDifficultyEasy,
                                  overflow: TextOverflow.ellipsis,
                                  style: ThemeTextStyles.bodyMedium(context),
                                ),
                              ),
                              SizedBox(width: AppSpacing.spaceMd),
                              Flexible(
                                child: Text(
                                  AppLocalizations.of(context)!.sudokuMistakesLabel(
                                    mistakes,
                                    SudokuCubit.maxMistakes,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  style: ThemeTextStyles.bodyMedium(context).copyWith(
                                    color: mistakes > 0
                                        ? AppColors.errorColor
                                        : extra.secondaryTextColor,
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
                                onPressed: () => context.read<SudokuCubit>().togglePause(),
                                icon: Icon(
                                  isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                                  size: AppSizes.iconSm,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: AppSpacing.spaceMd),
                      // Scoped to only the fields the grid renders, so the
                      // 9x9 grid does not rebuild on every timer tick or
                      // mistakes-counter change — only on moves/selection.
                      BlocSelector<SudokuCubit, SudokuState, _GridSlice>(
                        selector: (state) => (
                          state.values,
                          state.given,
                          state.conflicts,
                          state.candidates,
                          state.selectedRow,
                          state.selectedCol,
                          state.isPaused,
                        ),
                        builder: (context, grid) {
                          final (_, _, _, _, _, _, isPaused) = grid;
                          final extra = context.extra;
                          return Stack(
                            children: [
                              SudokuGridWidget(
                                state: context.read<SudokuCubit>().state,
                                onCellTap: (row, col) =>
                                    context.read<SudokuCubit>().selectCell(row, col),
                              ),
                              if (isPaused)
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                                    child: BackdropFilter(
                                      filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                      child: Container(
                                        color: extra.cardBackgroundColor!.withValues(
                                          alpha: 0.7,
                                        ),
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
                        },
                      ),
                      SizedBox(height: AppSpacing.space2Xl),
                      // Scoped to only the fields the number pad needs.
                      BlocSelector<SudokuCubit, SudokuState, _NumberPadSlice>(
                        selector: (state) =>
                            (state.mode, state.canUndo, state.autoCandidateMode, state.values),
                        builder: (context, pad) {
                          final (mode, canUndo, autoCandidateMode, values) = pad;
                          return SudokuNumberPadWidget(
                            mode: mode,
                            canUndo: canUndo,
                            autoCandidateMode: autoCandidateMode,
                            values: values,
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
                          );
                        },
                      ),
                      // Scoped to only `status` — unaffected by moves/timer.
                      BlocSelector<SudokuCubit, SudokuState, SudokuStatus>(
                        selector: (state) => state.status,
                        builder: (context, status) {
                          if (status == SudokuStatus.won) {
                            return Column(
                              children: [
                                SizedBox(height: AppSpacing.space2Xl),
                                Text(
                                  AppLocalizations.of(context)!.sudokuWonMessage,
                                  style: ThemeTextStyles.titleMedium(context),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: AppSpacing.spaceMd),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => context.go(AppRoutes.home),
                                        child: Text(AppLocalizations.of(context)!.sudokuDoneButton),
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
                                        child: Text(AppLocalizations.of(context)!.sudokuPlayAgainButton),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                          if (status == SudokuStatus.lost) {
                            return Column(
                              children: [
                                SizedBox(height: AppSpacing.space2Xl),
                                Text(
                                  AppLocalizations.of(context)!.sudokuLostMessage,
                                  style: ThemeTextStyles.titleMedium(context),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: AppSpacing.spaceMd),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => context.go(AppRoutes.home),
                                        child: Text(AppLocalizations.of(context)!.sudokuDoneButton),
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
                                        child: Text(AppLocalizations.of(context)!.sudokuTryAgainButton),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      SizedBox(height: AppSpacing.spaceXl),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
