import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_cubit.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_state.dart';
import 'package:lueur/features/sudoku/presentation/widgets/sudoku_number_pad_widget.dart';

/// Slice of [SudokuState] the number pad needs.
typedef _NumberPadSlice = (
  SudokuInputMode mode,
  bool canUndo,
  bool autoCandidateMode,
  List<List<int>> values,
);

/// Rebuilds only when the input mode, undo availability, auto-candidate
/// toggle, or board values change.
class SudokuNumberPadSection extends StatelessWidget {
  const SudokuNumberPadSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SudokuCubit, SudokuState, _NumberPadSlice>(
      selector: (state) => (
        state.mode,
        state.canUndo,
        state.autoCandidateMode,
        state.values,
      ),
      builder: (context, pad) {
        final (mode, canUndo, autoCandidateMode, values) = pad;
        return SudokuNumberPadWidget(
          mode: mode,
          canUndo: canUndo,
          autoCandidateMode: autoCandidateMode,
          values: values,
          onModeChanged: (mode) => context.read<SudokuCubit>().setMode(mode),
          onUndo: () => context.read<SudokuCubit>().undo(),
          onNumberTap: (n) => context.read<SudokuCubit>().inputNumber(n),
          onClearTap: () => context.read<SudokuCubit>().clearSelectedCell(),
          onAutoCandidateModeChanged: (enabled) =>
              context.read<SudokuCubit>().toggleAutoCandidateMode(enabled),
        );
      },
    );
  }
}
