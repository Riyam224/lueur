/// Computes the current consecutive-day streak from a list of entry
/// timestamps.
class StreakCalculator {
  StreakCalculator._();

  /// Counts consecutive calendar days ending today, or ending yesterday if
  /// there's no entry for today yet. Any gap in calendar days breaks the
  /// streak.
  static int calculateConsecutiveStreak(List<DateTime> timestamps) {
    if (timestamps.isEmpty) return 0;

    final dates = timestamps
        .map((t) {
          final local = t.toLocal();
          return DateTime(local.year, local.month, local.day);
        })
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    var expected = DateTime(today.year, today.month, today.day);
    var streak = 0;

    for (var i = 0; i < dates.length; i++) {
      final date = dates[i];
      final diff = expected.difference(date).inDays;
      // The most recent entry may be today or yesterday (today's entry
      // might not exist yet). Every entry after that must land exactly on
      // the expected consecutive day, or the streak is broken.
      if (i == 0 ? diff > 1 : diff != 0) break;
      streak++;
      expected = date.subtract(const Duration(days: 1));
    }

    return streak;
  }
}
