import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/sudoku/domain/repositories/sudoku_results_repository.dart';

class DeleteSudokuResultUseCase {
  final SudokuResultsRepository _repository;

  DeleteSudokuResultUseCase(this._repository);

  Future<Either<Failure, void>> call(String id) {
    return _repository.deleteResult(id);
  }
}
