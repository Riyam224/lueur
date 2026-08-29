import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/core/journal/journal_refresh_signal.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/home/domain/repositories/mood_repository.dart';
import 'package:lueur/features/journal/domain/usecases/delete_journal_entry_usecase.dart';
import 'package:lueur/features/journal/domain/usecases/get_journal_entries_usecase.dart';
import 'package:lueur/features/journal/domain/usecases/set_journal_card_color_usecase.dart';
import 'package:lueur/features/journal/domain/usecases/toggle_journal_pin_usecase.dart';
import 'package:lueur/features/journal/presentation/cubit/journal_grid_cubit.dart';
import 'package:lueur/features/journal/presentation/cubit/journal_grid_state.dart';

/// Counts [getHistory] calls so the test can prove a refetch happened,
/// without caring about the returned entries themselves.
class _CountingMoodRepository implements MoodRepository {
  int getHistoryCallCount = 0;

  @override
  Future<Either<Failure, List<MoodEntryEntity>>> getHistory() async {
    getHistoryCallCount++;
    return const Right([]);
  }

  @override
  Never noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  testWidgets(
    'bumping JournalRefreshSignal triggers JournalGridCubit.loadEntries, '
    'mirroring the BlocListener wiring in JournalGridScreen/TimelineScreen',
    (tester) async {
      final repo = _CountingMoodRepository();
      final journalGridCubit = JournalGridCubit(
        getEntriesUseCase: GetJournalEntriesUseCase(repo),
        setCardColorUseCase: SetJournalCardColorUseCase(repo),
        togglePinUseCase: ToggleJournalPinUseCase(repo),
        deleteEntryUseCase: DeleteJournalEntryUseCase(repo),
      );
      final refreshSignal = JournalRefreshSignal();

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: journalGridCubit..loadEntries()),
              BlocProvider.value(value: refreshSignal),
            ],
            child: BlocListener<JournalRefreshSignal, int>(
              listener: (context, state) {
                context.read<JournalGridCubit>().loadEntries();
              },
              child: BlocBuilder<JournalGridCubit, JournalGridState>(
                builder: (context, state) => const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(repo.getHistoryCallCount, 1);

      // Simulate an activity (breathing/sudoku/drawing) or mood-chat write
      // completing successfully and bumping the shared signal.
      refreshSignal.bump();
      await tester.pumpAndSettle();

      expect(repo.getHistoryCallCount, 2);

      await journalGridCubit.close();
      await refreshSignal.close();
    },
  );
}
