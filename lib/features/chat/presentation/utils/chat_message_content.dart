import 'package:flutter/widgets.dart';
import 'package:lueur/features/chat/domain/entities/chat_message.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Resolves a chat message's displayed text, mapping `ChatCubit`'s
/// send-failure sentinel to its localized string, where [BuildContext] is available.
String resolveChatMessageContent(BuildContext context, ChatMessage message) {
  if (!message.isSendFailedSentinel) return message.content;
  final l10n = AppLocalizations.of(context)!;
  return switch (message.sendFailedSentinelIndex) {
    0 => l10n.chatSendFailedMessages0,
    1 => l10n.chatSendFailedMessages1,
    2 => l10n.chatSendFailedMessages2,
    3 => l10n.chatSendFailedMessages3,
    _ => l10n.chatSendFailedMessages4,
  };
}
