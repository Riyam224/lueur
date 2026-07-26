import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/sudoku/domain/entities/sudoku_result_entity.dart';

abstract class SudokuResultsRepository {
  Future<Either<Failure, List<SudokuResultEntity>>> getResults();
  Future<Either<Failure, SudokuResultEntity>> saveResult({
    required bool won,
    required int mistakes,
    required int durationSeconds,
  });
  Future<Either<Failure, void>> deleteResult(String id);
}
