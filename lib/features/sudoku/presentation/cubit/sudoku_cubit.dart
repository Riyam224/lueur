import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:lueur/features/sudoku/domain/entities/sudoku_board_entity.dart';
import 'package:lueur/features/sudoku/domain/usecases/save_sudoku_result_usecase.dart';
import 'package:lueur/features/sudoku/domain/usecases/validate_sudoku_move_usecase.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_state.dart';
import 'package:lueur/features/sudoku/presentation/models/sudoku_move.dart';
import 'package:lueur/features/sudoku/presentation/utils/sudoku_grid_factory.dart';
import 'package:lueur/features/sudoku/presentation/utils/sudoku_grid_ops.dart';

/// Drives a single live 9x9 sudoku game — board state, notes ("candidates"),
/// undo history, and the pausable timer. Ephemeral by design (like
/// [DrawCubit] for free draw): only the final result is persisted, via
/// [SaveSudokuResultUseCase], never the in-progress board.
class SudokuCubit extends Cubit<SudokuState> {
  /// Three strikes and the round ends — keeps a hard round short and low
  /// stakes rather than letting mistakes pile up indefinitely.
  static const int maxMistakes = 3;

  final Future<SudokuBoardEntity> Function() _generatePuzzle;
  final SaveSudokuResultUseCase _saveResult;
  final SudokuGridOps _gridOps;
  final Logger _logger = Logger();

  late List<List<int>> _solution;
  final List<SudokuMove> _history = [];
  Timer? _ticker;
  bool _resultSaved = false;

  SudokuCubit(
    this._generatePuzzle,
    ValidateSudokuMoveUseCase validateMove,
    this._saveResult,
  )   : _gridOps = SudokuGridOps(validateMove),
        super(SudokuGridFactory.freshState());

  Future<void> start() async {
    if (isClosed) return;
    _ticker?.cancel();
    emit(SudokuGridFactory.freshState(isGenerating: true));

    final board = await _generatePuzzle();
    if (isClosed) return;

    _solution = board.solution;
    _resultSaved = false;
    _history.clear();

    emit(
      SudokuGridFactory.freshState(
        values: initialValuesFor(board),
        given: board.given,
      ),
    );

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
          candidates: SudokuGridFactory.emptyCandidateGrid(),
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        autoCandidateMode: true,
        candidates: _gridOps.computeAllCandidates(state.values),
      ),
    );
  }

  void _recordMove(int row, int col) {
    _history.add(
      SudokuMove(
        row,
        col,
        state.values[row][col],
        Set.from(state.candidates[row][col]),
      ),
    );
  }

  void inputNumber(int value) {
    if (state.status != SudokuStatus.playing || state.isPaused) return;
    final row = state.selectedRow;
    final col = state.selectedCol;
    if (row == null || col == null) return;

    _recordMove(row, col);

    if (state.mode == SudokuInputMode.candidate) {
      if (state.values[row][col] == 0) {
        emit(
          state.copyWith(
            candidates: _gridOps.toggleCandidate(
              state.candidates,
              state.values,
              row,
              col,
              value,
            ),
            canUndo: true,
          ),
        );
      }
      return;
    }

    final result = _gridOps.applyValueEntry(
      values: state.values,
      candidates: state.candidates,
      solution: _solution,
      row: row,
      col: col,
      value: value,
      currentMistakes: state.mistakes,
      autoCandidateMode: state.autoCandidateMode,
      maxMistakes: maxMistakes,
    );

    if (result.isSolved) _saveOnce(won: true, mistakes: result.mistakes);
    if (result.isOutOfTries) _saveOnce(won: false, mistakes: result.mistakes);

    emit(
      state.copyWith(
        values: result.values,
        candidates: result.candidates,
        conflicts: result.conflicts,
        mistakes: result.mistakes,
        canUndo: true,
        status: result.isSolved
            ? SudokuStatus.won
            : (result.isOutOfTries ? SudokuStatus.lost : SudokuStatus.playing),
      ),
    );
  }

  void clearSelectedCell() {
    final row = state.selectedRow;
    final col = state.selectedCol;
    if (row == null || col == null || state.given[row][col]) return;

    _recordMove(row, col);

    final result = _gridOps.clearCell(
      values: state.values,
      candidates: state.candidates,
      row: row,
      col: col,
    );
    emit(
      state.copyWith(
        values: result.values,
        candidates: result.candidates,
        conflicts: result.conflicts,
        canUndo: true,
      ),
    );
  }

  void undo() {
    if (_history.isEmpty) return;
    final move = _history.removeLast();

    final result = _gridOps.applyUndo(
      values: state.values,
      candidates: state.candidates,
      move: move,
    );
    emit(
      state.copyWith(
        values: result.values,
        candidates: result.candidates,
        conflicts: result.conflicts,
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

  void _saveOnce({required bool won, required int mistakes}) {
    if (_resultSaved) return;
    _resultSaved = true;
    unawaited(_persistResult(won: won, mistakes: mistakes));
  }

  /// Persists the round outcome — never blocks the win/loss UI flow. On
  /// failure the result is lost from history, so it's surfaced via a soft
  /// [SudokuState.resultSaveFailed] flag (the underlying error is already
  /// logged by the repository) rather than disrupting the outcome dialog.
  Future<void> _persistResult({
    required bool won,
    required int mistakes,
  }) async {
    final result = await _saveResult(
      won: won,
      mistakes: mistakes,
      durationSeconds: state.elapsedSeconds,
    );
    if (isClosed) return;

    result.fold(
      (failure) {
        _logger.e('SudokuCubit: failed to save result — ${failure.message}');
        emit(state.copyWith(resultSaveFailed: true));
      },
      (_) {},
    );
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
