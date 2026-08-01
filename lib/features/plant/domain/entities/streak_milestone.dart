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

  /// The highest milestone reached at or before [streakDays], or null when
  /// [streakDays] hasn't reached the first milestone yet.
  static StreakMilestone? previous(int streakDays) {
    StreakMilestone? result;
    for (final milestone in values) {
      if (milestone.days <= streakDays) result = milestone;
    }
    return result;
  }

  /// Progress (0.0-1.0) toward the next milestone, measured from the
  /// previously reached milestone (or day 0 if none reached yet). Returns
  /// 1.0 once every milestone has been reached.
  static double progressToNext(int streakDays) {
    final upcoming = next(streakDays);
    if (upcoming == null) return 1.0;
    final start = previous(streakDays)?.days ?? 0;
    final span = upcoming.days - start;
    if (span <= 0) return 1.0;
    return ((streakDays - start) / span).clamp(0.0, 1.0);
  }
}
