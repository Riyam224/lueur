import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:lueur/features/chat/domain/entities/chat_message.dart';
import 'package:lueur/features/chat/domain/repositories/chat_repository.dart';
import 'package:lueur/features/chat/presentation/cubit/chat_state.dart';

const int _sendFailedMessageCount = 5;

String _randomSendFailedSentinel() =>
    '${ChatMessage.sendFailedSentinelPrefix}${Random().nextInt(_sendFailedMessageCount)}';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository repository;
  final String userId;
  final Logger _logger = Logger();

  ChatCubit({
    required this.repository,
    required this.userId,
    List<ChatMessage> initialMessages = const [],
  }) : super(ChatState(messages: initialMessages));

  Future<void> sendMessage({
    required String emoji,
    required String thoughts,
  }) async {
    if (state.sessionEnded) return;

    final userMessage = ChatMessage(role: 'user', content: thoughts);
    final updatedMessages = [...state.messages, userMessage];

    emit(state.copyWith(
      status: ChatStatus.loading,
      messages: updatedMessages,
    ),);

    try {
      // History excludes the last user message — the API adds it via the
      // `thoughts` field. Only the last 10 turns are sent, matching the
      // backend's own window and keeping the payload from growing unbounded.
      final fullHistory = updatedMessages.sublist(0, updatedMessages.length - 1);
      final history = fullHistory.length > 10
          ? fullHistory.sublist(fullHistory.length - 10)
          : fullHistory;

      final reply = await repository.sendMessage(
        userId: userId,
        emoji: emoji,
        thoughts: thoughts,
        history: history,
      );
      if (isClosed) return;

      final sessionEnded = reply.contains('[SESSION_END]');
      final cleanReply = reply.replaceAll('[SESSION_END]', '').trim();

      final lunaMessage = ChatMessage(
        role: 'assistant',
        content: cleanReply,
      );

      emit(state.copyWith(
        status: ChatStatus.success,
        messages: [...updatedMessages, lunaMessage],
        sessionEnded: sessionEnded,
      ),);
    } catch (e) {
      if (isClosed) return;
      _logger.e('ChatCubit.sendMessage failed', error: e);
      // Show the fallback as a normal Luna chat bubble, not a system
      // error banner — keeps the "texting a friend" feel intact even
      // when a request fails or gets throttled.
      final fallbackMessage = ChatMessage(
        role: 'assistant',
        content: _randomSendFailedSentinel(),
      );
      emit(state.copyWith(
        status: ChatStatus.success,
        messages: [...updatedMessages, fallbackMessage],
      ),);
    }
  }

  void resetSession() => emit(const ChatState());
}
