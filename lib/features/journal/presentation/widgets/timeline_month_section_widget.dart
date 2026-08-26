import 'package:flutter/material.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/models/mood_entry_type.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/journal/presentation/models/day_group.dart';
import 'package:lueur/features/journal/presentation/utils/timeline_layout.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_activity_choice_card.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_card_options_sheet.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_grid_card_widget.dart';
import 'package:lueur/features/journal/presentation/widgets/month_separator_widget.dart';

/// One month's worth of scattered day-bubbles, with its month heading and
/// an optional reflection line above the bubbles.
class TimelineMonthSectionWidget extends StatelessWidget {
  const TimelineMonthSectionWidget({
    super.key,
    required this.section,
    required this.reflection,
    required this.subheadingColor,
    required this.onOpenDay,
  });

  final MonthSection section;
  final String? reflection;
  final Color subheadingColor;
  final ValueChanged<DayGroup> onOpenDay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.space2Xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MonthSeparatorWidget(month: section.month),
          if (reflection != null) ...[
            SizedBox(height: AppSpacing.spaceSm),
            Text(
              reflection!,
              style: ThemeTextStyles.bodySmall(context).copyWith(
                color: subheadingColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          SizedBox(height: AppSpacing.spaceLg),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.spaceXl,
            runSpacing: AppSpacing.spaceXl,
            children: [
              for (var i = 0; i < section.groups.length; i++)
                Transform.translate(
                  offset: TimelineLayout.scatterFor(
                    section.groups[i].representative.id,
                  ),
                  child: section.groups[i].representative.entryType ==
                          MoodEntryType.moodChat
                      ? JournalGridCardWidget(
                          entry: section.groups[i].representative,
                          index: i,
                          size: TimelineLayout.sizeForRank(i),
                          duration: section.groups[i].conversationDuration,
                          onTap: () => onOpenDay(section.groups[i]),
                          onLongPress: () => showJournalCardOptionsSheet(
                            context,
                            entryId: section.groups[i].representative.id,
                          ),
                        )
                      : JournalActivityChoiceCard(
                          entry: section.groups[i].representative,
                          size: TimelineLayout.sizeForRank(i),
                        ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
