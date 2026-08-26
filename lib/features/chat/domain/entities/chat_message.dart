class ChatMessage {
  final String role;
  final String content;

  const ChatMessage({
    required this.role,
    required this.content,
  });

  /// Sentinel for a send-failure line: `ChatCubit` has no `BuildContext` to
  /// localize it, so `chat_screen.dart` resolves it at render time instead.
  static const String sendFailedSentinelPrefix = 'chat_send_failed:';

  bool get isSendFailedSentinel => content.startsWith(sendFailedSentinelPrefix);

  int get sendFailedSentinelIndex =>
      int.parse(content.substring(sendFailedSentinelPrefix.length));
}
