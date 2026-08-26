import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_activity_choice_card.dart';

/// A friendly one-line-per-activity description of the day's other
/// activities (breathing/sudoku/drawing), shown inside a Timeline day card
/// below its main content. Unlike [JournalDayActivityDots] — a compact tap
/// target for the small Journal preview bubbles — this spells out what
/// happened in a short warm sentence, since Timeline cards have the
/// vertical room for it. Reuses [JournalActivityChoiceCard.colorForType]
/// as the single source of truth for activity-type dot colors.
class TimelineActivityDescriptionRow extends StatelessWidget {
  const TimelineActivityDescriptionRow({
    super.key,
    required this.dayEntries,
    required this.excludingType,
    required this.maxWidth,
  });

  final List<MoodEntryEntity> dayEntries;
  final String excludingType;
  final double maxWidth;

  static String? _phraseFor(MoodEntryEntity entry) {
    switch (entry.entryType) {
      case 'breathing':
        final seconds = entry.payload['duration_seconds'];
        if (seconds is num && seconds >= 60) {
          final minutes = (seconds / 60).round();
          return 'took a $minutes min breather';
        }
        return 'took a breather';
      case 'sudoku':
        final solved = entry.payload['solved'];
        if (solved == true) return 'played a puzzle — solved!';
        if (solved == false) return 'gave a puzzle a go';
        return 'played a puzzle';
      case 'drawing':
        return 'made a little drawing';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Last entry of each non-excluded type present that day, so the
    // phrase reflects the most recent occurrence's payload.
    final byType = <String, MoodEntryEntity>{};
    for (final entry in dayEntries) {
      if (entry.entryType == excludingType) continue;
      byType[entry.entryType] = entry;
    }
    if (byType.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      width: maxWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final entry in byType.values)
            if (_phraseFor(entry) case final phrase?)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: GestureDetector(
                  onTap: () {
                    final route =
                        JournalActivityChoiceCard.routeForType(entry.entryType);
                    if (route != null) context.push(route);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: JournalActivityChoiceCard.colorForType(
                                entry.entryType,
                              ) ??
                              AppColors.lightOnBackground,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          phrase,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ThemeTextStyles.captionSmall(context).copyWith(
                            color: AppColors.lightOnBackground
                                .withValues(alpha: 0.6),
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.lightOnBackground
                                .withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
