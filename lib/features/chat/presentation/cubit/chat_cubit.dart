import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
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

  ChatCubit({
    required this.sendChatMessageUseCase,
    required this.userId,
    List<ChatMessage> initialMessages = const [],
  }) : super(ChatState(messages: initialMessages));

  Future<void> sendMessage({
    required String emoji,
    required String thoughts,
  }) async {
    if (state.sessionEnded) return;

    final userMessage =
        ChatMessage(role: ChatMessage.roleUser, content: thoughts);
    final updatedMessages = [...state.messages, userMessage];

    emit(state.copyWith(
      status: ChatStatus.loading,
      messages: updatedMessages,
    ),);

    // History excludes the last user message (the API adds it via `thoughts`)
    // and caps at 10 turns, matching the backend's window.
    final fullHistory = updatedMessages.sublist(0, updatedMessages.length - 1);
    final history = fullHistory.length > 10
        ? fullHistory.sublist(fullHistory.length - 10)
        : fullHistory;

    final result = await sendChatMessageUseCase(
      userId: userId,
      emoji: emoji,
      thoughts: thoughts,
      history: history,
    );
    if (isClosed) return;

    result.fold(
      (failure) {
        _logger.e('ChatCubit.sendMessage failed', error: failure.message);
        // Show the fallback as a normal Luna chat bubble, not an error
        // banner — keeps the "texting a friend" feel intact on failure.
        final fallbackMessage = ChatMessage(
          role: ChatMessage.roleAssistant,
          content: _randomSendFailedSentinel(),
        );
        emit(state.copyWith(
          status: ChatStatus.success,
          messages: [...updatedMessages, fallbackMessage],
        ),);
      },
      (reply) {
        final sessionEnded = reply.contains('[SESSION_END]');
        final cleanReply = reply.replaceAll('[SESSION_END]', '').trim();

        final lunaMessage = ChatMessage(
          role: ChatMessage.roleAssistant,
          content: cleanReply,
        );

        emit(state.copyWith(
          status: ChatStatus.success,
          messages: [...updatedMessages, lunaMessage],
          sessionEnded: sessionEnded,
        ),);
      },
    );
  }

  void resetSession() => emit(const ChatState());
}
