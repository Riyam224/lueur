/// The exact streak-day counts that trigger a full-screen celebration.
/// Unlike [StreakGrowthStage]'s repeating 7-day visual cycle, these are
/// fixed, non-repeating milestones — the celebration screen only ever
/// fires on one of these four days.
enum StreakMilestone {
  day7(7),
  day10(10),
  day15(15),
  day30(30);

  const StreakMilestone(this.days);

  final int days;

  /// True when [streakDays] lands exactly on one of the milestone days.
  static bool isMilestone(int streakDays) =>
      values.any((m) => m.days == streakDays);

  static StreakMilestone? fromStreak(int streakDays) {
    for (final milestone in values) {
      if (milestone.days == streakDays) return milestone;
    }
    return null;
  }

  /// The next milestone strictly after [streakDays], or null once every
  /// milestone has already been reached.
  static StreakMilestone? next(int streakDays) {
    for (final milestone in values) {
      if (milestone.days > streakDays) return milestone;
    }
    return null;
  }
}
