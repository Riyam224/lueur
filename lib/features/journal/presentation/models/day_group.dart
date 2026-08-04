import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';

/// One journal bubble's worth of data — every entry from a single calendar
/// day, chronologically ordered. Color/pin/delete act on [representative]
/// (the day's most recent entry) since those fields live on a single entry.
class DayGroup {
  final DateTime date;
  final List<MoodEntryEntity> entries;

  DayGroup({required this.date, required this.entries});

  MoodEntryEntity get representative => entries.last;

  bool get pinned => entries.any((e) => e.pinned);

  Duration? get conversationDuration => entries.length > 1
      ? entries.last.createdAt.difference(entries.first.createdAt)
      : null;
}

/// A month's worth of day-groups, newest day first.
class MonthSection {
  final DateTime month;
  final List<DayGroup> groups;

  MonthSection({required this.month, required this.groups});
}
