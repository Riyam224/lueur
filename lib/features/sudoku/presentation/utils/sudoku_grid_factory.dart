import 'package:lueur/features/sudoku/domain/entities/sudoku_board_entity.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_state.dart';

/// Starting `values` grid for a freshly generated board — given cells are
/// pre-filled with their solution value, everything else starts empty.
List<List<int>> initialValuesFor(SudokuBoardEntity board) => List.generate(
      SudokuBoardEntity.size,
      (r) => List.generate(
        SudokuBoardEntity.size,
        (c) => board.given[r][c] ? board.solution[r][c] : 0,
      ),
    );

/// Empty-grid constructors shared by [SudokuCubit] for resetting board
/// state between games and when auto-candidate mode is toggled off.
class SudokuGridFactory {
  const SudokuGridFactory._();

  static List<List<int>> emptyGrid() => List.generate(
        SudokuBoardEntity.size,
        (_) => List.filled(SudokuBoardEntity.size, 0),
      );

  static List<List<bool>> emptyBoolGrid() => List.generate(
        SudokuBoardEntity.size,
        (_) => List.filled(SudokuBoardEntity.size, false),
      );

  static List<List<Set<int>>> emptyCandidateGrid() => List.generate(
        SudokuBoardEntity.size,
        (_) => List.generate(SudokuBoardEntity.size, (_) => <int>{}),
      );

  /// A fresh "just started" state — used both for [SudokuCubit]'s initial
  /// state (before any puzzle has been generated) and when a new game
  /// starts (once [values]/[given] are known).
  static SudokuState freshState({
    List<List<int>>? values,
    List<List<bool>>? given,
  }) {
    return SudokuState(
      values: values ?? emptyGrid(),
      given: given ?? emptyBoolGrid(),
      conflicts: emptyBoolGrid(),
      candidates: emptyCandidateGrid(),
      mode: SudokuInputMode.normal,
      mistakes: 0,
      elapsedSeconds: 0,
      isPaused: false,
      autoCandidateMode: false,
      canUndo: false,
      status: SudokuStatus.playing,
    );
  }
}
