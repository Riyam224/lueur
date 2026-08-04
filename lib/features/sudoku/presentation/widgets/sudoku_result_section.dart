import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_cubit.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_state.dart';
import 'package:lueur/features/sudoku/presentation/widgets/sudoku_result_banner.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Rebuilds only when [SudokuState.status] changes — unaffected by
/// moves/timer ticks. Shows nothing until the game is won or lost.
class SudokuResultSection extends StatelessWidget {
  const SudokuResultSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SudokuCubit, SudokuState, SudokuStatus>(
      selector: (state) => state.status,
      builder: (context, status) {
        final l10n = AppLocalizations.of(context)!;
        if (status == SudokuStatus.won) {
          return SudokuResultBanner(
            message: l10n.sudokuWonMessage,
            doneLabel: l10n.sudokuDoneButton,
            primaryLabel: l10n.sudokuPlayAgainButton,
            onDone: () => context.go(AppRoutes.home),
            onPrimary: () => context.read<SudokuCubit>().start(),
          );
        }
        if (status == SudokuStatus.lost) {
          return SudokuResultBanner(
            message: l10n.sudokuLostMessage,
            doneLabel: l10n.sudokuDoneButton,
            primaryLabel: l10n.sudokuTryAgainButton,
            onDone: () => context.go(AppRoutes.home),
            onPrimary: () => context.read<SudokuCubit>().start(),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
