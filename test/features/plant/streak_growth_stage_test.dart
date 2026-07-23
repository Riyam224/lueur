import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/features/plant/domain/entities/streak_growth_stage.dart';

void main() {
  group('StreakGrowthStage.fromStreak', () {
    test('day 1 of a cycle is seed', () {
      expect(StreakGrowthStage.fromStreak(1), StreakGrowthStage.seed);
      expect(StreakGrowthStage.fromStreak(8), StreakGrowthStage.seed);
    });

    test('days 2-3 of a cycle are sprout', () {
      expect(StreakGrowthStage.fromStreak(2), StreakGrowthStage.sprout);
      expect(StreakGrowthStage.fromStreak(3), StreakGrowthStage.sprout);
      expect(StreakGrowthStage.fromStreak(10), StreakGrowthStage.sprout);
    });

    test('days 4-6 of a cycle are plant', () {
      expect(StreakGrowthStage.fromStreak(4), StreakGrowthStage.plant);
      expect(StreakGrowthStage.fromStreak(6), StreakGrowthStage.plant);
      expect(StreakGrowthStage.fromStreak(13), StreakGrowthStage.plant);
    });

    test('day 7 of a cycle is blooming, and re-blooms every 7th day', () {
      expect(StreakGrowthStage.fromStreak(7), StreakGrowthStage.blooming);
      expect(StreakGrowthStage.fromStreak(14), StreakGrowthStage.blooming);
      expect(StreakGrowthStage.fromStreak(21), StreakGrowthStage.blooming);
    });

    test('no streak yet is seed', () {
      expect(StreakGrowthStage.fromStreak(0), StreakGrowthStage.seed);
    });
  });

  group('StreakGrowthStage.isCelebrationDay', () {
    test('true only on positive multiples of 7', () {
      expect(StreakGrowthStage.isCelebrationDay(7), isTrue);
      expect(StreakGrowthStage.isCelebrationDay(14), isTrue);
      expect(StreakGrowthStage.isCelebrationDay(21), isTrue);
    });

    test('false for 0 and non-multiples of 7', () {
      expect(StreakGrowthStage.isCelebrationDay(0), isFalse);
      expect(StreakGrowthStage.isCelebrationDay(6), isFalse);
      expect(StreakGrowthStage.isCelebrationDay(8), isFalse);
    });
  });
}
