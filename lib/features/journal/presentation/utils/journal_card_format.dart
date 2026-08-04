import 'package:intl/intl.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';

String formatJournalCardDate(DateTime date) => DateFormat('MMM d').format(date);

String formatJournalCardDuration(Duration duration) {
  if (duration.inHours >= 1) {
    final minutes = duration.inMinutes % 60;
    return minutes > 0
        ? '${duration.inHours}h ${minutes}m'
        : '${duration.inHours}h';
  }
  if (duration.inMinutes >= 1) return '${duration.inMinutes}m';
  return '<1m';
}

String journalCardPreview(MoodEntryEntity entry, int maxChars) {
  final source =
      entry.aiResponse.isNotEmpty ? entry.aiResponse : entry.thoughts;
  final trimmed = source.trim();
  if (trimmed.length <= maxChars) return trimmed;
  return '${trimmed.substring(0, maxChars).trimRight()}…';
}
