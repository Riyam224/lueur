import 'package:lueur/features/sudoku/domain/entities/sudoku_board_entity.dart';

/// Checks whether placing [value] at ([row], [col]) conflicts with another
/// filled cell in the same row, column, or 2x2 box — used for live "that
/// clashes with another cell" highlighting as the player types.
class ValidateSudokuMoveUseCase {
  bool call(List<List<int>> grid, int row, int col, int value) {
    for (var c = 0; c < SudokuBoardEntity.size; c++) {
      if (c != col && grid[row][c] == value) return false;
    }
    for (var r = 0; r < SudokuBoardEntity.size; r++) {
      if (r != row && grid[r][col] == value) return false;
    }

    final boxRow = (row ~/ SudokuBoardEntity.boxSize) * SudokuBoardEntity.boxSize;
    final boxCol = (col ~/ SudokuBoardEntity.boxSize) * SudokuBoardEntity.boxSize;
    for (var r = boxRow; r < boxRow + SudokuBoardEntity.boxSize; r++) {
      for (var c = boxCol; c < boxCol + SudokuBoardEntity.boxSize; c++) {
        if ((r != row || c != col) && grid[r][c] == value) return false;
      }
    }
    return true;
  }
}
