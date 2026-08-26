import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
              child: Text(
                journalCardPreview(entry, (size / 3).round()),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: ThemeTextStyles.bodySmall(context).copyWith(
                  color: AppColors.lightOnBackground,
                  fontSize: 10.sp,
                  height: 1.25,
                ),
              ),
            ),
            if (duration != null) ...[
              SizedBox(height: size * 0.02),
              Text(
                formatJournalCardDuration(duration!),
                style: ThemeTextStyles.captionSmall(context).copyWith(
                  color: AppColors.lightOnBackground.withValues(alpha: 0.5),
                  fontSize: 9.sp,
                ),
              ),
            ],
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
