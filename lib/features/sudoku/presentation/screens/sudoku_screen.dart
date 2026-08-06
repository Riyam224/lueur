import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_cubit.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_state.dart';
import 'package:lueur/features/sudoku/presentation/widgets/sudoku_grid_selector_section.dart';
import 'package:lueur/features/sudoku/presentation/widgets/sudoku_header_section.dart';
import 'package:lueur/features/sudoku/presentation/widgets/sudoku_help_dialog.dart';
import 'package:lueur/features/sudoku/presentation/widgets/sudoku_number_pad_section.dart';
import 'package:lueur/features/sudoku/presentation/widgets/sudoku_outcome_dialog.dart';
import 'package:lueur/features/sudoku/presentation/widgets/sudoku_toolbar.dart';

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
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _leave(BuildContext context) {
    context.read<SudokuCubit>().recordUnfinishedIfNeeded();
    context.pop();
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
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == SudokuStatus.won) {
                _confettiController.play();
                unawaited(
                  showSudokuOutcomeDialog(
                    context,
                    variant: SudokuOutcomeVariant.success,
                  ),
                );
              } else if (state.status == SudokuStatus.lost) {
                unawaited(
                  showSudokuOutcomeDialog(
                    context,
                    variant: SudokuOutcomeVariant.fail,
                  ),
                );
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
                      SudokuToolbar(
                        onLeave: () => _leave(context),
                        onHelp: () => showSudokuHelpDialog(context),
                        onNewGame: () => context.read<SudokuCubit>().start(),
                      ),
                      const SudokuHeaderSection(),
                      SizedBox(height: AppSpacing.spaceMd),
                      const SudokuGridSelectorSection(),
                      SizedBox(height: AppSpacing.space2Xl),
                      const SudokuNumberPadSection(),
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
