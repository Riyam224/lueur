import 'dart:math';

import 'package:lueur/features/sudoku/domain/entities/sudoku_board_entity.dart';

/// Generates a simple, easy 4x4 sudoku puzzle. No external solver needed at
/// this size: every valid 4x4 sudoku grid can be reached from one hardcoded
/// base grid via digit relabeling + row/column-band shuffles (symmetries
/// that always preserve row/column/box uniqueness), so a fresh valid grid
/// is produced every time without a real constraint solver.
class GenerateSudokuPuzzleUseCase {
  static const List<List<int>> _baseGrid = [
    [1, 2, 3, 4],
    [3, 4, 1, 2],
    [2, 1, 4, 3],
    [4, 3, 2, 1],
  ];

  /// How many of the 16 cells stay blank for the player to fill in.
  static const int blanksForEasyPuzzle = 7;

  SudokuBoardEntity call({Random? random}) {
    final rng = random ?? Random();
    var grid = _baseGrid.map((row) => List<int>.from(row)).toList();

    grid = _relabelDigits(grid, rng);
    if (rng.nextBool()) grid = _transpose(grid);
    grid = _shuffleRowsWithinBands(grid, rng);
    grid = _shuffleColsWithinBands(grid, rng);
    if (rng.nextBool()) grid = _swapRowBands(grid);
    if (rng.nextBool()) grid = _swapColBands(grid);

    final given = List.generate(
      SudokuBoardEntity.size,
      (_) => List.filled(SudokuBoardEntity.size, true),
    );
    final cellIndices = [
      for (var r = 0; r < SudokuBoardEntity.size; r++)
        for (var c = 0; c < SudokuBoardEntity.size; c++) (r, c),
    ]..shuffle(rng);
    for (final (r, c) in cellIndices.take(blanksForEasyPuzzle)) {
      given[r][c] = false;
    }

    return SudokuBoardEntity(solution: grid, given: given);
  }

  List<List<int>> _relabelDigits(List<List<int>> grid, Random rng) {
    final mapping = [1, 2, 3, 4]..shuffle(rng);
    return grid
        .map((row) => row.map((v) => mapping[v - 1]).toList())
        .toList();
  }

  List<List<int>> _transpose(List<List<int>> grid) {
    return List.generate(
      SudokuBoardEntity.size,
      (r) => List.generate(SudokuBoardEntity.size, (c) => grid[c][r]),
    );
  }

  List<List<int>> _shuffleRowsWithinBands(List<List<int>> grid, Random rng) {
    final result = grid.map((row) => List<int>.from(row)).toList();
    for (final band in [0, 2]) {
      if (rng.nextBool()) {
        final tmp = result[band];
        result[band] = result[band + 1];
        result[band + 1] = tmp;
      }
    }
    return result;
  }

  List<List<int>> _shuffleColsWithinBands(List<List<int>> grid, Random rng) {
    final result = grid.map((row) => List<int>.from(row)).toList();
    for (final band in [0, 2]) {
      if (rng.nextBool()) {
        for (final row in result) {
          final tmp = row[band];
          row[band] = row[band + 1];
          row[band + 1] = tmp;
        }
      }
    }
    return result;
  }

  List<List<int>> _swapRowBands(List<List<int>> grid) {
    return [grid[2], grid[3], grid[0], grid[1]];
  }

  List<List<int>> _swapColBands(List<List<int>> grid) {
    return grid
        .map((row) => [row[2], row[3], row[0], row[1]])
        .toList();
  }
}
