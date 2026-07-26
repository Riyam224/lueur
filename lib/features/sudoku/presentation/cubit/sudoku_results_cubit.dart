import 'package:flutter_bloc/flutter_bloc.dart';
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

  Future<void> loadResults() async {
    emit(const SudokuResultsLoading());
    final result = await _getResults();
    result.fold(
      (failure) => emit(SudokuResultsError(failure.message)),
      (results) => emit(SudokuResultsLoaded(results)),
    );
  }

  Future<void> deleteResult(String id) async {
    final result = await _deleteResult(id);
    result.fold(
      (failure) => emit(SudokuResultsError(failure.message)),
      (_) => loadResults(),
    );
  }
}
