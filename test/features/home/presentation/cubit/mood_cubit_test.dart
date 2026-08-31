import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/core/journal/journal_refresh_signal.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/home/domain/repositories/mood_repository.dart';
import 'package:lueur/features/home/presentation/cubit/mood_cubit.dart';
import 'package:lueur/features/home/presentation/cubit/mood_state.dart';

class _DelayedMoodRepository implements MoodRepository {
  final history = Completer<Either<Failure, List<MoodEntryEntity>>>();
  Either<Failure, void> deleteEntryResult = const Right(null);
  Either<Failure, void> deleteAllEntriesResult = const Right(null);

  @override
  Future<Either<Failure, List<MoodEntryEntity>>> getHistory() => history.future;

  @override
  Future<Either<Failure, MoodEntryEntity>> addLocalEntry({
    required String emoji,
    required String thoughts,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> deleteAllEntries() async =>
      deleteAllEntriesResult;

  @override
  Future<Either<Failure, void>> deleteEntry(int id) async => deleteEntryResult;

  @override
  Future<Either<Failure, MoodEntryEntity>> generateResponse({
    required String emoji,
    required String thoughts,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, MoodEntryEntity>> setCardColor(
    int id,
    String cardColor,
  ) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, MoodEntryEntity>> setPinned(int id, bool pinned) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, MoodEntryEntity>> logActivity({
    required String entryType,
    required Map<String, dynamic> payload,
  }) =>
      throw UnimplementedError();
}

void main() {
  test('a history request started before session reset cannot restore old data',
      () async {
    final repository = _DelayedMoodRepository();
    final cubit = MoodCubit(repository, JournalRefreshSignal());
    final oldAccountEntry = MoodEntryEntity(
      id: 1,
      userId: 'old-user',
      emoji: '🌱',
      thoughts: 'Private account entry',
      aiResponse: '',
      createdAt: DateTime(2026),
    );

    final load = cubit.getHistory();
    cubit.clearEntries();
    repository.history.complete(Right([oldAccountEntry]));
    await load;

    expect(cubit.state, isA<MoodInitial>());
    await cubit.close();
  });

  test('deleteEntry removes the entry from state when the repository succeeds',
      () async {
    final repository = _DelayedMoodRepository();
    final cubit = MoodCubit(repository, JournalRefreshSignal());
    final entry = MoodEntryEntity(
      id: 1,
      userId: 'user',
      emoji: '🌱',
      thoughts: 'thoughts',
      aiResponse: '',
      createdAt: DateTime(2026),
    );

    final load = cubit.getHistory();
    repository.history.complete(Right([entry]));
    await load;

    repository.deleteEntryResult = const Right(null);
    await cubit.deleteEntry(1);

    final state = cubit.state;
    expect(state, isA<MoodHistorySuccess>());
    expect((state as MoodHistorySuccess).entries, isEmpty);
    await cubit.close();
  });

  test(
      'deleteEntry keeps the entry and emits MoodError when the repository fails',
      () async {
    final repository = _DelayedMoodRepository();
    final cubit = MoodCubit(repository, JournalRefreshSignal());
    final entry = MoodEntryEntity(
      id: 1,
      userId: 'user',
      emoji: '🌱',
      thoughts: 'thoughts',
      aiResponse: '',
      createdAt: DateTime(2026),
    );

    final load = cubit.getHistory();
    repository.history.complete(Right([entry]));
    await load;

    repository.deleteEntryResult =
        const Left(NetworkFailure('Failed to delete entry'));
    await cubit.deleteEntry(1);

    final state = cubit.state;
    expect(state, isA<MoodError>());
    expect((state as MoodError).message, 'Failed to delete entry');
    await cubit.close();
  });

  test(
      'deleteAllEntries clears state when the repository succeeds',
      () async {
    final repository = _DelayedMoodRepository();
    final cubit = MoodCubit(repository, JournalRefreshSignal());
    final entry = MoodEntryEntity(
      id: 1,
      userId: 'user',
      emoji: '🌱',
      thoughts: 'thoughts',
      aiResponse: '',
      createdAt: DateTime(2026),
    );

    final load = cubit.getHistory();
    repository.history.complete(Right([entry]));
    await load;

    repository.deleteAllEntriesResult = const Right(null);
    await cubit.deleteAllEntries();

    final state = cubit.state;
    expect(state, isA<MoodHistorySuccess>());
    expect((state as MoodHistorySuccess).entries, isEmpty);
    await cubit.close();
  });

  test(
      'deleteAllEntries keeps entries and emits MoodError when the repository fails',
      () async {
    final repository = _DelayedMoodRepository();
    final cubit = MoodCubit(repository, JournalRefreshSignal());
    final entry = MoodEntryEntity(
      id: 1,
      userId: 'user',
      emoji: '🌱',
      thoughts: 'thoughts',
      aiResponse: '',
      createdAt: DateTime(2026),
    );

    final load = cubit.getHistory();
    repository.history.complete(Right([entry]));
    await load;

    repository.deleteAllEntriesResult =
        const Left(NetworkFailure('Failed to delete all entries'));
    await cubit.deleteAllEntries();

    final state = cubit.state;
    expect(state, isA<MoodError>());
    expect((state as MoodError).message, 'Failed to delete all entries');
    await cubit.close();
  });
}
