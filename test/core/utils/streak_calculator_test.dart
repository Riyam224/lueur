import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/utils/streak_calculator.dart';

void main() {
  final today = DateTime.now();
  DateTime daysAgo(int n) =>
      DateTime(today.year, today.month, today.day).subtract(Duration(days: n));

  group('StreakCalculator.calculateConsecutiveStreak', () {
    test('returns 0 for an empty list', () {
      expect(StreakCalculator.calculateConsecutiveStreak([]), 0);
    });

    test('first-ever check-in (today only) counts as a 1-day streak', () {
      final result = StreakCalculator.calculateConsecutiveStreak([daysAgo(0)]);
      expect(result, 1);
    });

    test('consecutive days ending today count every day', () {
      final entries = [daysAgo(0), daysAgo(1), daysAgo(2), daysAgo(3)];
      expect(StreakCalculator.calculateConsecutiveStreak(entries), 4);
    });

    test('no check-in today yet still counts the streak ending yesterday', () {
      final entries = [daysAgo(1), daysAgo(2), daysAgo(3)];
      expect(StreakCalculator.calculateConsecutiveStreak(entries), 3);
    });

    test('a gap breaks the streak at the gap, not before it', () {
      // Today, yesterday, then a 2-day gap before day 4/5.
      final entries = [daysAgo(0), daysAgo(1), daysAgo(4), daysAgo(5)];
      expect(StreakCalculator.calculateConsecutiveStreak(entries), 2);
    });

    test('a lapsed streak (most recent entry 2+ days ago) resets to 0', () {
      final entries = [daysAgo(3), daysAgo(4), daysAgo(5)];
      expect(StreakCalculator.calculateConsecutiveStreak(entries), 0);
    });

    test('multiple entries on the same day count as a single day', () {
      final entries = [
        daysAgo(0),
        daysAgo(0).add(const Duration(hours: 3)),
        daysAgo(1),
      ];
      expect(StreakCalculator.calculateConsecutiveStreak(entries), 2);
    });
  });
}
