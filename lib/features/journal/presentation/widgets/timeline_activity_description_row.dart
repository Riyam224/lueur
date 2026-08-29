import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_activity_choice_card.dart';

/// One-line-per-activity description of the day's other activities, shown
/// below a Timeline day card's main content — the roomier counterpart to
/// [JournalDayActivityDots]'s compact tap target on the Journal preview.
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

  static Widget _row(BuildContext context, MoodEntryEntity entry, String phrase) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: GestureDetector(
        onTap: () {
          final route = JournalActivityChoiceCard.routeForType(entry.entryType);
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
                color: JournalActivityChoiceCard.colorForType(entry.entryType) ??
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
                  color: AppColors.lightOnBackground.withValues(alpha: 0.6),
                  decoration: TextDecoration.underline,
                  decorationColor:
                      AppColors.lightOnBackground.withValues(alpha: 0.3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _columnFor(BuildContext context, List<MoodEntryEntity> entries) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final entry in entries)
          if (_phraseFor(entry) case final phrase?) _row(context, entry, phrase),
      ],
    );
  }

  /// Placeholder entries — one per known activity type — used only to
  /// measure this widget's worst-case height; never shown (see [build]).
  static final List<MoodEntryEntity> _ghostEntries = [
    for (final type in JournalActivityChoiceCard.knownActivityTypes)
      MoodEntryEntity(
        id: -1,
        userId: '',
        emoji: '',
        thoughts: '',
        aiResponse: '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        entryType: type,
      ),
  ];

  @override
  Widget build(BuildContext context) {
    // Last entry of each non-excluded type present that day, so the
    // phrase reflects the most recent occurrence's payload.
    final byType = <String, MoodEntryEntity>{};
    for (final entry in dayEntries) {
      if (entry.entryType == excludingType) continue;
      byType[entry.entryType] = entry;
    }

    // An invisible worst-case column (every known activity type) reserves
    // this widget's layout height at a constant value regardless of how
    // many activities actually happened that day — see the matching
    // comment in JournalDayActivityDots.build for why that consistency
    // matters to the ancestor FittedBox.
    return SizedBox(
      width: maxWidth,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Visibility(
            visible: false,
            maintainState: true,
            maintainAnimation: true,
            maintainSize: true,
            child: _columnFor(context, _ghostEntries),
          ),
          if (byType.isNotEmpty) _columnFor(context, byType.values.toList()),
        ],
      ),
    );
  }
}
