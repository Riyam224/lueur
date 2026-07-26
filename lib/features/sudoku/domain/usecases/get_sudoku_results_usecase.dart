import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/sudoku/domain/entities/sudoku_result_entity.dart';
import 'package:lueur/features/sudoku/domain/repositories/sudoku_results_repository.dart';

class GetSudokuResultsUseCase {
  final SudokuResultsRepository _repository;

  GetSudokuResultsUseCase(this._repository);

  Future<Either<Failure, List<SudokuResultEntity>>> call() {
    return _repository.getResults();
  }
}
