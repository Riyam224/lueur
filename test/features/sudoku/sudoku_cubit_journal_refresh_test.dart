import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/core/journal/journal_refresh_signal.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/home/domain/repositories/mood_repository.dart';
import 'package:lueur/features/home/domain/usecases/log_activity_usecase.dart';
import 'package:lueur/features/sudoku/domain/entities/sudoku_result_entity.dart';
import 'package:lueur/features/sudoku/domain/repositories/sudoku_results_repository.dart';
import 'package:lueur/features/sudoku/domain/usecases/generate_sudoku_puzzle_usecase.dart';
import 'package:lueur/features/sudoku/domain/usecases/save_sudoku_result_usecase.dart';
import 'package:lueur/features/sudoku/domain/usecases/validate_sudoku_move_usecase.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_cubit.dart';

class _FakeSudokuResultsRepository implements SudokuResultsRepository {
  @override
  Future<Either<Failure, SudokuResultEntity>> saveResult({
    required bool won,
    required int mistakes,
    required int durationSeconds,
  }) async {
    return Right(
      SudokuResultEntity(
        id: '1',
        won: won,
        mistakes: mistakes,
        durationSeconds: durationSeconds,
        completedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<Either<Failure, List<SudokuResultEntity>>> getResults() async =>
      const Right([]);

  @override
  Future<Either<Failure, void>> deleteResult(String id) async =>
      const Right(null);
}

class _FakeMoodRepository implements MoodRepository {
  int logActivityCallCount = 0;

  @override
  Future<Either<Failure, MoodEntryEntity>> logActivity({
    required String entryType,
    required Map<String, dynamic> payload,
  }) async {
    logActivityCallCount++;
    return Right(
      MoodEntryEntity(
        id: 1,
        userId: 'test',
        emoji: '',
        thoughts: '',
        aiResponse: '',
        createdAt: DateTime.now(),
        entryType: entryType,
        payload: payload,
      ),
    );
  }

  @override
  Never noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  test(
    'an abandoned (unfinished) sudoku round still logs the activity and '
    'bumps JournalRefreshSignal once the write succeeds — this is the exact '
    'chain SudokuScreen._leave triggers on back navigation',
    () async {
      final moodRepo = _FakeMoodRepository();
      final refreshSignal = JournalRefreshSignal();
      final cubit = SudokuCubit(
        () async => GenerateSudokuPuzzleUseCase()(),
        ValidateSudokuMoveUseCase(),
        SaveSudokuResultUseCase(_FakeSudokuResultsRepository()),
        LogActivityUseCase(moodRepo),
        refreshSignal,
      );

      final bumped = expectLater(refreshSignal.stream, emits(1));

      await cubit.start();
      cubit.recordUnfinishedIfNeeded();

      await bumped;

      expect(moodRepo.logActivityCallCount, 1);
      expect(refreshSignal.state, 1);

      await cubit.close();
      await refreshSignal.close();
    },
  );
}
