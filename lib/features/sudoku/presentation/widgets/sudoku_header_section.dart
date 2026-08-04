import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_cubit.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_state.dart';
import 'package:lueur/features/sudoku/presentation/widgets/sudoku_header_stats.dart';

/// Slice of [SudokuState] the mistakes/timer/pause row needs. Scoping the
/// rebuild to just this record means the ticking timer (`elapsedSeconds`,
/// emitted once per second) no longer forces the 9x9 grid or number pad to
/// rebuild.
typedef _HeaderSlice = (int mistakes, int elapsedSeconds, bool isPaused);

/// Rebuilds only when mistakes/elapsedSeconds/isPaused change.
class SudokuHeaderSection extends StatelessWidget {
  const SudokuHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SudokuCubit, SudokuState, _HeaderSlice>(
      selector: (state) =>
          (state.mistakes, state.elapsedSeconds, state.isPaused),
      builder: (context, header) {
        final (mistakes, elapsedSeconds, isPaused) = header;
        return SudokuHeaderStats(
          mistakes: mistakes,
          elapsedSeconds: elapsedSeconds,
          isPaused: isPaused,
          onTogglePause: () => context.read<SudokuCubit>().togglePause(),
        );
      },
    );
  }
}
