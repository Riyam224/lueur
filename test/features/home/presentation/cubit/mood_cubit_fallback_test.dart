import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/core/journal/journal_refresh_signal.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/home/domain/repositories/mood_repository.dart';
import 'package:lueur/features/home/presentation/cubit/mood_cubit.dart';
import 'package:lueur/features/home/presentation/cubit/mood_state.dart';

MoodEntryEntity _entry(int id, {bool isFallback = false}) => MoodEntryEntity(
      id: id,
      userId: 'uid',
      emoji: '🌱',
      thoughts: 't$id',
      aiResponse: 'reply',
      createdAt: DateTime(2026),
      isFallback: isFallback,
    );

class _FakeRepository implements MoodRepository {
  _FakeRepository(this.generated);

  final MoodEntryEntity generated;

  @override
  Future<Either<Failure, MoodEntryEntity>> generateResponse({
    required String emoji,
    required String thoughts,
  }) async =>
      Right(generated);

  @override
  Future<Either<Failure, List<MoodEntryEntity>>> getHistory() async =>
      Right([_entry(1)]);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

void main() {
  test('a fallback reply is shown but never added to the cached entries',
      () async {
    final signal = JournalRefreshSignal();
    final cubit = MoodCubit(
      _FakeRepository(_entry(-9, isFallback: true)),
      signal,
    );
    await cubit.getHistory();

    await cubit.generateResponse(emoji: '🌱', thoughts: 'hi');

    final state = cubit.state as MoodHistorySuccess;
    expect(state.justGenerated?.isFallback, isTrue);
    expect(state.entries.map((e) => e.id), [1]);
    expect(signal.state, 0, reason: 'the Journal must not be refreshed');
    await cubit.close();
  });

  test('a later history reload does not contain the fallback reply', () async {
    final cubit = MoodCubit(
      _FakeRepository(_entry(-9, isFallback: true)),
      JournalRefreshSignal(),
    );
    await cubit.generateResponse(emoji: '🌱', thoughts: 'hi');
    await cubit.getHistory();

    final state = cubit.state as MoodHistorySuccess;
    expect(state.entries.any((e) => e.isFallback), isFalse);
    await cubit.close();
  });

  test('a normal reply is prepended and refreshes the Journal', () async {
    final signal = JournalRefreshSignal();
    final cubit = MoodCubit(_FakeRepository(_entry(5)), signal);
    await cubit.getHistory();

    await cubit.generateResponse(emoji: '🌱', thoughts: 'hi');

    final state = cubit.state as MoodHistorySuccess;
    expect(state.entries.map((e) => e.id), [5, 1]);
    expect(signal.state, 1);
    await cubit.close();
  });
}
