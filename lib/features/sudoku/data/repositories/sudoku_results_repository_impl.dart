import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/sudoku/data/datasources/sudoku_results_local_datasource.dart';
import 'package:lueur/features/sudoku/data/models/sudoku_result_model.dart';
import 'package:lueur/features/sudoku/domain/entities/sudoku_result_entity.dart';
import 'package:lueur/features/sudoku/domain/repositories/sudoku_results_repository.dart';

class SudokuResultsRepositoryImpl implements SudokuResultsRepository {
  final SudokuResultsLocalDatasource _local;
  final FirebaseAuth _firebaseAuth;
  final Logger _logger = Logger();

  SudokuResultsRepositoryImpl(this._local, this._firebaseAuth);

  String get _currentUserId => _firebaseAuth.currentUser?.uid ?? '';

  @override
  Future<Either<Failure, List<SudokuResultEntity>>> getResults() async {
    try {
      final results = _local.getResults(userId: _currentUserId);
      return Right(results.map((r) => r.toEntity()).toList());
    } catch (e) {
      _logger.e('Failed to load sudoku results: $e');
      return const Left(NetworkFailure('Failed to load sudoku results'));
    }
  }

  @override
  Future<Either<Failure, SudokuResultEntity>> saveResult({
    required bool won,
    required int mistakes,
    required int durationSeconds,
  }) async {
    try {
      final result = SudokuResultModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        won: won,
        mistakes: mistakes,
        durationSeconds: durationSeconds,
        completedAt: DateTime.now(),
      );
      await _local.saveResult(result, userId: _currentUserId);
      return Right(result.toEntity());
    } catch (e) {
      _logger.e('Failed to save sudoku result: $e');
      return const Left(NetworkFailure('Failed to save sudoku result'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteResult(String id) async {
    try {
      await _local.deleteResult(id, userId: _currentUserId);
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to delete sudoku result: $e');
      return const Left(NetworkFailure('Failed to delete sudoku result'));
    }
  }
}
