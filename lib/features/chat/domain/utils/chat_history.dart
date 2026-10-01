import 'package:lueur/core/constants/app_limits.dart';
import 'package:lueur/features/chat/domain/entities/chat_message.dart';

/// The part of [messages] worth sending to the backend as `history`.
///
/// Drops local-only notices (send-failure bubbles), empty messages and any
/// role other than user/assistant, then keeps the most recent turns that fit
/// the backend's limits — so it never has to trim mid-conversation itself.
List<ChatMessage> buildChatHistory(List<ChatMessage> messages) {
  final eligible = messages.where(
    (m) =>
        !m.isLocalNotice &&
        m.content.trim().isNotEmpty &&
        (m.role == ChatMessage.roleUser ||
            m.role == ChatMessage.roleAssistant),
  );

  final recent = eligible.toList();
  final window = recent.length > AppLimits.chatHistoryMaxTurns
      ? recent.sublist(recent.length - AppLimits.chatHistoryMaxTurns)
      : recent;

  final kept = <ChatMessage>[];
  var total = 0;
  for (final message in window.reversed) {
    final content = message.content.length > AppLimits.chatHistoryItemMaxChars
        ? message.content.substring(0, AppLimits.chatHistoryItemMaxChars)
        : message.content;
    if (total + content.length > AppLimits.chatHistoryTotalMaxChars) break;
    total += content.length;
    kept.add(ChatMessage(role: message.role, content: content));
  }
  return kept.reversed.toList();
}
