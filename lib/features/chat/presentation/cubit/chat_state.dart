import 'package:lueur/features/chat/domain/entities/chat_message.dart';

enum ChatStatus { initial, loading, success, error, sessionEnded }

class ChatState {
  final ChatStatus status;
  final List<ChatMessage> messages;
  final String? error;
  final bool sessionEnded;

  /// One-shot signal that the last send failed because the device is
  /// offline — the screen shows a friendly snackbar for this and then it's
  /// explicitly reset on every subsequent emit, never carried forward.
  final bool offline;

  /// True when a guest tried to talk with Luna — the screen shows a warm
  /// sign-in prompt in place of the chat UI instead of a fake Luna reply.
  final bool guestBlocked;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.error,
    this.sessionEnded = false,
    this.offline = false,
    this.guestBlocked = false,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessage>? messages,
    String? error,
    bool? sessionEnded,
    bool? offline,
    bool? guestBlocked,
  }) =>
      ChatState(
        status: status ?? this.status,
        messages: messages ?? this.messages,
        error: error ?? this.error,
        sessionEnded: sessionEnded ?? this.sessionEnded,
        offline: offline ?? this.offline,
        guestBlocked: guestBlocked ?? this.guestBlocked,
      );
}
