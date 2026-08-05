import 'package:lueur/features/plant/domain/entities/streak_growth_stage.dart';
import 'package:lueur/features/plant/domain/entities/streak_milestone.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Localized copy helpers for the streak celebration screen, kept separate
/// from the widget tree so the mapping logic isn't buried inside build().
class StreakCelebrationCopy {
  const StreakCelebrationCopy._();

  static const int affirmationCount = 6;

  static String affirmation(AppLocalizations l10n, int index) =>
      switch (index) {
        0 => l10n.streakCelebrationAffirmations0,
        1 => l10n.streakCelebrationAffirmations1,
        2 => l10n.streakCelebrationAffirmations2,
        3 => l10n.streakCelebrationAffirmations3,
        4 => l10n.streakCelebrationAffirmations4,
        _ => l10n.streakCelebrationAffirmations5,
      };

  static String nextMilestoneText(AppLocalizations l10n, int streakDays) {
    final next = StreakMilestone.next(streakDays);
    if (next == null) return l10n.streakCelebrationAllMilestonesReached;
    return l10n.streakCelebrationNextMilestone(next.days - streakDays);
  }

  static String stageLabel(AppLocalizations l10n, StreakGrowthStage stage) =>
      switch (stage) {
        StreakGrowthStage.seed => l10n.streakGrowthStageSeedLabel,
        StreakGrowthStage.sprout => l10n.streakGrowthStageSproutLabel,
        StreakGrowthStage.plant => l10n.streakGrowthStagePlantLabel,
        StreakGrowthStage.blossom => l10n.streakGrowthStageBlossomLabel,
        StreakGrowthStage.blooming => l10n.streakGrowthStageBloomingLabel,
      };
}
