/// Size limits shared between the chat UI and the code that shapes what is
/// sent to the backend, which trims anything beyond them.
class AppLimits {
  const AppLimits._();

  /// Longest message a user can type into the chat.
  static const int chatMessageMaxLength = 1000;

  /// How many past turns are sent as `history`.
  static const int chatHistoryMaxTurns = 10;

  /// Backend cuts any single `history` item beyond this.
  static const int chatHistoryItemMaxChars = 5000;

  /// Backend trims the whole `history` beyond this.
  static const int chatHistoryTotalMaxChars = 12000;
}
