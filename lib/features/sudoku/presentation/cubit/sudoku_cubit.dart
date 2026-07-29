import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/features/sudoku/domain/entities/sudoku_board_entity.dart';
import 'package:lueur/features/sudoku/domain/usecases/generate_sudoku_puzzle_usecase.dart';
import 'package:lueur/features/sudoku/domain/usecases/save_sudoku_result_usecase.dart';
import 'package:lueur/features/sudoku/domain/usecases/validate_sudoku_move_usecase.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_state.dart';

class _Move {
  final int row;
  final int col;
  final int prevValue;
  final Set<int> prevCandidates;

  const _Move(this.row, this.col, this.prevValue, this.prevCandidates);
}

/// Drives a single live 9x9 sudoku game — board state, notes ("candidates"),
/// undo history, and the pausable timer. Ephemeral by design (like
/// [DrawCubit] for free draw): only the final result is persisted, via
/// [SaveSudokuResultUseCase], never the in-progress board.
class SudokuCubit extends Cubit<SudokuState> {
  /// Three strikes and the round ends — keeps a hard round short and low
  /// stakes rather than letting mistakes pile up indefinitely.
  static const int maxMistakes = 3;

  final GenerateSudokuPuzzleUseCase _generatePuzzle;
  final ValidateSudokuMoveUseCase _validateMove;
  final SaveSudokuResultUseCase _saveResult;

  late List<List<int>> _solution;
  final List<_Move> _history = [];
  Timer? _ticker;
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
          candidates: _emptyCandidateGrid(),
          mode: SudokuInputMode.normal,
          mistakes: 0,
          elapsedSeconds: 0,
          isPaused: false,
          autoCandidateMode: false,
          canUndo: false,
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

  static List<List<Set<int>>> _emptyCandidateGrid() => List.generate(
    SudokuBoardEntity.size,
    (_) => List.generate(SudokuBoardEntity.size, (_) => <int>{}),
  );

  void start() {
    final board = _generatePuzzle();
    _solution = board.solution;
    _resultSaved = false;
    _history.clear();

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
        candidates: _emptyCandidateGrid(),
        mode: SudokuInputMode.normal,
        mistakes: 0,
        elapsedSeconds: 0,
        isPaused: false,
        autoCandidateMode: false,
        canUndo: false,
        status: SudokuStatus.playing,
      ),
    );

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.isPaused || state.status != SudokuStatus.playing) return;
      emit(state.copyWith(elapsedSeconds: state.elapsedSeconds + 1));
    });
  }

  void togglePause() {
    if (state.status != SudokuStatus.playing) return;
    emit(state.copyWith(isPaused: !state.isPaused));
  }

  void setMode(SudokuInputMode mode) {
    emit(state.copyWith(mode: mode));
  }

  void selectCell(int row, int col) {
    if (state.status != SudokuStatus.playing || state.isPaused) return;
    if (state.given[row][col]) return;
    emit(state.copyWith(selectedRow: row, selectedCol: col));
  }

  void toggleAutoCandidateMode(bool enabled) {
    if (!enabled) {
      emit(
        state.copyWith(
          autoCandidateMode: false,
          candidates: _emptyCandidateGrid(),
        ),
      );
      return;
    }

    final candidates = state.candidates
        .map((row) => row.map(Set<int>.from).toList())
        .toList();
    for (var r = 0; r < SudokuBoardEntity.size; r++) {
      for (var c = 0; c < SudokuBoardEntity.size; c++) {
        if (state.values[r][c] != 0) continue;
        candidates[r][c] = {
          for (var v = 1; v <= SudokuBoardEntity.size; v++)
            if (_validateMove(state.values, r, c, v)) v,
        };
      }
    }
    emit(state.copyWith(autoCandidateMode: true, candidates: candidates));
  }

  void inputNumber(int value) {
    if (state.status != SudokuStatus.playing || state.isPaused) return;
    final row = state.selectedRow;
    final col = state.selectedCol;
    if (row == null || col == null) return;

    _history.add(
      _Move(row, col, state.values[row][col], Set.from(state.candidates[row][col])),
    );

    if (state.mode == SudokuInputMode.candidate) {
      if (state.values[row][col] != 0) return;
      final candidates = state.candidates
          .map((r) => r.map(Set<int>.from).toList())
          .toList();
      final cell = candidates[row][col];
      if (!cell.remove(value)) cell.add(value);
      emit(state.copyWith(candidates: candidates, canUndo: true));
      return;
    }

    final values = state.values.map(List<int>.from).toList();
    values[row][col] = value;
    final candidates = state.candidates
        .map((r) => r.map(Set<int>.from).toList())
        .toList();
    candidates[row][col] = {};

    if (state.autoCandidateMode) {
      _eliminatePeerCandidates(candidates, row, col, value);
    }

    final isWrong = value != _solution[row][col];
    final mistakes = state.mistakes + (isWrong ? 1 : 0);
    final conflicts = _recomputeConflicts(values);
    final isSolved =
        values.every((r) => r.every((v) => v != 0)) &&
        conflicts.every((r) => r.every((flag) => !flag));
    final isOutOfTries = !isSolved && mistakes >= maxMistakes;

    if (isSolved) _saveOnce(won: true, mistakes: mistakes);
    if (isOutOfTries) _saveOnce(won: false, mistakes: mistakes);

    emit(
      state.copyWith(
        values: values,
        candidates: candidates,
        conflicts: conflicts,
        mistakes: mistakes,
        canUndo: true,
        status: isSolved
            ? SudokuStatus.won
            : (isOutOfTries ? SudokuStatus.lost : SudokuStatus.playing),
      ),
    );
  }

  void clearSelectedCell() {
    final row = state.selectedRow;
    final col = state.selectedCol;
    if (row == null || col == null || state.given[row][col]) return;

    _history.add(
      _Move(row, col, state.values[row][col], Set.from(state.candidates[row][col])),
    );

    final values = state.values.map(List<int>.from).toList();
    values[row][col] = 0;
    final candidates = state.candidates
        .map((r) => r.map(Set<int>.from).toList())
        .toList();
    candidates[row][col] = {};

    emit(
      state.copyWith(
        values: values,
        candidates: candidates,
        conflicts: _recomputeConflicts(values),
        canUndo: true,
      ),
    );
  }

  void undo() {
    if (_history.isEmpty) return;
    final move = _history.removeLast();

    final values = state.values.map(List<int>.from).toList();
    values[move.row][move.col] = move.prevValue;
    final candidates = state.candidates
        .map((r) => r.map(Set<int>.from).toList())
        .toList();
    candidates[move.row][move.col] = Set.from(move.prevCandidates);

    emit(
      state.copyWith(
        values: values,
        candidates: candidates,
        conflicts: _recomputeConflicts(values),
        canUndo: _history.isNotEmpty,
      ),
    );
  }

  /// Records this session's outcome exactly once — call when the player
  /// leaves without finishing (a "gave it a go" entry in their history).
  void recordUnfinishedIfNeeded() {
    if (state.status == SudokuStatus.won) return;
    _saveOnce(won: false, mistakes: state.mistakes);
  }

  void _eliminatePeerCandidates(
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

  List<List<bool>> _recomputeConflicts(List<List<int>> values) {
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

  void _saveOnce({required bool won, required int mistakes}) {
    if (_resultSaved) return;
    _resultSaved = true;
    _saveResult(won: won, mistakes: mistakes, durationSeconds: state.elapsedSeconds);
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
