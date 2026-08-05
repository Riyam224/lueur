class ChatMessage {
  final String role;
  final String content;

  const ChatMessage({
    required this.role,
    required this.content,
  });

  /// Marks [content] as a send-failure filler line picked by `ChatCubit`,
  /// which has no `BuildContext` to resolve a localized string itself.
  /// The presentation layer (`chat_screen.dart`) resolves the sentinel to
  /// the matching `AppLocalizations.chatSendFailedMessagesN` string at
  /// render time, where a `BuildContext` is available.
  static const String sendFailedSentinelPrefix = 'chat_send_failed:';

  bool get isSendFailedSentinel => content.startsWith(sendFailedSentinelPrefix);

  int get sendFailedSentinelIndex =>
      int.parse(content.substring(sendFailedSentinelPrefix.length));
}
