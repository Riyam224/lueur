import 'package:flutter/material.dart';
import 'package:lueur/core/styling/app_assets.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/utils/app_strings.dart';

/// The set of mood illustrations available in assets/illustrations/.
enum MoodType {
  happy,
  sad,
  angry,
  anxious,
  calm,
  excited,
  grateful,
  hopeful,
  lonely,
  neutral,
  scared,
  burnout,
  contentPeaceful,
}

/// Reverse lookup from a persisted [MoodEntry.emoji] unicode value back to
/// its [MoodType], so any screen displaying a saved mood entry can render
/// the same illustration used on the home mood picker.
MoodType? moodTypeFromEmoji(String emoji) {
  for (final moodType in MoodType.values) {
    if (moodType.emoji == emoji) return moodType;
  }
  return null;
}

extension MoodTypeDetails on MoodType {
  String get assetPath => switch (this) {
        MoodType.happy => AppAssets.illustrationHappy,
        MoodType.sad => AppAssets.illustrationSad,
        MoodType.angry => AppAssets.illustrationAngry,
        MoodType.anxious => AppAssets.illustrationAnxious,
        MoodType.calm => AppAssets.illustrationCalm,
        MoodType.excited => AppAssets.illustrationExcited,
        MoodType.grateful => AppAssets.illustrationGrateful,
        MoodType.hopeful => AppAssets.illustrationHopeful,
        MoodType.lonely => AppAssets.illustrationLonely,
        MoodType.neutral => AppAssets.illustrationNeutral,
        MoodType.scared => AppAssets.illustrationScared,
        MoodType.burnout => AppAssets.illustrationBurnout,
        MoodType.contentPeaceful => AppAssets.illustrationContentPeaceful,
      };

  /// Unicode emoji representing this mood — used for the mood picker and
  /// stored as the persisted [MoodEntry.emoji] value.
  String get emoji => switch (this) {
        MoodType.happy => '😊',
        MoodType.sad => '😢',
        MoodType.angry => '😠',
        MoodType.anxious => '😰',
        MoodType.calm => '😌',
        MoodType.excited => '🤩',
        MoodType.grateful => '🙏',
        MoodType.hopeful => '🤞',
        MoodType.lonely => '😔',
        MoodType.neutral => '😐',
        MoodType.scared => '😨',
        MoodType.burnout => '🫠',
        MoodType.contentPeaceful => '🧘',
      };

  /// Border/glow color used to highlight this mood when selected.
  Color get color => switch (this) {
        MoodType.happy => AppColors.moodHappy,
        MoodType.sad => AppColors.moodSad,
        MoodType.angry => AppColors.errorColor,
        MoodType.anxious => AppColors.moodAnxious,
        MoodType.calm => AppColors.moodCalm,
        MoodType.excited => AppColors.moodExcited,
        MoodType.grateful => AppColors.accent,
        MoodType.hopeful => AppColors.breathOutColor,
        MoodType.lonely => AppColors.lavender,
        MoodType.neutral => AppColors.moodNeutral,
        MoodType.scared => AppColors.primaryDark,
        MoodType.burnout => AppColors.warningAmber,
        MoodType.contentPeaceful => AppColors.primaryContainer,
      };

  /// Light-mode tile background — a soft tint of [color].
  Color get bgColor => Color.lerp(color, AppColors.lightSurface, 0.85)!;

  /// Moods distressing enough that "Talk to Luna" should route through the
  /// breathing exercise first instead of straight to the AI response.
  bool get isLowMood => switch (this) {
        MoodType.angry ||
        MoodType.anxious ||
        MoodType.scared ||
        MoodType.burnout =>
          true,
        _ => false,
      };

  String get label => switch (this) {
        MoodType.happy => AppStrings.moodLabelHappy,
        MoodType.sad => AppStrings.moodLabelSad,
        MoodType.angry => AppStrings.moodLabelAngry,
        MoodType.anxious => AppStrings.moodLabelAnxious,
        MoodType.calm => AppStrings.moodLabelCalm,
        MoodType.excited => AppStrings.moodLabelExcited,
        MoodType.grateful => AppStrings.moodLabelGrateful,
        MoodType.hopeful => AppStrings.moodLabelHopeful,
        MoodType.lonely => AppStrings.moodLabelLonely,
        MoodType.neutral => AppStrings.moodLabelNeutral,
        MoodType.scared => AppStrings.moodLabelScared,
        MoodType.burnout => AppStrings.moodLabelBurnout,
        MoodType.contentPeaceful => AppStrings.moodLabelContentPeaceful,
      };
}
