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

/// A small sticky-note "you did this" card for a non-mood_chat journal
/// entry (breathing/sudoku/drawing) — deliberately simpler than
/// [JournalBubbleVisual]: no drag. Tapping it takes the user back into that
/// activity.
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

  /// Overrides the default tap behavior (pushing straight to the activity's
  /// own screen) — e.g. Journal's recent-memories cards route to Timeline
  /// instead. Null keeps today's direct-to-activity behavior.
  final VoidCallback? onTap;

  /// The dot/card color for a given [MoodEntryEntity.entryType], or null
  /// for an unrecognized type (e.g. `mood_chat`, which isn't one of the
  /// pill-card activity types). Single source of truth for activity-type
  /// colors — reused by [JournalDayActivityDots].
  static Color? colorForType(String entryType) =>
      _activityCopy[entryType]?.color;

  /// The short "you did this" label for a given entry type, or null for an
  /// unrecognized type. Single source of truth for activity-type short
  /// copy — reused by [JournalDayActivityDots].
  static String? labelForType(String entryType) =>
      _activityCopy[entryType]?.label;

  /// The route to push when an activity-type indicator is tapped, or null
  /// for an unrecognized type.
  static String? routeForType(String entryType) =>
      _activityCopy[entryType]?.route;

  /// The emoji shown for a given entry type, or null for an unrecognized
  /// type — reused by [TimelineDayCard]'s per-activity row icon.
  static String? emojiForType(String entryType) =>
      _activityCopy[entryType]?.emoji;

  /// Every non-mood_chat activity type the app knows about — the full set
  /// [JournalDayActivityDots] can ever need to render for a single day, so
  /// it can measure its own worst-case layout footprint without
  /// hardcoding that set itself.
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
              // Scales the whole content block down to fit the card's fixed
              // height (matching JournalBubbleContent's approach) instead of
              // overflowing — the label can otherwise run to 2 lines.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(copy.emoji, style: TextStyle(fontSize: size * 0.32)),
                    SizedBox(height: size * 0.06),
                    SizedBox(
                      // Bounds the label's width so it wraps to up to 2
                      // lines before FittedBox scales the block down —
                      // otherwise an unconstrained Text lays out on one
                      // very wide line instead.
                      width: size * 0.87,
                      child: Text(
                        copy.label,
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
