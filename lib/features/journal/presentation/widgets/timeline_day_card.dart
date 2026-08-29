import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/models/mood_type.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/journal/presentation/models/day_group.dart';
import 'package:lueur/features/journal/presentation/utils/journal_card_format.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_activity_choice_card.dart';

/// One agenda-style card per day — every activity that day (mood check-ins
/// and activity entries alike) listed as a row, in chronological order.
/// Replaces the old scattered per-entry-type bubble cards: a day with a
/// mood check-in and a breathing session now shows both in one place.
class TimelineDayCard extends StatelessWidget {
  const TimelineDayCard({
    super.key,
    required this.group,
    required this.onOpenDay,
    required this.onLongPress,
  });

  final DayGroup group;
  final ValueChanged<DayGroup> onOpenDay;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = context.extra.cardBackgroundColor ??
        (isDark ? AppColors.darkSurface : AppColors.lightSurface);
    final textColor = context.extra.primaryTextColor ??
        (isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground);
    final shadowColor = context.extra.shadowColor ?? AppColors.shadowColor;
    final locale = Localizations.localeOf(context).toString();
    final dayLabel = DateFormat('EEE, MMM d', locale).format(group.date);

    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.spaceLg),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(AppSpacing.spaceLg),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    dayLabel,
                    style: ThemeTextStyles.labelMedium(context).copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (group.pinned)
                  Icon(
                    Icons.push_pin_rounded,
                    size: 14,
                    color: textColor.withValues(alpha: 0.55),
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.spaceMd),
            for (var i = 0; i < group.entries.length; i++) ...[
              if (i > 0) SizedBox(height: AppSpacing.spaceSm),
              _TimelineEntryRow(
                entry: group.entries[i],
                onTap: () => _openEntry(context, group.entries[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openEntry(BuildContext context, MoodEntryEntity entry) {
    if (entry.entryType == 'mood_chat') {
      onOpenDay(group);
      return;
    }
    final route = JournalActivityChoiceCard.routeForType(entry.entryType);
    if (route != null) context.push(route);
  }
}

class _TimelineEntryRow extends StatelessWidget {
  const _TimelineEntryRow({required this.entry, required this.onTap});

  final MoodEntryEntity entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final moodType = moodTypeFromEmoji(entry.emoji);
    final isMoodEntry = entry.entryType == 'mood_chat';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = context.extra.primaryTextColor ??
        (isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground);
    final timeColor = context.extra.secondaryTextColor ?? textColor;

    final iconColor = isMoodEntry
        ? (moodType?.journalBubbleColor ?? AppColors.journalCardLavender)
        : (JournalActivityChoiceCard.colorForType(entry.entryType) ??
            AppColors.journalCardLavender);

    final title = isMoodEntry
        ? journalCardPreview(entry, 42)
        : JournalActivityChoiceCard.labelForType(entry.entryType) ??
            entry.entryType;

    final timeLabel = DateFormat('h:mm a').format(entry.createdAt);

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
            child: Center(
              child: isMoodEntry
                  ? (moodType != null
                      ? Image.asset(
                          moodType.assetPath,
                          width: 24,
                          height: 24,
                          fit: BoxFit.contain,
                        )
                      : null)
                  : Text(
                      JournalActivityChoiceCard.emojiForType(entry.entryType) ??
                          '',
                      style: const TextStyle(fontSize: 18),
                    ),
            ),
          ),
          SizedBox(width: AppSpacing.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ThemeTextStyles.bodyMedium(context).copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  timeLabel,
                  style: ThemeTextStyles.captionSmall(context).copyWith(
                    color: timeColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
