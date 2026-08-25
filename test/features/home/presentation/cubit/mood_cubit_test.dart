import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/home/domain/repositories/mood_repository.dart';
import 'package:lueur/features/home/presentation/cubit/mood_cubit.dart';
import 'package:lueur/features/home/presentation/cubit/mood_state.dart';

class _DelayedMoodRepository implements MoodRepository {
  final history = Completer<Either<Failure, List<MoodEntryEntity>>>();

  @override
  Future<Either<Failure, List<MoodEntryEntity>>> getHistory() => history.future;

  @override
  Future<Either<Failure, MoodEntryEntity>> addLocalEntry({
    required String emoji,
    required String thoughts,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> deleteAllEntries() =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> deleteEntry(int id) =>
      throw UnimplementedError();

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
    final cubit = MoodCubit(repository);
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
}
