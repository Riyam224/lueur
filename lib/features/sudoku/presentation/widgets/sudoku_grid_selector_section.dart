import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_cubit.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_state.dart';
import 'package:lueur/features/sudoku/presentation/widgets/sudoku_grid_section.dart';

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

/// Rebuilds only when a move/selection/pause changes the grid — not on
/// every timer tick or mistakes-counter change.
class SudokuGridSelectorSection extends StatelessWidget {
  const SudokuGridSelectorSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SudokuCubit, SudokuState, _GridSlice>(
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
        return SudokuGridSection(
          isPaused: isPaused,
          onCellTap: (row, col) =>
              context.read<SudokuCubit>().selectCell(row, col),
        );
      },
    );
  }
}
