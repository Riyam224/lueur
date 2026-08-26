import 'dart:math';

import 'package:lueur/features/sudoku/domain/entities/sudoku_board_entity.dart';

/// Generates an "Easy" 9x9 sudoku puzzle with a verified unique solution,
/// pure Dart (no solver package): build a base solved grid, reshuffle it via
/// symmetries that preserve uniqueness, then dig holes — clearing cells only
/// when a backtracking solver confirms the puzzle still has one solution.
class GenerateSudokuPuzzleUseCase {
  /// How many of the 81 cells stay filled for an Easy puzzle.
  static const int easyClueCount = 40;

  SudokuBoardEntity call({Random? random}) {
    final rng = random ?? Random();
    var grid = _baseSolvedGrid();

    grid = _relabelDigits(grid, rng);
    if (rng.nextBool()) grid = _transpose(grid);
    grid = _shuffleRowsWithinBands(grid, rng);
    grid = _shuffleColsWithinBands(grid, rng);
    if (rng.nextBool()) grid = _swapBands(grid, rng, transposed: false);
    if (rng.nextBool()) {
      grid = _swapBands(_transpose(grid), rng, transposed: true);
    }

    final given = _digHoles(grid, rng);
    return SudokuBoardEntity(solution: grid, given: given);
  }

  List<List<int>> _baseSolvedGrid() {
    const n = SudokuBoardEntity.size;
    const box = SudokuBoardEntity.boxSize;
    return List.generate(
      n,
      (r) => List.generate(n, (c) => (box * (r % box) + r ~/ box + c) % n + 1),
    );
  }

  List<List<bool>> _digHoles(List<List<int>> solution, Random rng) {
    const n = SudokuBoardEntity.size;
    final given = List.generate(n, (_) => List.filled(n, true));
    final puzzle = solution.map(List<int>.from).toList();

    var filled = n * n;
    final cells = [
      for (var r = 0; r < n; r++)
        for (var c = 0; c < n; c++) (r, c),
    ]..shuffle(rng);

    for (final (r, c) in cells) {
      if (filled <= easyClueCount) break;

      final backup = puzzle[r][c];
      puzzle[r][c] = 0;
      if (_countSolutions(puzzle, limit: 2) == 1) {
        given[r][c] = false;
        filled--;
      } else {
        puzzle[r][c] = backup;
      }
    }

    return given;
  }

  /// Counts solutions up to [limit] (stops early — we only ever need to
  /// distinguish "exactly one" from "more than one").
  int _countSolutions(List<List<int>> grid, {required int limit}) {
    const n = SudokuBoardEntity.size;
    const box = SudokuBoardEntity.boxSize;
    final board = grid.map(List<int>.from).toList();
    var count = 0;

    bool isSafe(int r, int c, int value) {
      for (var i = 0; i < n; i++) {
        if (board[r][i] == value || board[i][c] == value) return false;
      }
      final boxRow = (r ~/ box) * box;
      final boxCol = (c ~/ box) * box;
      for (var dr = 0; dr < box; dr++) {
        for (var dc = 0; dc < box; dc++) {
          if (board[boxRow + dr][boxCol + dc] == value) return false;
        }
      }
      return true;
    }

    void solve(int index) {
      if (count >= limit) return;
      if (index == n * n) {
        count++;
        return;
      }
      final r = index ~/ n;
      final c = index % n;
      if (board[r][c] != 0) {
        solve(index + 1);
        return;
      }
      for (var value = 1; value <= n; value++) {
        if (isSafe(r, c, value)) {
          board[r][c] = value;
          solve(index + 1);
          board[r][c] = 0;
          if (count >= limit) return;
        }
      }
    }

    solve(0);
    return count;
  }

  List<List<int>> _relabelDigits(List<List<int>> grid, Random rng) {
    final mapping = List.generate(SudokuBoardEntity.size, (i) => i + 1)
      ..shuffle(rng);
    return grid
        .map((row) => row.map((v) => mapping[v - 1]).toList())
        .toList();
  }

  List<List<int>> _transpose(List<List<int>> grid) {
    const n = SudokuBoardEntity.size;
    return List.generate(n, (r) => List.generate(n, (c) => grid[c][r]));
  }

  List<List<int>> _shuffleRowsWithinBands(List<List<int>> grid, Random rng) {
    final result = grid.map(List<int>.from).toList();
    const box = SudokuBoardEntity.boxSize;
    for (var band = 0; band < SudokuBoardEntity.size; band += box) {
      final rows = List.generate(box, (i) => band + i)..shuffle(rng);
      final bandCopy = [for (final r in rows) List<int>.from(result[r])];
      for (var i = 0; i < box; i++) {
        result[band + i] = bandCopy[i];
      }
    }
    return result;
  }

  List<List<int>> _shuffleColsWithinBands(List<List<int>> grid, Random rng) {
    return _transpose(_shuffleRowsWithinBands(_transpose(grid), rng));
  }

  /// Swaps the order of the row bands (top/middle/bottom thirds). When
  /// [transposed] is true, the caller has already transposed the grid so
  /// this effectively swaps column bands instead — result is transposed
  /// back by the caller.
  List<List<int>> _swapBands(
    List<List<int>> grid,
    Random rng, {
    required bool transposed,
  }) {
    const box = SudokuBoardEntity.boxSize;
    final bandOrder = List.generate(SudokuBoardEntity.size ~/ box, (i) => i)
      ..shuffle(rng);
    final result = <List<int>>[];
    for (final band in bandOrder) {
      for (var i = 0; i < box; i++) {
        result.add(grid[band * box + i]);
      }
    }
    return transposed ? _transpose(result) : result;
  }
}
