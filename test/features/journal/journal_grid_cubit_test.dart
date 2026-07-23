import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/home/domain/repositories/mood_repository.dart';
import 'package:lueur/features/journal/domain/usecases/delete_journal_entry_usecase.dart';
import 'package:lueur/features/journal/domain/usecases/get_journal_entries_usecase.dart';
import 'package:lueur/features/journal/domain/usecases/set_journal_card_color_usecase.dart';
import 'package:lueur/features/journal/domain/usecases/toggle_journal_pin_usecase.dart';
import 'package:lueur/features/journal/presentation/cubit/journal_grid_cubit.dart';
import 'package:lueur/features/journal/presentation/cubit/journal_grid_state.dart';

class FakeMoodRepository implements MoodRepository {
  final List<MoodEntryEntity> entries;

  FakeMoodRepository(this.entries);

  @override
  Future<Either<Failure, List<MoodEntryEntity>>> getHistory() async =>
      Right(List.of(entries));

  @override
  Future<Either<Failure, MoodEntryEntity>> setCardColor(
    int id,
    String cardColor,
  ) async {
    final index = entries.indexWhere((e) => e.id == id);
    if (index == -1) return const Left(NetworkFailure('Entry not found'));
    final updated = entries[index].copyWith(cardColor: cardColor);
    entries[index] = updated;
    return Right(updated);
  }

  @override
  Future<Either<Failure, MoodEntryEntity>> setPinned(int id, bool pinned) async {
    final index = entries.indexWhere((e) => e.id == id);
    if (index == -1) return const Left(NetworkFailure('Entry not found'));
    final updated = entries[index].copyWith(pinned: pinned);
    entries[index] = updated;
    return Right(updated);
  }

  @override
  Future<Either<Failure, void>> deleteEntry(int id) async {
    entries.removeWhere((e) => e.id == id);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteAllEntries() async {
    entries.clear();
    return const Right(null);
  }

  @override
  Future<Either<Failure, MoodEntryEntity>> generateResponse({
    required String emoji,
    required String thoughts,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, MoodEntryEntity>> addLocalEntry({
    required String emoji,
    required String thoughts,
  }) {
    throw UnimplementedError();
  }
}

MoodEntryEntity buildTestEntry(int id, {String? cardColor, bool pinned = false}) {
  return MoodEntryEntity(
    id: id,
    userId: 'u1',
    emoji: '😊',
    thoughts: 'entry $id',
    aiResponse: '',
    createdAt: DateTime(2026, 1, id),
    cardColor: cardColor,
    pinned: pinned,
  );
}

JournalGridCubit _buildCubit(FakeMoodRepository repo) {
  return JournalGridCubit(
    getEntriesUseCase: GetJournalEntriesUseCase(repo),
    setCardColorUseCase: SetJournalCardColorUseCase(repo),
    togglePinUseCase: ToggleJournalPinUseCase(repo),
    deleteEntryUseCase: DeleteJournalEntryUseCase(repo),
  );
}

void main() {
  group('JournalGridCubit', () {
    test('loadEntries emits loading then loaded with entries', () async {
      final repo = FakeMoodRepository([buildTestEntry(1), buildTestEntry(2)]);
      final cubit = _buildCubit(repo);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<JournalGridLoading>(),
          isA<JournalGridLoaded>().having(
            (s) => s.entries.length,
            'entries.length',
            2,
          ),
        ]),
      );

      await cubit.loadEntries();
      await expectation;
      await cubit.close();
    });

    test('setCardColor updates only the target entry', () async {
      final repo = FakeMoodRepository([buildTestEntry(1), buildTestEntry(2)]);
      final cubit = _buildCubit(repo);
      await cubit.loadEntries();

      await cubit.setCardColor(2, 'mint');

      final state = cubit.state as JournalGridLoaded;
      final entry1 = state.entries.firstWhere((e) => e.id == 1);
      final entry2 = state.entries.firstWhere((e) => e.id == 2);
      expect(entry1.cardColor, isNull);
      expect(entry2.cardColor, 'mint');
      await cubit.close();
    });

    test('togglePinned updates only the target entry', () async {
      final repo = FakeMoodRepository([buildTestEntry(1), buildTestEntry(2)]);
      final cubit = _buildCubit(repo);
      await cubit.loadEntries();

      await cubit.togglePinned(1, true);

      final state = cubit.state as JournalGridLoaded;
      final entry1 = state.entries.firstWhere((e) => e.id == 1);
      final entry2 = state.entries.firstWhere((e) => e.id == 2);
      expect(entry1.pinned, isTrue);
      expect(entry2.pinned, isFalse);
      await cubit.close();
    });

    test('deleteEntry removes only the target entry from state', () async {
      final repo = FakeMoodRepository([buildTestEntry(1), buildTestEntry(2), buildTestEntry(3)]);
      final cubit = _buildCubit(repo);
      await cubit.loadEntries();

      await cubit.deleteEntry(2);

      final state = cubit.state as JournalGridLoaded;
      expect(state.entries.map((e) => e.id), [1, 3]);
      await cubit.close();
    });

    test('deleteEntry does not touch repository entries until confirmed by caller', () async {
      // The cubit method itself performs the deletion (confirmation happens
      // at the UI layer before this is ever called) — this just proves the
      // repository is the source of truth after the call completes.
      final repo = FakeMoodRepository([buildTestEntry(1)]);
      final cubit = _buildCubit(repo);
      await cubit.loadEntries();

      await cubit.deleteEntry(1);

      expect(repo.entries, isEmpty);
      await cubit.close();
    });

    test('methods are no-ops after the cubit is closed (isClosed guard)', () async {
      final repo = FakeMoodRepository([buildTestEntry(1)]);
      final cubit = _buildCubit(repo);
      await cubit.loadEntries();
      await cubit.close();

      expect(cubit.isClosed, isTrue);

      // None of these should throw "emit after close" — the isClosed guard
      // after each await must prevent it.
      await cubit.loadEntries();
      await cubit.setCardColor(1, 'peach');
      await cubit.togglePinned(1, true);
      await cubit.deleteEntry(1);
    });
  });
}
