import 'package:flutter/material.dart';
import 'package:lueur/core/styling/app_colors.dart';

/// The 4 pastel options a journal grid card can be customized with.
/// Persisted on [MoodEntryEntity.cardColor] as this enum's [name] — a plain
/// string, so the domain layer stays free of Flutter's [Color] type.
enum JournalCardColor {
  lavender,
  mint,
  peach,
  coral;

  Color get color => switch (this) {
        JournalCardColor.lavender => AppColors.journalCardLavender,
        JournalCardColor.mint => AppColors.journalCardMint,
        JournalCardColor.peach => AppColors.journalCardPeach,
        JournalCardColor.coral => AppColors.journalCardCoral,
      };

  static JournalCardColor? fromName(String? name) {
    for (final value in JournalCardColor.values) {
      if (value.name == name) return value;
    }
    return null;
  }

  /// Deterministic rotation so unset cards get a stable color that doesn't
  /// reshuffle on rebuild.
  static JournalCardColor fromIndex(int index) =>
      JournalCardColor.values[index % JournalCardColor.values.length];
}
