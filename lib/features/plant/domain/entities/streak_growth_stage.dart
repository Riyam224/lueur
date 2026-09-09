/// Maps a streak day count onto a repeating 7-day visual growth cycle (day 8
/// looks like day 1 again) — the underlying streak count never resets, only this visual cycles.
///
/// Deliberately separate from [PlantStage] (see plant_stage.dart), which maps
/// the same streak count onto a cumulative, non-repeating growth model that
/// tops out "fully bloomed" at day 28 and stays there. The two enums share
/// stage names (seed/sprout/blossom/blooming) by coincidence of visual
/// vocabulary, not because they represent the same progression — don't merge
/// them or assume a given streak count maps to the same stage in both.
enum StreakGrowthStage {
  seed,
  sprout,
  plant,
  blossom,
  blooming;

  String get lottiePath {
    switch (this) {
      case StreakGrowthStage.seed:
        return 'assets/lottie/seed_soil.json';
      case StreakGrowthStage.sprout:
        return 'assets/lottie/plant_sprout.json';
      case StreakGrowthStage.plant:
        return 'assets/lottie/plant.json';
      case StreakGrowthStage.blossom:
        return 'assets/lottie/blossom.json';
      case StreakGrowthStage.blooming:
        return 'assets/lottie/blooming.json';
    }
  }

  /// Day-of-week within the current 7-day growth cycle (1-7).
  /// Streak day 0 (no streak yet) is treated as cycle day 1.
  static int cycleDayFor(int streakDays) {
    if (streakDays <= 0) return 1;
    return ((streakDays - 1) % 7) + 1;
  }

  static StreakGrowthStage fromStreak(int streakDays) {
    final cycleDay = cycleDayFor(streakDays);
    if (cycleDay == 1) return StreakGrowthStage.seed;
    if (cycleDay <= 3) return StreakGrowthStage.sprout;
    if (cycleDay <= 5) return StreakGrowthStage.plant;
    if (cycleDay == 6) return StreakGrowthStage.blossom;
    return StreakGrowthStage.blooming;
  }

  /// True on every 7th day of a real streak (7, 14, 21, ...) — the moment
  /// the celebration should fire.
  static bool isCelebrationDay(int streakDays) =>
      streakDays > 0 && streakDays % 7 == 0;
}
