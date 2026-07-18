// lib/features/chat/presentation/cubit/chat_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur_app/features/chat/domain/entities/chat_message.dart';
import 'package:lueur_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:lueur_app/features/chat/presentation/cubit/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository repository;
  final String userId;

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
      final history = updatedMessages.sublist(0, updatedMessages.length - 1);

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
      emit(state.copyWith(
        status: ChatStatus.error,
        error: 'Luna is taking a little break 🌿',
      ),);
    }
  }

  void resetSession() => emit(const ChatState());
}
