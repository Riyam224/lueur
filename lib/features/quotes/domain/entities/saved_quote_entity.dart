class SavedQuoteEntity {
  final String id;
  final String text;
  final DateTime savedAt;

  /// The mood emoji active when this was saved, if any.
  final String? emoji;

  /// What the user wrote (their thoughts/message) alongside this quote.
  final String? thoughts;

  const SavedQuoteEntity({
    required this.id,
    required this.text,
    required this.savedAt,
    this.emoji,
    this.thoughts,
  });
}
