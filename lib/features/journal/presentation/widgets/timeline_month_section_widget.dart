import 'package:flutter/material.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/journal/presentation/models/day_group.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_card_options_sheet.dart';
import 'package:lueur/features/journal/presentation/widgets/month_separator_widget.dart';
import 'package:lueur/features/journal/presentation/widgets/timeline_day_card.dart';

/// One month's worth of agenda-style day cards, with its month heading and
/// an optional reflection line above the list.
class TimelineMonthSectionWidget extends StatelessWidget {
  const TimelineMonthSectionWidget({
    super.key,
    required this.section,
    required this.reflection,
    required this.subheadingColor,
    required this.onOpenDay,
    required this.keyForDate,
  });

  final MonthSection section;
  final String? reflection;
  final Color subheadingColor;
  final ValueChanged<DayGroup> onOpenDay;

  /// Supplies a stable [Key] for a given day, so [TimelineScreen] can scroll
  /// to a specific day via [Scrollable.ensureVisible] once it's built.
  final Key Function(DateTime date) keyForDate;

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
          for (var i = 0; i < section.groups.length; i++) ...[
            if (i > 0) SizedBox(height: AppSpacing.spaceMd),
            KeyedSubtree(
              key: keyForDate(section.groups[i].date),
              child: TimelineDayCard(
                group: section.groups[i],
                onOpenDay: onOpenDay,
                onLongPress: () => showJournalCardOptionsSheet(
                  context,
                  entryId: section.groups[i].representative.id,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
