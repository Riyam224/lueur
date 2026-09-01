import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/models/journal_card_color.dart';
import 'package:lueur/core/models/mood_type.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/journal/presentation/models/day_group.dart';
import 'package:lueur/features/journal/presentation/utils/journal_card_format.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_activity_choice_card.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_bubble_visual.dart'
    show noteTiltFor;

/// One agenda-style card per day — every activity that day, each a
/// color-tagged rail item with a pastel note and exact time. Replaces the old per-entry-type bubble cards.
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
            for (var i = 0; i < group.entries.length; i++)
              _TimelineActivityItem(
                entry: group.entries[i],
                isLast: i == group.entries.length - 1,
                onTap: () => _openEntry(context, group.entries[i]),
              ),
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

/// One activity's row: a color-tagged rail capsule on the left, connected
/// by a dashed line, and a tilted pastel note with time and a short preview.
class _TimelineActivityItem extends StatelessWidget {
  const _TimelineActivityItem({
    required this.entry,
    required this.isLast,
    required this.onTap,
  });

  final MoodEntryEntity entry;
  final bool isLast;
  final VoidCallback onTap;

  /// The rail tag's short category name for a non-mood activity entry (e.g.
  /// `breathing` -> `Breathing`), distinct from the card's fuller detail text.
  static String _shortActivityLabel(String entryType) =>
      entryType.isEmpty ? entryType : entryType[0].toUpperCase() + entryType.substring(1);

  @override
  Widget build(BuildContext context) {
    final moodType = moodTypeFromEmoji(entry.emoji);
    final isMoodEntry = entry.entryType == 'mood_chat';

    // A manually-picked color (via the card options sheet) always wins,
    // matching JournalGridCardWidget's precedence.
    final accentColor = JournalCardColor.fromName(entry.cardColor)?.color ??
        (isMoodEntry
            ? (moodType?.journalBubbleColor ?? AppColors.journalCardLavender)
            : (JournalActivityChoiceCard.colorForType(entry.entryType) ??
                AppColors.journalCardLavender));

    // The rail tag is a short category name; the card gives the detail —
    // otherwise an activity entry would repeat the same text on both sides.
    final tagLabel = isMoodEntry
        ? (moodType?.label(context) ?? entry.emoji)
        : _shortActivityLabel(entry.entryType);

    final preview = isMoodEntry
        ? journalCardPreview(entry, 60)
        : JournalActivityChoiceCard.labelForType(context, entry.entryType) ??
            entry.entryType;

    final timeLabel = DateFormat('h:mm a').format(entry.createdAt);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.spaceSm),
      child: GestureDetector(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      tagLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ThemeTextStyles.captionSmall(context).copyWith(
                        color: AppColors.lightOnBackground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: _DashedVerticalLine(color: accentColor),
                      ),
                    ),
                ],
              ),
              SizedBox(width: AppSpacing.spaceMd),
              Expanded(
                child: Transform.rotate(
                  angle: noteTiltFor(entry.id) * 0.5,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.spaceMd,
                      vertical: AppSpacing.spaceSm,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.overlayBlack.withValues(alpha: 0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: AppColors.lightOnBackground
                                  .withValues(alpha: 0.55),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              timeLabel,
                              style:
                                  ThemeTextStyles.captionSmall(context).copyWith(
                                color: AppColors.lightOnBackground
                                    .withValues(alpha: 0.7),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.spaceXs),
                        Text(
                          preview,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: ThemeTextStyles.bodySmall(context).copyWith(
                            color: AppColors.lightOnBackground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A short dashed line connecting one rail tag to the next.
class _DashedVerticalLine extends StatelessWidget {
  const _DashedVerticalLine({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 2,
      child: CustomPaint(
        painter: _DashedVerticalPainter(color: color),
        size: const Size(2, double.infinity),
      ),
    );
  }
}

class _DashedVerticalPainter extends CustomPainter {
  const _DashedVerticalPainter({required this.color});

  final Color color;

  static const double _dashLength = 4;
  static const double _gapLength = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    var y = 0.0;
    while (y < size.height) {
      final end = (y + _dashLength).clamp(0.0, size.height);
      canvas.drawLine(Offset(1, y), Offset(1, end), paint);
      y += _dashLength + _gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedVerticalPainter oldDelegate) =>
      oldDelegate.color != color;
}
