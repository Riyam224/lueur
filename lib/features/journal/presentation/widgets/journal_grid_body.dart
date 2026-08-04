import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/home/presentation/widgets/recent_entries_header.dart';
import 'package:lueur/features/journal/presentation/cubit/journal_grid_cubit.dart';
import 'package:lueur/features/journal/presentation/cubit/journal_grid_state.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_recent_memories_section.dart';
import 'package:lueur/features/journal/presentation/widgets/timeline_empty_state_widget.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Loading/error/empty/loaded states for the Journal screen's entry list —
/// a header + a taste of the most recent memories once loaded.
class JournalGridBody extends StatelessWidget {
  const JournalGridBody({super.key, required this.subheadingColor});

  final Color subheadingColor;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JournalGridCubit, JournalGridState>(
      builder: (context, state) {
        final l10n = AppLocalizations.of(context)!;
        return switch (state) {
          JournalGridInitial() || JournalGridLoading() =>
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
          JournalGridError(:final message) => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.horizontalPaddingLg),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: ThemeTextStyles.bodyMedium(context),
                  ),
                ),
              ),
            ),
          JournalGridLoaded(:final entries) when entries.isEmpty =>
            SliverFillRemaining(
              hasScrollBody: false,
              child: TimelineEmptyStateWidget(
                emoji: '📖',
                title: l10n.journalEmptyStateTitle,
                message: l10n.journalGridEmptyMessage,
                messageColor: subheadingColor,
              ),
            ),
          JournalGridLoaded(:final entries) => SliverMainAxisGroup(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.horizontalPaddingLg,
                    0,
                    AppSpacing.horizontalPaddingLg,
                    0,
                  ),
                  sliver: const SliverToBoxAdapter(
                    child: RecentEntriesHeader(),
                  ),
                ),
                JournalRecentMemoriesSection(entries: entries),
              ],
            ),
        };
      },
    );
  }
}
