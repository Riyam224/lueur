/// Maps a streak day count onto a cumulative, non-repeating growth model
/// that tops out "fully bloomed" at day 28 and stays there.
///
/// Deliberately separate from [StreakGrowthStage] (see
/// streak_growth_stage.dart), which maps the same streak count onto a
/// repeating 7-day visual cycle instead. The two enums share stage names
/// (seed/sprout/blossom/blooming) by coincidence of visual vocabulary, not
/// because they represent the same progression — don't merge them or assume
/// a given streak count maps to the same stage in both.
enum PlantStage {
  seed,
  sprout,
  seedling,
  youngPlant,
  blooming;

  String get lottiePath {
    switch (this) {
      case PlantStage.seed:
        return 'assets/lottie/seed_soil.json';
      case PlantStage.sprout:
        return 'assets/lottie/plant_sprout.json';
      case PlantStage.seedling:
        return 'assets/lottie/plant_sprout.json';
      case PlantStage.youngPlant:
        return 'assets/lottie/blossom.json';
      case PlantStage.blooming:
        return 'assets/lottie/blooming.json';
    }
  }

  String get label {
    switch (this) {
      case PlantStage.seed:
        return 'Plant your first seed 🌱';
      case PlantStage.sprout:
        return 'Your plant is sprouting!';
      case PlantStage.seedling:
        return 'Growing beautifully 🌿';
      case PlantStage.youngPlant:
        return 'Almost blooming...';
      case PlantStage.blooming:
        return 'Fully blooming! 🌸';
    }
  }

  String get streakMessage {
    switch (this) {
      case PlantStage.seed:
        return 'Start journaling to grow Luna';
      case PlantStage.sprout:
        return 'Keep going, Luna is growing!';
      case PlantStage.seedling:
        return '1 week strong 💪';
      case PlantStage.youngPlant:
        return 'Luna loves your consistency';
      case PlantStage.blooming:
        return 'Luna is fully blooming! 🌸';
    }
  }

  static PlantStage fromStreak(int streak) {
    if (streak == 0)  return PlantStage.seed;
    if (streak < 7)   return PlantStage.sprout;
    if (streak < 14)  return PlantStage.seedling;
    if (streak < 28)  return PlantStage.youngPlant;
    return PlantStage.blooming;
  }
}
