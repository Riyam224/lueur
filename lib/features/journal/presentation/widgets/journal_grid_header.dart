import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/home/presentation/cubit/mood_cubit.dart';
import 'package:lueur/features/home/presentation/cubit/mood_state.dart';
import 'package:lueur/features/home/presentation/widgets/streak_card_widget.dart';
import 'package:lueur/features/home/presentation/widgets/weekly_letter_banner.dart';
import 'package:lueur/features/plant/presentation/cubit/plant_cubit.dart';
import 'package:lueur/features/plant/presentation/cubit/plant_state.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Title, subtitle, streak card, and (for non-guest users) the weekly
/// letter banner at the top of the Journal screen.
class JournalGridHeader extends StatelessWidget {
  const JournalGridHeader({
    super.key,
    required this.headingColor,
    required this.subheadingColor,
    required this.isGuest,
  });

  final Color headingColor;
  final Color subheadingColor;
  final bool isGuest;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppSpacing.spaceLg),
        Text(
          l10n.journalGridTitle,
          style: ThemeTextStyles.headlineMedium(context)
              .copyWith(color: headingColor),
        ),
        SizedBox(height: AppSpacing.spaceSm),
        Text(
          l10n.journalGridSubtitle,
          style: ThemeTextStyles.bodyMedium(context)
              .copyWith(color: subheadingColor),
        ),
        SizedBox(height: AppSpacing.spaceLg),
        BlocBuilder<MoodCubit, MoodState>(
          builder: (context, moodState) {
            final entries = moodState is MoodHistorySuccess
                ? moodState.entries
                : <MoodEntryEntity>[];
            return BlocBuilder<PlantCubit, PlantState>(
              builder: (context, plantState) {
                final streakDays =
                    plantState is PlantLoaded ? plantState.streakDays : 0;
                return StreakCardWidget(
                  entries: entries,
                  streakDays: streakDays,
                );
              },
            );
          },
        ),
        if (!isGuest) ...[
          SizedBox(height: AppSpacing.spaceLg),
          const WeeklyLetterBanner(),
        ],
        SizedBox(height: AppSpacing.spaceLg),
      ],
    );
  }
}
