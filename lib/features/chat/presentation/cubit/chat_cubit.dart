// lib/features/chat/presentation/cubit/chat_cubit.dart

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
    List<ChatMessage> initialMessages = const [], // ← pre-load history
  }) : super(ChatState(messages: initialMessages)); // ← chat opens with context

  Future<void> sendMessage({
    required String emoji,
    required String thoughts,
  }) async {
    if (state.sessionEnded) return;

    // 1 — add user message to UI immediately
    final userMessage = ChatMessage(role: 'user', content: thoughts);
    final updatedMessages = [...state.messages, userMessage];

    emit(state.copyWith(
      status: ChatStatus.loading,
      messages: updatedMessages,
    ),);

    try {
      // 2 — history = everything except the last user message
      // because API adds it via `thoughts` field
      // Only send the last 10 turns — matches the backend's own window,
      // keeps the payload small, and avoids ever-growing token usage.
      final fullHistory = updatedMessages.sublist(0, updatedMessages.length - 1);
      final history = fullHistory.length > 10
          ? fullHistory.sublist(fullHistory.length - 10)
          : fullHistory;

      // 3 — call API with userId + history
      final reply = await repository.sendMessage(
        userId: userId,
        emoji: emoji,
        thoughts: thoughts,
        history: history,
      );

      // 4 — detect session end tag from Luna
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
