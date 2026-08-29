import 'package:flutter/material.dart';
import 'package:lueur/core/models/mood_type.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/journal/presentation/utils/journal_card_format.dart';

/// Mood illustration + date, and (space permitting) an AI-response preview
/// and conversation duration, scaled to fit inside a journal bubble.
class JournalBubbleContent extends StatelessWidget {
  const JournalBubbleContent({
    super.key,
    required this.entry,
    required this.moodType,
    required this.size,
    required this.bubbleWidth,
    required this.showSummary,
    required this.duration,
    this.footer,
  });

  final MoodEntryEntity entry;
  final MoodType? moodType;
  final double size;
  final double bubbleWidth;
  final bool showSummary;
  final Duration? duration;

  /// Extra content shown below the date/summary/duration — e.g. the
  /// Timeline day card's other-activities description row. Null for the
  /// default (Journal preview) rendering.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final previewStyle = ThemeTextStyles.bodySmall(context).copyWith(
      color: AppColors.lightOnBackground,
      height: 1.25,
    );
    final durationStyle = ThemeTextStyles.captionSmall(context).copyWith(
      color: AppColors.lightOnBackground.withValues(alpha: 0.5),
    );

    // Both the preview and the duration line reserve their full-content
    // height (3 lines; one line) regardless of how much text an entry
    // actually has. Without this, FittedBox scales its whole child down by
    // however much *this* entry's content overflows the bubble — so a
    // short entry (1 line, no duration) and a long one (3 lines + duration)
    // at the same bubble size end up scaled by different factors, and the
    // "same" text style renders at visibly different sizes. Reserving a
    // fixed footprint makes the scale factor depend only on `showSummary`,
    // not on incidental content length.
    final previewLineHeight = previewStyle.fontSize! * previewStyle.height!;
    final durationLineHeight = durationStyle.fontSize! * 1.3;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (moodType != null)
            Image.asset(
              moodType!.assetPath,
              width: size * 0.34,
              height: size * 0.34,
              fit: BoxFit.contain,
            ),
          SizedBox(height: size * 0.05),
          Text(
            formatJournalCardDate(entry.createdAt),
            style: ThemeTextStyles.labelSmall(context).copyWith(
              color: AppColors.lightOnBackground.withValues(alpha: 0.65),
              fontWeight: FontWeight.w700,
            ),
          ),
          if (showSummary) ...[
            SizedBox(height: size * 0.03),
            SizedBox(
              width: bubbleWidth * 0.82,
              height: previewLineHeight * 3,
              child: Text(
                journalCardPreview(entry, (size / 3).round()),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: previewStyle,
              ),
            ),
            SizedBox(height: size * 0.02),
            SizedBox(
              height: durationLineHeight,
              child: duration != null
                  ? Text(
                      formatJournalCardDuration(duration!),
                      style: durationStyle,
                    )
                  : null,
            ),
          ],
          if (footer != null) ...[
            SizedBox(height: size * 0.03),
            footer!,
          ],
        ],
      ),
    );
  }
}
