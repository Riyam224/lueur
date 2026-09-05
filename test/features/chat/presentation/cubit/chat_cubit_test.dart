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

class _GuestBlockedChatRepository implements ChatRepository {
  @override
  Future<Either<Failure, String>> sendMessage({
    required String userId,
    required String emoji,
    required String thoughts,
    required List<ChatMessage> history,
  }) async =>
      const Left(GuestSignInRequiredFailure());
}

/// Returns the guest-blocked failure on the first call, then succeeds —
/// simulates a guest signing in mid-session and retrying with the same
/// ChatCubit instance.
class _SignsInAfterFirstCallChatRepository implements ChatRepository {
  var _calls = 0;

  @override
  Future<Either<Failure, String>> sendMessage({
    required String userId,
    required String emoji,
    required String thoughts,
    required List<ChatMessage> history,
  }) async {
    _calls++;
    if (_calls == 1) return const Left(GuestSignInRequiredFailure());
    return const Right('Welcome back.');
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

  test(
      'sendMessage as a guest never fakes a Luna reply and emits guestBlocked',
      () async {
    final repository = _GuestBlockedChatRepository();
    final cubit = ChatCubit(
      sendChatMessageUseCase: SendChatMessageUseCase(repository),
      userId: '',
    );

    await cubit.sendMessage(emoji: '🌱', thoughts: 'Trying Luna');

    expect(cubit.state.guestBlocked, isTrue);
    expect(cubit.state.messages.map((m) => m.content), ['Trying Luna']);
    await cubit.close();
  });

  test('guestBlocked clears once a later sendMessage succeeds', () async {
    final repository = _SignsInAfterFirstCallChatRepository();
    final cubit = ChatCubit(
      sendChatMessageUseCase: SendChatMessageUseCase(repository),
      userId: '',
    );

    await cubit.sendMessage(emoji: '🌱', thoughts: 'Trying Luna');
    expect(cubit.state.guestBlocked, isTrue);

    await cubit.sendMessage(emoji: '🌱', thoughts: 'Hi again');

    expect(cubit.state.guestBlocked, isFalse);
    await cubit.close();
  });
}
