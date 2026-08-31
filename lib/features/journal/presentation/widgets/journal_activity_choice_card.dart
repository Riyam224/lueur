import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/journal/presentation/utils/journal_card_format.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_bubble_visual.dart'
    show noteTiltFor;
import 'package:lueur/features/journal/presentation/widgets/journal_grid_card_widget.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_pushpin.dart';
import 'package:lueur/l10n/app_localizations.dart';

class _ActivityCardCopy {
  final String emoji;
  final Color color;
  final String route;

  const _ActivityCardCopy({
    required this.emoji,
    required this.color,
    required this.route,
  });
}

const Map<String, _ActivityCardCopy> _activityCopy = {
  'breathing': _ActivityCardCopy(
    emoji: '🌬️',
    color: AppColors.journalCardBlue,
    route: AppRoutes.breathing,
  ),
  'sudoku': _ActivityCardCopy(
    emoji: '🧩',
    color: AppColors.journalCardLavender,
    route: AppRoutes.sudoku,
  ),
  'drawing': _ActivityCardCopy(
    emoji: '🎨',
    color: AppColors.journalCardPeach,
    route: AppRoutes.freeDraw,
  ),
};

/// The localized "you did this" label for a given entry type, or null if
/// unrecognized — reused by [JournalDayActivityDots] and [TimelineDayCard].
String? _labelForType(BuildContext context, String entryType) {
  final l10n = AppLocalizations.of(context)!;
  switch (entryType) {
    case 'breathing':
      return l10n.journalActivityBreathing;
    case 'sudoku':
      return l10n.journalActivityPuzzle;
    case 'drawing':
      return l10n.journalActivityDrawing;
    default:
      return null;
  }
}

/// A small sticky-note "you did this" card for a non-mood_chat journal entry
/// — simpler than [JournalBubbleVisual] (no drag); tapping it re-opens that activity.
class JournalActivityChoiceCard extends StatelessWidget {
  const JournalActivityChoiceCard({
    super.key,
    required this.entry,
    required this.size,
    this.footer,
    this.onTap,
  });

  final MoodEntryEntity entry;
  final double size;

  /// Extra content shown below the date — see
  /// [JournalBubbleContent.footer].
  final Widget? footer;

  /// Overrides the default tap behavior (straight to the activity's screen)
  /// — e.g. recent-memories cards route to Timeline instead. Null keeps the default.
  final VoidCallback? onTap;

  /// The dot/card color for a given entry type, or null for an unrecognized
  /// one (e.g. `mood_chat`) — reused by [JournalDayActivityDots].
  static Color? colorForType(String entryType) =>
      _activityCopy[entryType]?.color;

  /// The short "you did this" label for a given entry type, or null if
  /// unrecognized — reused by [JournalDayActivityDots].
  static String? labelForType(BuildContext context, String entryType) =>
      _activityCopy.containsKey(entryType)
          ? _labelForType(context, entryType)
          : null;

  /// The route to push when an activity-type indicator is tapped, or null
  /// for an unrecognized type.
  static String? routeForType(String entryType) =>
      _activityCopy[entryType]?.route;

  /// The emoji shown for a given entry type, or null for an unrecognized
  /// type — reused by [TimelineDayCard]'s per-activity row icon.
  static String? emojiForType(String entryType) =>
      _activityCopy[entryType]?.emoji;

  /// Every non-mood_chat activity type the app knows about — lets
  /// [JournalDayActivityDots] measure its own worst-case layout footprint.
  static List<String> get knownActivityTypes => _activityCopy.keys.toList();

  @override
  Widget build(BuildContext context) {
    final copy = _activityCopy[entry.entryType];
    if (copy == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap ?? () => context.push(copy.route),
      child: Transform.rotate(
        angle: noteTiltFor(entry.id),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size * JournalGridCardWidget.widthRatio,
              height: size * JournalGridCardWidget.heightRatio,
              padding: EdgeInsets.symmetric(
                horizontal: size * 0.14,
                vertical: size * 0.1,
              ),
              decoration: BoxDecoration(
                color: copy.color,
                borderRadius: BorderRadius.circular(size * 0.08),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.overlayBlack.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              // Scales the whole content block to fit the card's fixed height
              // (matching JournalBubbleContent) since the label can run to 2 lines.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(copy.emoji, style: TextStyle(fontSize: size * 0.32)),
                    SizedBox(height: size * 0.06),
                    SizedBox(
                      // Bounds the label's width so it wraps to up to 2 lines
                      // before FittedBox scales down, instead of laying out on one wide line.
                      width: size * 0.87,
                      child: Text(
                        _labelForType(context, entry.entryType) ?? '',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: ThemeTextStyles.labelSmall(context).copyWith(
                          color: AppColors.lightOnBackground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: size * 0.05),
                    Text(
                      formatJournalCardDate(entry.createdAt),
                      style: ThemeTextStyles.captionSmall(context).copyWith(
                        color:
                            AppColors.lightOnBackground.withValues(alpha: 0.6),
                      ),
                    ),
                    if (footer != null) ...[
                      SizedBox(height: size * 0.05),
                      footer!,
                    ],
                  ],
                ),
              ),
            ),
            Positioned(
              top: -size * 0.07,
              left: 0,
              right: 0,
              child: Center(
                child: JournalPushpin(
                  size: size * 0.16,
                  cardColor: copy.color,
                  isFavorite: entry.pinned,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
