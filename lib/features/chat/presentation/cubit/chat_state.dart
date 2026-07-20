// lib/features/chat/presentation/cubit/chat_state.dart

import 'package:lueur/features/chat/domain/entities/chat_message.dart';

enum ChatStatus { initial, loading, success, error, sessionEnded }

class ChatState {
  final ChatStatus status;
  final List<ChatMessage> messages;
  final String? error;
  final bool sessionEnded;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.error,
    this.sessionEnded = false,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessage>? messages,
    String? error,
    bool? sessionEnded,
  }) =>
      ChatState(
        status: status ?? this.status,
        messages: messages ?? this.messages,
        error: error ?? this.error,
        sessionEnded: sessionEnded ?? this.sessionEnded,
      );
}
