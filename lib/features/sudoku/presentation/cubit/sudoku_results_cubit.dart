import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/features/sudoku/domain/entities/sudoku_result_entity.dart';
import 'package:lueur/features/sudoku/domain/usecases/delete_sudoku_result_usecase.dart';
import 'package:lueur/features/sudoku/domain/usecases/get_sudoku_results_usecase.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_results_state.dart';

/// Lists and deletes past Sudoku results for the Profile screen — separate
/// from [SudokuCubit], which only drives a single live game.
class SudokuResultsCubit extends Cubit<SudokuResultsState> {
  final GetSudokuResultsUseCase _getResults;
  final DeleteSudokuResultUseCase _deleteResult;

  SudokuResultsCubit(
    this._getResults,
    this._deleteResult,
  ) : super(const SudokuResultsInitial());

  /// Hidden by [hideForDelete] but not yet deleted — kept out of every load
  /// so a silent refresh during the undo window can't bring them back.
  final _pendingDeleteIds = <String>{};

  List<SudokuResultEntity> _visible(List<SudokuResultEntity> results) =>
      results.where((r) => !_pendingDeleteIds.contains(r.id)).toList();

  Future<void> loadResults() async {
    emit(const SudokuResultsLoading());
    final result = await _getResults();
    if (isClosed) return;
    result.fold(
      (failure) => emit(SudokuResultsError(failure.message)),
      (results) => emit(SudokuResultsLoaded(_visible(results))),
    );
  }

  /// Re-reads without a Loading flash once loaded (e.g. Profile becoming
  /// visible again); a failed silent re-read keeps the current list.
  Future<void> refresh() async {
    if (state is SudokuResultsLoading) return;
    if (state is! SudokuResultsLoaded) return loadResults();
    final result = await _getResults();
    if (isClosed) return;
    result.fold(
      (_) {},
      (results) => emit(SudokuResultsLoaded(_visible(results))),
    );
  }

  Future<void> deleteResult(String id) async {
    final result = await _deleteResult(id);
    if (isClosed) return;
    result.fold(
      (failure) => emit(SudokuResultsError(failure.message)),
      (_) => loadResults(),
    );
  }

  /// Removes [id] from the list right away without deleting it, so the
  /// delete can still be undone; follow with [commitDelete] or [undoDelete].
  void hideForDelete(String id) {
    _pendingDeleteIds.add(id);
    final current = state;
    if (current is SudokuResultsLoaded) {
      emit(SudokuResultsLoaded(_visible(current.results)));
    }
  }

  /// Brings a hidden result back — nothing was deleted yet.
  Future<void> undoDelete(String id) async {
    if (!_pendingDeleteIds.remove(id)) return;
    await refresh();
  }

  /// Deletes a hidden result for real once the undo window has passed. Runs
  /// even if this cubit was closed meanwhile (e.g. the user left Profile).
  Future<void> commitDelete(String id) async {
    if (!_pendingDeleteIds.contains(id)) return;
    final result = await _deleteResult(id);
    _pendingDeleteIds.remove(id);
    if (isClosed) return;
    result.fold(
      (failure) => emit(SudokuResultsError(failure.message)),
      (_) {},
    );
  }
}
