import 'package:flutter/material.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/models/mood_type.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/journal/presentation/cubit/journal_grid_state.dart';
import 'package:lueur/features/journal/presentation/models/day_group.dart';
import 'package:lueur/features/journal/presentation/utils/timeline_layout.dart';
import 'package:lueur/features/journal/presentation/widgets/timeline_empty_state_widget.dart';
import 'package:lueur/features/journal/presentation/widgets/timeline_month_section_widget.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Builds the scrollable-content slivers for [JournalGridState]: loading,
/// error, empty, no-results, or the grouped month sections. Kept outside
/// the screen's State class so the widget tree logic stays testable and
/// the screen file stays focused on layout wiring.
List<Widget> buildTimelineBodySlivers(
  BuildContext context, {
  required JournalGridState state,
  required Color subheadingColor,
  required MoodType? moodFilter,
  required DateTime? monthFilter,
  required String query,
  required void Function(DayGroup group) onOpenDay,
  required Key Function(DateTime date) keyForDate,
}) {
  if (state is JournalGridInitial || state is JournalGridLoading) {
    return [
      const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    ];
  }
  if (state is JournalGridError) {
    return [
      SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.horizontalPaddingLg),
            child: Text(
              state.message,
              textAlign: TextAlign.center,
              style: ThemeTextStyles.bodyMedium(context),
            ),
          ),
        ),
      ),
    ];
  }

  final entries = (state as JournalGridLoaded).entries;
  final l10n = AppLocalizations.of(context)!;
  if (entries.isEmpty) {
    return [
      SliverFillRemaining(
        hasScrollBody: false,
        child: TimelineEmptyStateWidget(
          emoji: '📖',
          title: l10n.journalEmptyStateTitle,
          message: l10n.journalGridEmptyMessage,
          messageColor: subheadingColor,
        ),
      ),
    ];
  }

  final filtered = entries
      .where(
        (entry) => TimelineLayout.matchesFilters(
          entry,
          moodFilter: moodFilter,
          monthFilter: monthFilter,
          query: query,
        ),
      )
      .toList();
  if (filtered.isEmpty) {
    return [
      SliverFillRemaining(
        hasScrollBody: false,
        child: TimelineEmptyStateWidget(
          emoji: '🔍',
          title: l10n.timelineNoResultsTitle,
          message: l10n.timelineNoResultsMessage,
          messageColor: subheadingColor,
        ),
      ),
    ];
  }

  final sections = TimelineLayout.sections(TimelineLayout.groupByDay(filtered));
  final reflectionPool = [
    l10n.timelineReflection1,
    l10n.timelineReflection2,
    l10n.timelineReflection3,
    l10n.timelineReflection4,
  ];

  // Each month is one lazily-built sliver item — the scroll view only
  // ever builds the month sections currently near the viewport rather
  // than every bubble in the whole history up front.
  return [
    SliverPadding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.horizontalPaddingLg,
        AppSpacing.space2Xl,
        AppSpacing.horizontalPaddingLg,
        AppSpacing.space2Xl,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => TimelineMonthSectionWidget(
            section: sections[index],
            reflection: TimelineLayout.reflectionFor(index, reflectionPool),
            subheadingColor: subheadingColor,
            onOpenDay: onOpenDay,
            keyForDate: keyForDate,
          ),
          childCount: sections.length,
        ),
      ),
    ),
  ];
}
