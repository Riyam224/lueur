import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:lueur/core/chat/chat_reset_signal.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/chat/domain/entities/chat_message.dart';
import 'package:lueur/features/chat/domain/usecases/send_chat_message_usecase.dart';
import 'package:lueur/features/chat/presentation/cubit/chat_state.dart';

const int _sendFailedMessageCount = 5;

String _randomSendFailedSentinel() =>
    '${ChatMessage.sendFailedSentinelPrefix}${Random().nextInt(_sendFailedMessageCount)}';

class ChatCubit extends Cubit<ChatState> {
  final SendChatMessageUseCase sendChatMessageUseCase;
  final String userId;
  final Logger _logger = Logger();
  StreamSubscription<int>? _resetSubscription;
  int _epoch = 0;

  ChatCubit({
    required this.sendChatMessageUseCase,
    required this.userId,
    List<ChatMessage> initialMessages = const [],
    ChatResetSignal? resetSignal,
  }) : super(ChatState(messages: initialMessages)) {
    // Delete-all, logout or an account change: forget every message, and
    // ignore a reply that is still on its way.
    _resetSubscription = resetSignal?.stream.listen((_) {
      _epoch++;
      emit(const ChatState());
    });
  }

  Future<void> sendMessage({
    required String emoji,
    required String thoughts,
  }) async {
    if (state.sessionEnded) return;
    // Guards against a fast double-invoke (e.g. autoSendThoughts racing a
    // manual send) — a second concurrent call would build its message list
    // from a stale snapshot and clobber the first call's result on resolve.
    if (state.status == ChatStatus.loading) return;

    final epoch = _epoch;
    final userMessage =
        ChatMessage(role: ChatMessage.roleUser, content: thoughts);
    final updatedMessages = [...state.messages, userMessage];

    emit(state.copyWith(
      status: ChatStatus.loading,
      messages: updatedMessages,
      offline: false,
      guestBlocked: false,
    ),);

    // History excludes the last user message (the API adds it via `thoughts`);
    // the use case trims it to what the backend accepts.
    final history = updatedMessages.sublist(0, updatedMessages.length - 1);

    final result = await sendChatMessageUseCase(
      userId: userId,
      emoji: emoji,
      thoughts: thoughts,
      history: history,
    );
    if (isClosed || epoch != _epoch) return;

    result.fold(
      (failure) {
        _logger.e('ChatCubit.sendMessage failed', error: failure.message);
        if (failure is GuestSignInRequiredFailure) {
          // No fake Luna reply for a blocked guest — the screen replaces
          // the whole chat UI with a sign-in prompt instead.
          emit(state.copyWith(
            status: ChatStatus.success,
            messages: updatedMessages,
            guestBlocked: true,
          ),);
          return;
        }
        if (failure is NetworkOfflineFailure) {
          // No fake Luna reply when there's no connection at all — just
          // surface the offline snackbar and leave the message sendable again.
          emit(state.copyWith(
            status: ChatStatus.success,
            messages: updatedMessages,
            offline: true,
            guestBlocked: false,
          ),);
          return;
        }
        // Show the fallback as a normal Luna chat bubble, not an error
        // banner — keeps the "texting a friend" feel intact on failure.
        final fallbackMessage = ChatMessage(
          role: ChatMessage.roleAssistant,
          content: _randomSendFailedSentinel(),
        );
        emit(state.copyWith(
          status: ChatStatus.success,
          messages: [...updatedMessages, fallbackMessage],
          offline: false,
          guestBlocked: false,
        ),);
      },
      (reply) {
        // A canned fallback never ends the session — the "saved to your
        // journal" card would be untrue, since nothing was saved.
        final sessionEnded =
            !reply.isFallback && reply.text.contains('[SESSION_END]');
        final cleanReply = reply.text.replaceAll('[SESSION_END]', '').trim();

        final lunaMessage = ChatMessage(
          role: ChatMessage.roleAssistant,
          content: cleanReply,
          isFallback: reply.isFallback,
        );

        emit(state.copyWith(
          status: ChatStatus.success,
          messages: [...updatedMessages, lunaMessage],
          sessionEnded: sessionEnded,
          offline: false,
          guestBlocked: false,
        ),);
      },
    );
  }

  void resetSession() => emit(const ChatState());

  @override
  Future<void> close() async {
    await _resetSubscription?.cancel();
    return super.close();
  }
}
