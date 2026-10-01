import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/draw/domain/entities/saved_drawing_entity.dart';
import 'package:lueur/features/draw/domain/usecases/delete_drawing_usecase.dart';
import 'package:lueur/features/draw/domain/usecases/get_saved_drawings_usecase.dart';
import 'package:lueur/features/draw/domain/usecases/save_drawing_usecase.dart';
import 'package:lueur/features/draw/presentation/cubit/saved_drawings_cubit.dart';
import 'package:lueur/features/draw/presentation/cubit/saved_drawings_state.dart';
import 'package:lueur/features/quotes/domain/entities/saved_quote_entity.dart';
import 'package:lueur/features/quotes/domain/usecases/delete_quote_usecase.dart';
import 'package:lueur/features/quotes/domain/usecases/get_saved_quotes_usecase.dart';
import 'package:lueur/features/quotes/domain/usecases/save_quote_usecase.dart';
import 'package:lueur/features/quotes/presentation/cubit/saved_quotes_cubit.dart';
import 'package:lueur/features/quotes/presentation/cubit/saved_quotes_state.dart';
import 'package:lueur/features/sudoku/domain/entities/sudoku_result_entity.dart';
import 'package:lueur/features/sudoku/domain/usecases/delete_sudoku_result_usecase.dart';
import 'package:lueur/features/sudoku/domain/usecases/get_sudoku_results_usecase.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_results_cubit.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_results_state.dart';

import 'profile_test_harness.dart';

final _drawing = SavedDrawingEntity(
  id: 'd1',
  paths: const [],
  createdAt: DateTime(2026, 10, 2),
);
final _result = SudokuResultEntity(
  id: 's1',
  won: true,
  mistakes: 0,
  durationSeconds: 60,
  completedAt: DateTime(2026, 10, 2),
);
final _quote = SavedQuoteEntity(
  id: 'q1',
  text: 'hello',
  savedAt: DateTime(2026, 10, 2),
);

Future<List<S>> _emissionsOf<S>(
  Stream<S> stream,
  Future<void> Function() action,
) async {
  final emitted = <S>[];
  final sub = stream.listen(emitted.add);
  await action();
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  return emitted;
}

void main() {
  group('SavedDrawingsCubit.refresh', () {
    late FakeDrawingsRepository repo;
    late SavedDrawingsCubit cubit;

    setUp(() {
      repo = FakeDrawingsRepository();
      cubit = SavedDrawingsCubit(
        GetSavedDrawingsUseCase(repo),
        SaveDrawingUseCase(repo),
        DeleteDrawingUseCase(repo),
      );
    });

    tearDown(() => cubit.close());

    test('when loaded, emits the new list without a Loading state', () async {
      await cubit.loadDrawings();
      repo.next = Right([_drawing]);

      final emitted = await _emissionsOf(cubit.stream, cubit.refresh);

      expect(emitted, hasLength(1));
      expect((emitted.single as SavedDrawingsLoaded).drawings, [_drawing]);
    });

    test('when loaded, a failed re-read keeps the current list', () async {
      repo.next = Right([_drawing]);
      await cubit.loadDrawings();
      repo.next = const Left(ServerFailure('boom'));

      final emitted = await _emissionsOf(cubit.stream, cubit.refresh);

      expect(emitted, isEmpty);
      expect((cubit.state as SavedDrawingsLoaded).drawings, [_drawing]);
    });

    test('before the first load, falls back to a normal load', () async {
      final emitted = await _emissionsOf(cubit.stream, cubit.refresh);

      expect(emitted.first, isA<SavedDrawingsLoading>());
      expect(emitted.last, isA<SavedDrawingsLoaded>());
    });
  });

  group('SudokuResultsCubit.refresh', () {
    late FakeSudokuRepository repo;
    late SudokuResultsCubit cubit;

    setUp(() {
      repo = FakeSudokuRepository();
      cubit = SudokuResultsCubit(
        GetSudokuResultsUseCase(repo),
        DeleteSudokuResultUseCase(repo),
      );
    });

    tearDown(() => cubit.close());

    test('when loaded, emits the new list without a Loading state', () async {
      await cubit.loadResults();
      repo.next = Right([_result]);

      final emitted = await _emissionsOf(cubit.stream, cubit.refresh);

      expect(emitted, hasLength(1));
      expect((emitted.single as SudokuResultsLoaded).results, [_result]);
    });

    test('when loaded, a failed re-read keeps the current list', () async {
      repo.next = Right([_result]);
      await cubit.loadResults();
      repo.next = const Left(ServerFailure('boom'));

      final emitted = await _emissionsOf(cubit.stream, cubit.refresh);

      expect(emitted, isEmpty);
      expect((cubit.state as SudokuResultsLoaded).results, [_result]);
    });
  });

  group('SavedQuotesCubit.refresh', () {
    late FakeQuotesRepository repo;
    late SavedQuotesCubit cubit;

    setUp(() {
      repo = FakeQuotesRepository();
      cubit = SavedQuotesCubit(
        GetSavedQuotesUseCase(repo),
        SaveQuoteUseCase(repo),
        DeleteQuoteUseCase(repo),
      );
    });

    tearDown(() => cubit.close());

    test('when loaded, emits the new list without a Loading state', () async {
      await cubit.loadQuotes();
      repo.next = Right([_quote]);

      final emitted = await _emissionsOf(cubit.stream, cubit.refresh);

      expect(emitted, hasLength(1));
      expect((emitted.single as SavedQuotesLoaded).quotes, [_quote]);
    });

    test('when loaded, a failed re-read keeps the current list', () async {
      repo.next = Right([_quote]);
      await cubit.loadQuotes();
      repo.next = const Left(ServerFailure('boom'));

      final emitted = await _emissionsOf(cubit.stream, cubit.refresh);

      expect(emitted, isEmpty);
      expect((cubit.state as SavedQuotesLoaded).quotes, [_quote]);
    });
  });
}
