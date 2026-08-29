import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/core/journal/journal_refresh_signal.dart';
import 'package:lueur/core/styling/app_theme.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/home/domain/repositories/mood_repository.dart';
import 'package:lueur/features/home/domain/usecases/log_activity_usecase.dart';
import 'package:lueur/features/sudoku/domain/entities/sudoku_result_entity.dart';
import 'package:lueur/features/sudoku/domain/repositories/sudoku_results_repository.dart';
import 'package:lueur/features/sudoku/domain/usecases/generate_sudoku_puzzle_usecase.dart';
import 'package:lueur/features/sudoku/domain/usecases/save_sudoku_result_usecase.dart';
import 'package:lueur/features/sudoku/domain/usecases/validate_sudoku_move_usecase.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_cubit.dart';
import 'package:lueur/features/sudoku/presentation/widgets/sudoku_outcome_dialog.dart';
import 'package:lueur/l10n/app_localizations.dart';

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
  @override
  Future<Either<Failure, MoodEntryEntity>> logActivity({
    required String entryType,
    required Map<String, dynamic> payload,
  }) async {
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
  testWidgets('tapping New Game in the outcome dialog starts a fresh puzzle',
      (tester) async {
    final cubit = SudokuCubit(
      // Plain synchronous fake — reuses the real (pure, fast) generator
      // directly rather than the isolate-dispatching async usecase, so
      // this test never spawns a real isolate.
      () async => GenerateSudokuPuzzleUseCase()(),
      ValidateSudokuMoveUseCase(),
      SaveSudokuResultUseCase(_FakeSudokuResultsRepository()),
      LogActivityUseCase(_FakeMoodRepository()),
      JournalRefreshSignal(),
    );
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => BlocProvider.value(
            value: cubit,
            child: Scaffold(
              body: Center(
                child: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () => showSudokuOutcomeDialog(
                      context,
                      variant: SudokuOutcomeVariant.success,
                    ),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(body: Text('HOME')),
        ),
      ],
    );

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) => MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await cubit.start();
    await tester.pump();

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(Scaffold).last),
    )!;

    expect(find.text(l10n.sudokuOutcomeNewGameButton), findsOneWidget);

    final beforeValues = cubit.state.values;

    await tester.tap(find.text(l10n.sudokuOutcomeNewGameButton));
    await tester.pumpAndSettle();

    // Dialog should be gone.
    expect(find.text(l10n.sudokuOutcomeNewGameButton), findsNothing);

    // A fresh game should have started.
    expect(cubit.state.status.toString(), contains('playing'));
    expect(cubit.state.values, isNot(equals(beforeValues)));

    await cubit.close();
  });
}
