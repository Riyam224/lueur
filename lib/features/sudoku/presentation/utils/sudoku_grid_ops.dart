import 'package:lueur/features/sudoku/domain/entities/sudoku_board_entity.dart';
import 'package:lueur/features/sudoku/domain/usecases/validate_sudoku_move_usecase.dart';
import 'package:lueur/features/sudoku/presentation/models/sudoku_move.dart';

/// Result of applying a real number entry (not a candidate toggle) to the
/// board — everything [SudokuCubit.inputNumber] needs to emit.
typedef SudokuEntryResult = ({
  List<List<int>> values,
  List<List<Set<int>>> candidates,
  List<List<bool>> conflicts,
  int mistakes,
  bool isSolved,
  bool isOutOfTries,
});

/// Result of clearing a cell or undoing a move — everything
/// [SudokuCubit.clearSelectedCell]/[SudokuCubit.undo] need to emit.
typedef SudokuBoardEditResult = ({
  List<List<int>> values,
  List<List<Set<int>>> candidates,
  List<List<bool>> conflicts,
});

/// Pure grid mutation/query helpers used by [SudokuCubit] — kept free of
/// Cubit/state concerns so move-validation is easy to read and test.
class SudokuGridOps {
  const SudokuGridOps(this._validateMove);

  final ValidateSudokuMoveUseCase _validateMove;

  /// Places [value] at the given cell, recomputes conflicts/candidates,
  /// and determines whether the move wins or loses the round.
  SudokuEntryResult applyValueEntry({
    required List<List<int>> values,
    required List<List<Set<int>>> candidates,
    required List<List<int>> solution,
    required int row,
    required int col,
    required int value,
    required int currentMistakes,
    required bool autoCandidateMode,
    required int maxMistakes,
  }) {
    final newValues = values.map(List<int>.from).toList();
    newValues[row][col] = value;
    final newCandidates =
        candidates.map((r) => r.map(Set<int>.from).toList()).toList();
    newCandidates[row][col] = {};

    if (autoCandidateMode) {
      eliminatePeerCandidates(newCandidates, row, col, value);
    }

    final isWrong = value != solution[row][col];
    final mistakes = currentMistakes + (isWrong ? 1 : 0);
    final conflicts = recomputeConflicts(newValues);
    final isSolved = newValues.every((r) => r.every((v) => v != 0)) &&
        conflicts.every((r) => r.every((flag) => !flag));
    final isOutOfTries = !isSolved && mistakes >= maxMistakes;

    return (
      values: newValues,
      candidates: newCandidates,
      conflicts: conflicts,
      mistakes: mistakes,
      isSolved: isSolved,
      isOutOfTries: isOutOfTries,
    );
  }

  /// Toggles [value] in/out of a cell's candidate notes. No-op if the cell
  /// already holds a real value.
  List<List<Set<int>>> toggleCandidate(
    List<List<Set<int>>> candidates,
    List<List<int>> values,
    int row,
    int col,
    int value,
  ) {
    if (values[row][col] != 0) return candidates;
    final newCandidates =
        candidates.map((r) => r.map(Set<int>.from).toList()).toList();
    final cell = newCandidates[row][col];
    if (!cell.remove(value)) cell.add(value);
    return newCandidates;
  }

  /// Clears the value/candidates at a cell (e.g. the "clear" button).
  SudokuBoardEditResult clearCell({
    required List<List<int>> values,
    required List<List<Set<int>>> candidates,
    required int row,
    required int col,
  }) {
    final newValues = values.map(List<int>.from).toList();
    newValues[row][col] = 0;
    final newCandidates =
        candidates.map((r) => r.map(Set<int>.from).toList()).toList();
    newCandidates[row][col] = {};
    return (
      values: newValues,
      candidates: newCandidates,
      conflicts: recomputeConflicts(newValues),
    );
  }

  /// Restores the value/candidates a cell held before [move] was applied.
  SudokuBoardEditResult applyUndo({
    required List<List<int>> values,
    required List<List<Set<int>>> candidates,
    required SudokuMove move,
  }) {
    final newValues = values.map(List<int>.from).toList();
    newValues[move.row][move.col] = move.prevValue;
    final newCandidates =
        candidates.map((r) => r.map(Set<int>.from).toList()).toList();
    newCandidates[move.row][move.col] = Set.from(move.prevCandidates);
    return (
      values: newValues,
      candidates: newCandidates,
      conflicts: recomputeConflicts(newValues),
    );
  }

  /// Removes [value] as a candidate from every peer (row/column/box) of the
  /// given cell — called after a real move in auto-candidate mode.
  void eliminatePeerCandidates(
    List<List<Set<int>>> candidates,
    int row,
    int col,
    int value,
  ) {
    const n = SudokuBoardEntity.size;
    const box = SudokuBoardEntity.boxSize;
    for (var i = 0; i < n; i++) {
      candidates[row][i].remove(value);
      candidates[i][col].remove(value);
    }
    final boxRow = (row ~/ box) * box;
    final boxCol = (col ~/ box) * box;
    for (var r = boxRow; r < boxRow + box; r++) {
      for (var c = boxCol; c < boxCol + box; c++) {
        candidates[r][c].remove(value);
      }
    }
  }

  /// Every value 1–9 that would currently be legal at [row]/[col].
  Set<int> candidatesFor(List<List<int>> values, int row, int col) {
    return {
      for (var v = 1; v <= SudokuBoardEntity.size; v++)
        if (_validateMove(values, row, col, v)) v,
    };
  }

  /// Fills in every empty cell's legal-candidate set — used when
  /// auto-candidate mode is switched on mid-game.
  List<List<Set<int>>> computeAllCandidates(List<List<int>> values) {
    return List.generate(
      SudokuBoardEntity.size,
      (r) => List.generate(
        SudokuBoardEntity.size,
        (c) => values[r][c] == 0 ? candidatesFor(values, r, c) : <int>{},
      ),
    );
  }

  List<List<bool>> recomputeConflicts(List<List<int>> values) {
    const n = SudokuBoardEntity.size;
    return List.generate(
      n,
      (r) => List.generate(n, (c) {
        final value = values[r][c];
        if (value == 0) return false;
        return !_validateMove(values, r, c, value);
      }),
    );
  }
}
