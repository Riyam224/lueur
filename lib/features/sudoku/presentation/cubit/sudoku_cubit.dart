import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/features/sudoku/domain/entities/sudoku_board_entity.dart';
import 'package:lueur/features/sudoku/domain/usecases/generate_sudoku_puzzle_usecase.dart';
import 'package:lueur/features/sudoku/domain/usecases/save_sudoku_result_usecase.dart';
import 'package:lueur/features/sudoku/domain/usecases/validate_sudoku_move_usecase.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_state.dart';

/// Drives a single live 4x4 sudoku game. Ephemeral by design (like [DrawCubit]
/// for free draw) — only the final win/loss result is persisted, via
/// [SaveSudokuResultUseCase], never the in-progress board.
class SudokuCubit extends Cubit<SudokuState> {
  static const int maxMistakes = 3;

  final GenerateSudokuPuzzleUseCase _generatePuzzle;
  final ValidateSudokuMoveUseCase _validateMove;
  final SaveSudokuResultUseCase _saveResult;

  late List<List<int>> _solution;
  bool _resultSaved = false;

  SudokuCubit(
    this._generatePuzzle,
    this._validateMove,
    this._saveResult,
  ) : super(
        SudokuState(
          values: _emptyGrid(),
          given: _emptyBoolGrid(),
          conflicts: _emptyBoolGrid(),
          mistakes: 0,
          status: SudokuStatus.playing,
        ),
      );

  static List<List<int>> _emptyGrid() => List.generate(
    SudokuBoardEntity.size,
    (_) => List.filled(SudokuBoardEntity.size, 0),
  );

  static List<List<bool>> _emptyBoolGrid() => List.generate(
    SudokuBoardEntity.size,
    (_) => List.filled(SudokuBoardEntity.size, false),
  );

  void start() {
    final board = _generatePuzzle();
    _solution = board.solution;
    _resultSaved = false;

    final values = List.generate(
      SudokuBoardEntity.size,
      (r) => List.generate(
        SudokuBoardEntity.size,
        (c) => board.given[r][c] ? board.solution[r][c] : 0,
      ),
    );

    emit(
      SudokuState(
        values: values,
        given: board.given,
        conflicts: _emptyBoolGrid(),
        mistakes: 0,
        status: SudokuStatus.playing,
      ),
    );
  }

  void selectCell(int row, int col) {
    if (state.status != SudokuStatus.playing) return;
    if (state.given[row][col]) return;
    emit(state.copyWith(selectedRow: row, selectedCol: col));
  }

  void inputNumber(int value) {
    if (state.status != SudokuStatus.playing) return;
    final row = state.selectedRow;
    final col = state.selectedCol;
    if (row == null || col == null) return;

    final values = state.values.map((r) => List<int>.from(r)).toList();
    values[row][col] = value;

    final hasConflict = !_validateMove(values, row, col, value);
    final conflicts = state.conflicts.map((r) => List<bool>.from(r)).toList();
    conflicts[row][col] = hasConflict;

    final isWrong = value != _solution[row][col];
    final mistakes = state.mistakes + (isWrong ? 1 : 0);

    if (mistakes >= maxMistakes) {
      _saveOnce(won: false, mistakes: mistakes);
      emit(
        state.copyWith(
          values: values,
          conflicts: conflicts,
          mistakes: mistakes,
          status: SudokuStatus.lost,
        ),
      );
      return;
    }

    final isComplete = values.every(
      (r) => r.every((v) => v != 0),
    );
    final isSolved = isComplete &&
        List.generate(SudokuBoardEntity.size, (r) => r).every(
          (r) => List.generate(
            SudokuBoardEntity.size,
            (c) => values[r][c] == _solution[r][c],
          ).every((match) => match),
        );

    if (isSolved) {
      _saveOnce(won: true, mistakes: mistakes);
    }

    emit(
      state.copyWith(
        values: values,
        conflicts: conflicts,
        mistakes: mistakes,
        status: isSolved ? SudokuStatus.won : SudokuStatus.playing,
      ),
    );
  }

  void clearSelectedCell() {
    final row = state.selectedRow;
    final col = state.selectedCol;
    if (row == null || col == null || state.given[row][col]) return;

    final values = state.values.map((r) => List<int>.from(r)).toList();
    values[row][col] = 0;
    final conflicts = state.conflicts.map((r) => List<bool>.from(r)).toList();
    conflicts[row][col] = false;

    emit(state.copyWith(values: values, conflicts: conflicts));
  }

  void _saveOnce({required bool won, required int mistakes}) {
    if (_resultSaved) return;
    _resultSaved = true;
    _saveResult(won: won, mistakes: mistakes);
  }
}
