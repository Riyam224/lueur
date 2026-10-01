import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/chat/chat_reset_signal.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/core/journal/journal_refresh_signal.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/home/domain/repositories/mood_repository.dart';
import 'package:lueur/features/home/presentation/cubit/mood_cubit.dart';
import 'package:lueur/features/home/presentation/cubit/mood_state.dart';

MoodEntryEntity _entry(int id) => MoodEntryEntity(
      id: id,
      userId: 'uid',
      emoji: '🌱',
      thoughts: 't$id',
      aiResponse: 'reply',
      createdAt: DateTime(2026),
    );

class _Repository implements MoodRepository {
  final generate = Completer<Either<Failure, MoodEntryEntity>>();
  Either<Failure, void> deleteAllResult = const Right(null);

  @override
  Future<Either<Failure, MoodEntryEntity>> generateResponse({
    required String emoji,
    required String thoughts,
  }) =>
      generate.future;

  @override
  Future<Either<Failure, void>> deleteAllEntries() async => deleteAllResult;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

void main() {
  late _Repository repository;
  late ChatResetSignal chatSignal;
  late MoodCubit cubit;

  setUp(() {
    repository = _Repository();
    chatSignal = ChatResetSignal();
    cubit = MoodCubit(
      repository,
      JournalRefreshSignal(),
      chatResetSignal: chatSignal,
    );
  });

  tearDown(() async {
    await cubit.close();
    await chatSignal.close();
  });

  test('a successful delete-all tells open chats to forget their messages',
      () async {
    await cubit.deleteAllEntries();

    expect(chatSignal.state, 1);
  });

  test('a failed delete-all leaves open chats alone', () async {
    repository.deleteAllResult = const Left(NetworkFailure('no'));

    await cubit.deleteAllEntries();

    expect(chatSignal.state, 0);
  });

  test('clearing the session (logout, account change) resets open chats', () {
    cubit.clearEntries();

    expect(chatSignal.state, 1);
  });

  test('a reply that arrives after delete-all does not bring an entry back',
      () async {
    final pending = cubit.generateResponse(emoji: '🌱', thoughts: 'hi');
    await cubit.deleteAllEntries();

    repository.generate.complete(Right(_entry(7)));
    await pending;

    final state = cubit.state;
    expect(state, isA<MoodHistorySuccess>());
    expect((state as MoodHistorySuccess).entries, isEmpty);
  });
}
