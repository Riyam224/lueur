import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:lueur/core/models/mood_type.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/journal/presentation/models/day_group.dart';

/// Pure grouping/filtering/layout math for the timeline screen — kept free
/// of [BuildContext] so it stays unit-testable and reusable outside widgets.
class TimelineLayout {
  const TimelineLayout._();

  static const double maxBubbleSize = 128;
  static const double minBubbleSize = 96;
  static const int recencySpan = 6;
  static const double scatterRange = 14;

  /// Reflection lines shown sparingly between month sections — cycled
  /// deterministically so they don't reshuffle on every rebuild.
  static const int reflectionEveryNMonths = 3;

  static List<DayGroup> groupByDay(List<MoodEntryEntity> entries) {
    final byDay = <DateTime, List<MoodEntryEntity>>{};
    for (final entry in entries) {
      final day = DateTime(
        entry.createdAt.year,
        entry.createdAt.month,
        entry.createdAt.day,
      );
      (byDay[day] ??= []).add(entry);
    }

    final groups = byDay.entries.map((e) {
      final dayEntries = [...e.value]
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return DayGroup(date: e.key, entries: dayEntries);
    }).toList();

    groups.sort((a, b) => b.date.compareTo(a.date));
    return groups;
  }

  static List<DayGroup> sortedByPin(List<DayGroup> groups) {
    final pinned = groups.where((g) => g.pinned).toList();
    final rest = groups.where((g) => !g.pinned).toList();
    return [...pinned, ...rest];
  }

  static bool matchesFilters(
    MoodEntryEntity entry, {
    required MoodType? moodFilter,
    required DateTime? monthFilter,
    required String query,
  }) {
    if (moodFilter != null && moodTypeFromEmoji(entry.emoji) != moodFilter) {
      return false;
    }
    if (monthFilter != null) {
      final matchesMonth = entry.createdAt.year == monthFilter.year &&
          entry.createdAt.month == monthFilter.month;
      if (!matchesMonth) return false;
    }
    if (query.trim().isNotEmpty) {
      final needle = query.trim().toLowerCase();
      final haystack = '${entry.thoughts} ${entry.aiResponse}'.toLowerCase();
      if (!haystack.contains(needle)) return false;
    }
    return true;
  }

  static List<MonthSection> sections(List<DayGroup> groups) {
    final byMonth = <DateTime, List<DayGroup>>{};
    for (final group in groups) {
      final month = DateTime(group.date.year, group.date.month);
      (byMonth[month] ??= []).add(group);
    }

    final result = byMonth.entries
        .map((e) => MonthSection(month: e.key, groups: sortedByPin(e.value)))
        .toList()
      ..sort((a, b) => b.month.compareTo(a.month));
    return result;
  }

  static double sizeForRank(int rank) {
    final t = (rank / recencySpan).clamp(0.0, 1.0);
    return maxBubbleSize - (maxBubbleSize - minBubbleSize) * t;
  }

  /// Deterministic per-entry jitter — seeded by the entry's own id so a
  /// given bubble always scatters to the same spot instead of reshuffling
  /// on every rebuild/scroll.
  static Offset scatterFor(int entryId) {
    final random = Random(entryId);
    final dx = (random.nextDouble() * 2 - 1) * scatterRange;
    final dy = (random.nextDouble() * 2 - 1) * scatterRange;
    return Offset(dx, dy);
  }

  static String? reflectionFor(int sectionIndex, List<String> pool) {
    if (sectionIndex == 0 || sectionIndex % reflectionEveryNMonths != 0) {
      return null;
    }
    return pool[(sectionIndex ~/ reflectionEveryNMonths - 1) % pool.length];
  }
}
