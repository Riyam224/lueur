import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/sudoku/domain/entities/sudoku_result_entity.dart';
import 'package:lueur/features/sudoku/domain/repositories/sudoku_results_repository.dart';

class SaveSudokuResultUseCase {
  final SudokuResultsRepository _repository;

  SaveSudokuResultUseCase(this._repository);

  Future<Either<Failure, SudokuResultEntity>> call({
    required bool won,
    required int mistakes,
    required int durationSeconds,
  }) {
    return _repository.saveResult(
      won: won,
      mistakes: mistakes,
      durationSeconds: durationSeconds,
    );
  }
}
