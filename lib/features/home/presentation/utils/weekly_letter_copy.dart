/// Softens angry-mood emojis into something kinder for the weekly letter's
/// "dominant mood" chip — the letter is meant to feel warm and conversational.
String cuteWeeklyEmoji(String emoji) {
  return switch (emoji) {
    '😠' || '😡' => '🥰',
    _ => emoji,
  };
}
