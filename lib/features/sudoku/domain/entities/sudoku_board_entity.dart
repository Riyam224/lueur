/// A generated 9x9 sudoku puzzle: the full [solution] grid plus which
/// cells were pre-filled ([given]) when the puzzle was handed to the player.
class SudokuBoardEntity {
  static const int size = 9;
  static const int boxSize = 3;

  final List<List<int>> solution;
  final List<List<bool>> given;

  const SudokuBoardEntity({required this.solution, required this.given});
}
