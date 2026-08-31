import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/chat/domain/entities/chat_message.dart';
import 'package:lueur/features/chat/domain/repositories/chat_repository.dart';
import 'package:lueur/features/chat/domain/usecases/send_chat_message_usecase.dart';
import 'package:lueur/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:lueur/features/chat/presentation/cubit/chat_state.dart';

class _DelayedChatRepository implements ChatRepository {
  final calls = <String>[];
  final reply = Completer<Either<Failure, String>>();

  @override
  Future<Either<Failure, String>> sendMessage({
    required String userId,
    required String emoji,
    required String thoughts,
    required List<ChatMessage> history,
  }) {
    calls.add(thoughts);
    return reply.future;
  }
}

void main() {
  test(
    'a second sendMessage call while one is still in flight is a no-op',
    () async {
      final repository = _DelayedChatRepository();
      final cubit = ChatCubit(
        sendChatMessageUseCase: SendChatMessageUseCase(repository),
        userId: 'user-1',
      );

      final first = cubit.sendMessage(emoji: '🌱', thoughts: 'first message');
      // The first call's emit(loading) runs synchronously up to its first
      // await, so by now state.status is already ChatStatus.loading.
      expect(cubit.state.status, ChatStatus.loading);

      final second =
          cubit.sendMessage(emoji: '🌱', thoughts: 'second message');

      repository.reply.complete(const Right('Luna reply'));
      await first;
      await second;

      expect(repository.calls, ['first message']);
      expect(cubit.state.status, ChatStatus.success);
      expect(
        cubit.state.messages.map((m) => m.content),
        ['first message', 'Luna reply'],
      );
      await cubit.close();
    },
  );

  test('sendMessage succeeds normally when no send is in flight', () async {
    final repository = _DelayedChatRepository();
    final cubit = ChatCubit(
      sendChatMessageUseCase: SendChatMessageUseCase(repository),
      userId: 'user-1',
    );

    final send = cubit.sendMessage(emoji: '🌱', thoughts: 'hello');
    repository.reply.complete(const Right('hi there'));
    await send;

    expect(repository.calls, ['hello']);
    expect(cubit.state.status, ChatStatus.success);
    expect(
      cubit.state.messages.map((m) => m.content),
      ['hello', 'hi there'],
    );
    await cubit.close();
  });
}
