/// One undoable sudoku move — the value/candidates a cell held right
/// before the move was applied, so [SudokuCubit.undo] can restore them.
class SudokuMove {
  final int row;
  final int col;
  final int prevValue;
  final Set<int> prevCandidates;

  const SudokuMove(this.row, this.col, this.prevValue, this.prevCandidates);
}
