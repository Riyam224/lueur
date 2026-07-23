import 'package:hive_flutter/hive_flutter.dart';

/// Persists the last streak-day milestone (7, 14, 21, ...) the celebration
/// screen has already been shown for, so it fires once per milestone
/// instead of every time the user revisits Home that day.
class StreakCelebrationPrefs {
  static const _boxName = 'streak_celebration';
  static const _key = 'last_milestone';

  /// Returns the last celebrated milestone, or 0 if none yet.
  /// Returns 0 on any storage error (safe default — celebration may show again).
  static Future<int> lastMilestone() async {
    try {
      final box = await Hive.openBox<int>(_boxName);
      return box.get(_key, defaultValue: 0)!;
    } catch (_) {
      return 0;
    }
  }

  /// Persists the milestone just celebrated. Silently swallows storage errors.
  static Future<void> markCelebrated(int milestone) async {
    try {
      final box = await Hive.openBox<int>(_boxName);
      await box.put(_key, milestone);
    } catch (_) {}
  }
}
