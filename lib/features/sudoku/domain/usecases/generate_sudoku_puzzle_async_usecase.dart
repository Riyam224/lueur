import 'dart:isolate';

import 'package:lueur/features/sudoku/domain/entities/sudoku_board_entity.dart';
import 'package:lueur/features/sudoku/domain/usecases/generate_sudoku_puzzle_usecase.dart';

/// Runs [GenerateSudokuPuzzleUseCase] on a background isolate so the
/// backtracking solver never blocks the UI thread. The only place in the
/// codebase aware that puzzle generation is isolate-dispatched — callers
/// just await a [SudokuBoardEntity].
class GenerateSudokuPuzzleAsyncUseCase {
  Future<SudokuBoardEntity> call() {
    return Isolate.run(GenerateSudokuPuzzleUseCase().call);
  }
}
