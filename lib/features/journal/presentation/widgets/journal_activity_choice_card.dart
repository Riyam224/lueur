import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/journal/presentation/utils/journal_card_format.dart';

class _ActivityCardCopy {
  final String emoji;
  final String label;
  final Color color;
  final String route;

  const _ActivityCardCopy({
    required this.emoji,
    required this.label,
    required this.color,
    required this.route,
  });
}

const Map<String, _ActivityCardCopy> _activityCopy = {
  'breathing': _ActivityCardCopy(
    emoji: '🌬️',
    label: 'took a breather',
    color: AppColors.journalCardBlue,
    route: AppRoutes.breathing,
  ),
  'sudoku': _ActivityCardCopy(
    emoji: '🧩',
    label: 'played a puzzle',
    color: AppColors.journalCardLavender,
    route: AppRoutes.sudoku,
  ),
  'drawing': _ActivityCardCopy(
    emoji: '🎨',
    label: 'made a little drawing',
    color: AppColors.journalCardPeach,
    route: AppRoutes.freeDraw,
  ),
};

/// A small pill-shaped "you did this" card for a non-mood_chat journal
/// entry (breathing/sudoku/drawing) — deliberately simpler than
/// [JournalBubbleVisual]: no tail, no sticker, no drag. Tapping it takes
/// the user back into that activity.
class JournalActivityChoiceCard extends StatelessWidget {
  const JournalActivityChoiceCard({
    super.key,
    required this.entry,
    required this.size,
    this.footer,
  });

  final MoodEntryEntity entry;
  final double size;

  /// Extra content shown below the date — see
  /// [JournalBubbleContent.footer].
  final Widget? footer;

  /// The dot/card color for a given [MoodEntryEntity.entryType], or null
  /// for an unrecognized type (e.g. `mood_chat`, which isn't one of the
  /// pill-card activity types). Single source of truth for activity-type
  /// colors — reused by [JournalDayActivityDots].
  static Color? colorForType(String entryType) => _activityCopy[entryType]?.color;

  /// The short "you did this" label for a given entry type, or null for an
  /// unrecognized type. Single source of truth for activity-type short
  /// copy — reused by [JournalDayActivityDots].
  static String? labelForType(String entryType) => _activityCopy[entryType]?.label;

  /// The route to push when an activity-type indicator is tapped, or null
  /// for an unrecognized type.
  static String? routeForType(String entryType) => _activityCopy[entryType]?.route;

  /// Every non-mood_chat activity type the app knows about — the full set
  /// [JournalDayActivityDots]/[TimelineActivityDescriptionRow] can ever
  /// need to render for a single day, so they can measure their own
  /// worst-case layout footprint without hardcoding that set themselves.
  static List<String> get knownActivityTypes => _activityCopy.keys.toList();

  @override
  Widget build(BuildContext context) {
    final copy = _activityCopy[entry.entryType];
    if (copy == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => context.push(copy.route),
      child: Container(
        width: size * 1.15,
        padding: EdgeInsets.symmetric(
          horizontal: size * 0.14,
          vertical: size * 0.16,
        ),
        decoration: BoxDecoration(
          color: copy.color,
          borderRadius: BorderRadius.circular(size),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(copy.emoji, style: TextStyle(fontSize: size * 0.32)),
            SizedBox(height: size * 0.06),
            Text(
              copy.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: ThemeTextStyles.labelSmall(context).copyWith(
                color: AppColors.lightOnBackground,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: size * 0.05),
            Text(
              formatJournalCardDate(entry.createdAt),
              style: ThemeTextStyles.captionSmall(context).copyWith(
                color: AppColors.lightOnBackground.withValues(alpha: 0.6),
              ),
            ),
            if (footer != null) ...[
              SizedBox(height: size * 0.05),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}
