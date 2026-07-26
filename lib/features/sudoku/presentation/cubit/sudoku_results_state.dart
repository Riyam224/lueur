import 'package:equatable/equatable.dart';
import 'package:lueur/features/sudoku/domain/entities/sudoku_result_entity.dart';

abstract class SudokuResultsState extends Equatable {
  const SudokuResultsState();

  @override
  List<Object?> get props => [];
}

class SudokuResultsInitial extends SudokuResultsState {
  const SudokuResultsInitial();
}

class SudokuResultsLoading extends SudokuResultsState {
  const SudokuResultsLoading();
}

class SudokuResultsLoaded extends SudokuResultsState {
  final List<SudokuResultEntity> results;

  const SudokuResultsLoaded(this.results);

  @override
  List<Object?> get props => [results];
}

class SudokuResultsError extends SudokuResultsState {
  final String message;

  const SudokuResultsError(this.message);

  @override
  List<Object?> get props => [message];
}
