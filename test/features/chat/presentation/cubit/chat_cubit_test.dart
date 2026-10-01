import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/chat/chat_reset_signal.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/chat/domain/entities/chat_message.dart';
import 'package:lueur/features/chat/domain/entities/chat_reply.dart';
import 'package:lueur/features/chat/domain/repositories/chat_repository.dart';
import 'package:lueur/features/chat/domain/usecases/send_chat_message_usecase.dart';
import 'package:lueur/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:lueur/features/chat/presentation/cubit/chat_state.dart';

class _DelayedChatRepository implements ChatRepository {
  final calls = <String>[];
  final reply = Completer<Either<Failure, ChatReply>>();

  @override
  Future<Either<Failure, ChatReply>> sendMessage({
    required String userId,
    required String emoji,
    required String thoughts,
    required List<ChatMessage> history,
  }) {
    calls.add(thoughts);
    return reply.future;
  }
}

/// Fails the first call, succeeds afterwards, and records every history it
/// was handed.
class _FailsOnceChatRepository implements ChatRepository {
  final histories = <List<ChatMessage>>[];

  @override
  Future<Either<Failure, ChatReply>> sendMessage({
    required String userId,
    required String emoji,
    required String thoughts,
    required List<ChatMessage> history,
  }) async {
    histories.add(history);
    if (histories.length == 1) return const Left(ServerFailure('boom'));
    return const Right(ChatReply('ok'));
  }
}

/// Answers each call with the next scripted result and records the history.
class _ScriptedChatRepository implements ChatRepository {
  _ScriptedChatRepository(this._results);

  final List<Either<Failure, ChatReply>> _results;
  final histories = <List<ChatMessage>>[];

  @override
  Future<Either<Failure, ChatReply>> sendMessage({
    required String userId,
    required String emoji,
    required String thoughts,
    required List<ChatMessage> history,
  }) async {
    histories.add(history);
    return _results[histories.length - 1];
  }
}

class _GuestBlockedChatRepository implements ChatRepository {
  @override
  Future<Either<Failure, ChatReply>> sendMessage({
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
  Future<Either<Failure, ChatReply>> sendMessage({
    required String userId,
    required String emoji,
    required String thoughts,
    required List<ChatMessage> history,
  }) async {
    _calls++;
    if (_calls == 1) return const Left(GuestSignInRequiredFailure());
    return const Right(ChatReply('Welcome back.'));
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

      repository.reply.complete(const Right(ChatReply('Luna reply')));
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
    repository.reply.complete(const Right(ChatReply('hi there')));
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


  test('a failure bubble is never sent back as history', () async {
    final repository = _FailsOnceChatRepository();
    final cubit = ChatCubit(
      sendChatMessageUseCase: SendChatMessageUseCase(repository),
      userId: 'u',
    );

    await cubit.sendMessage(emoji: '🌱', thoughts: 'first');
    expect(cubit.state.messages.last.isSendFailedSentinel, isTrue);

    await cubit.sendMessage(emoji: '🌱', thoughts: 'second');

    expect(repository.histories.last.map((m) => m.content), ['first']);
    await cubit.close();
  });

  group('a fallback reply', () {
    test('is shown as a Luna bubble but never sent back as history', () async {
      final repository = _ScriptedChatRepository([
        const Right(ChatReply('Luna is resting.', isFallback: true)),
        const Right(ChatReply('ok')),
      ]);
      final cubit = ChatCubit(
        sendChatMessageUseCase: SendChatMessageUseCase(repository),
        userId: 'u',
      );

      await cubit.sendMessage(emoji: '🌱', thoughts: 'first');
      expect(cubit.state.messages.last.content, 'Luna is resting.');
      expect(cubit.state.messages.last.isFallback, isTrue);

      await cubit.sendMessage(emoji: '🌱', thoughts: 'second');

      expect(repository.histories.last.map((m) => m.content), ['first']);
      await cubit.close();
    });

    test('never ends the session, so the "saved to journal" card stays away',
        () async {
      final repository = _ScriptedChatRepository([
        const Right(ChatReply('Luna is resting. [SESSION_END]', isFallback: true)),
      ]);
      final cubit = ChatCubit(
        sendChatMessageUseCase: SendChatMessageUseCase(repository),
        userId: 'u',
      );

      await cubit.sendMessage(emoji: '🌱', thoughts: 'first');

      expect(cubit.state.sessionEnded, isFalse);
      await cubit.close();
    });

    test('a real reply with the end marker still ends the session', () async {
      final repository = _ScriptedChatRepository([
        const Right(ChatReply('Take care. [SESSION_END]')),
      ]);
      final cubit = ChatCubit(
        sendChatMessageUseCase: SendChatMessageUseCase(repository),
        userId: 'u',
      );

      await cubit.sendMessage(emoji: '🌱', thoughts: 'bye');

      expect(cubit.state.sessionEnded, isTrue);
      await cubit.close();
    });
  });

  group('a chat reset (delete-all, logout, account change)', () {
    test('forgets every message and the ended session', () async {
      final signal = ChatResetSignal();
      final repository = _ScriptedChatRepository([
        const Right(ChatReply('Take care. [SESSION_END]')),
      ]);
      final cubit = ChatCubit(
        sendChatMessageUseCase: SendChatMessageUseCase(repository),
        userId: 'u',
        resetSignal: signal,
      );
      await cubit.sendMessage(emoji: '🌱', thoughts: 'bye');
      expect(cubit.state.messages, isNotEmpty);

      signal.bump();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.messages, isEmpty);
      expect(cubit.state.sessionEnded, isFalse);
      await cubit.close();
      await signal.close();
    });

    test('old messages are never sent as history afterwards', () async {
      final signal = ChatResetSignal();
      final repository = _ScriptedChatRepository([
        const Right(ChatReply('first reply')),
        const Right(ChatReply('second reply')),
      ]);
      final cubit = ChatCubit(
        sendChatMessageUseCase: SendChatMessageUseCase(repository),
        userId: 'u',
        resetSignal: signal,
      );
      await cubit.sendMessage(emoji: '🌱', thoughts: 'old private thought');

      signal.bump();
      await Future<void>.delayed(Duration.zero);
      await cubit.sendMessage(emoji: '🌱', thoughts: 'fresh start');

      expect(repository.histories.last, isEmpty);
      await cubit.close();
      await signal.close();
    });

    test('a reply that was still in flight is dropped', () async {
      final signal = ChatResetSignal();
      final repository = _DelayedChatRepository();
      final cubit = ChatCubit(
        sendChatMessageUseCase: SendChatMessageUseCase(repository),
        userId: 'u',
        resetSignal: signal,
      );
      final pending = cubit.sendMessage(emoji: '🌱', thoughts: 'hello');

      signal.bump();
      await Future<void>.delayed(Duration.zero);
      repository.reply.complete(const Right(ChatReply('late reply')));
      await pending;

      expect(cubit.state.messages, isEmpty);
      expect(cubit.state.status, ChatStatus.initial);
      await cubit.close();
      await signal.close();
    });
  });
}
