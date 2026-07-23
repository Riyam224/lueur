/// Maps a streak day count onto a repeating 7-day visual growth cycle —
/// day 8 looks like day 1 again, day 14 blooms again, and so on. The
/// underlying streak count itself never resets; only this visual cycles.
enum StreakGrowthStage {
  seed,
  sprout,
  plant,
  blooming;

  String get lottiePath {
    switch (this) {
      case StreakGrowthStage.seed:
        return 'assets/lottie/seed_soil.json';
      case StreakGrowthStage.sprout:
        return 'assets/lottie/plant_sprout.json';
      case StreakGrowthStage.plant:
        return 'assets/lottie/plant.json';
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
    if (cycleDay <= 6) return StreakGrowthStage.plant;
    return StreakGrowthStage.blooming;
  }

  /// True on every 7th day of a real streak (7, 14, 21, ...) — the moment
  /// the celebration should fire.
  static bool isCelebrationDay(int streakDays) =>
      streakDays > 0 && streakDays % 7 == 0;
}
