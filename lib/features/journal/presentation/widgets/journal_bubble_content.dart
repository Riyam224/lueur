import 'package:flutter/material.dart';
import 'package:lueur/core/models/mood_type.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/journal/presentation/utils/journal_card_format.dart';

/// The exact rendered height of one line of [style], measured from the
/// font's own metrics — so reserved layout slots match what actually paints.
double _measuredLineHeight(TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(text: 'Ag', style: style),
    textDirection: TextDirection.ltr,
  )..layout();
  return painter.height;
}

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

  /// Extra content shown below the date/summary/duration (e.g. Timeline's
  /// other-activities row) — null for the default Journal preview.
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

    // Both lines reserve their full-content height regardless of actual text
    // length, so FittedBox scales every card by the same factor — depending only on `showSummary`, not incidental content length.
    final previewLineHeight = _measuredLineHeight(previewStyle);
    final durationLineHeight = _measuredLineHeight(durationStyle);

    // A footer widget (e.g. [JournalDayActivityDots]) reserves its own
    // worst-case height internally, so it reports the same intrinsic size regardless of content — no guessing needed here.

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
