/// Luna's answer to one chat message.
class ChatReply {
  /// The reply text, as the backend sent it.
  final String text;

  /// True when the backend couldn't reach the AI and sent a canned reply.
  /// It is shown, but isn't a real turn of the conversation.
  final bool isFallback;

  const ChatReply(this.text, {this.isFallback = false});
}
