import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/journal/presentation/utils/timeline_layout.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_activity_choice_card.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_card_options_sheet.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_grid_card_widget.dart';

/// A fixed bubble size for the 3-item preview — consistent heights read
/// calmer here than the Timeline's recency-scaled scatter, which fits a
/// full page of history rather than a 3-item taste of it.
const double _previewBubbleSize = 116;
const double _scatterRange = 10;

/// Deterministic per-entry jitter — seeded by the entry's own id so a given
/// bubble always scatters to the same spot instead of reshuffling on every
/// rebuild.
Offset _scatterFor(int entryId) {
  final random = Random(entryId);
  final dx = (random.nextDouble() * 2 - 1) * _scatterRange;
  final dy = (random.nextDouble() * 2 - 1) * _scatterRange;
  return Offset(dx, dy);
}

/// The most recent (up to 3) day-groups as scattered bubbles — Journal's
/// "taste" of the full timeline.
class JournalRecentMemoriesSection extends StatelessWidget {
  const JournalRecentMemoriesSection({super.key, required this.entries});

  final List<MoodEntryEntity> entries;

  @override
  Widget build(BuildContext context) {
    final groups = TimelineLayout.groupByDay(entries).take(3).toList();

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.horizontalPaddingLg,
        AppSpacing.spaceLg,
        AppSpacing.horizontalPaddingLg,
        AppSpacing.space2Xl,
      ),
      sliver: SliverToBoxAdapter(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.spaceXl,
          runSpacing: AppSpacing.spaceXl,
          children: [
            for (var i = 0; i < groups.length; i++)
              Builder(
                builder: (context) {
                  final group = groups[i];

                  void openTimeline() => context.push(
                        AppRoutes.timeline,
                        extra: group.date,
                      );

                  return Transform.translate(
                    offset: _scatterFor(group.representative.id),
                    child: group.representative.entryType == 'mood_chat'
                        ? JournalGridCardWidget(
                            entry: group.representative,
                            index: i,
                            size: _previewBubbleSize,
                            duration: group.conversationDuration,
                            onTap: openTimeline,
                            onLongPress: () => showJournalCardOptionsSheet(
                              context,
                              entryId: group.representative.id,
                            ),
                          )
                        : JournalActivityChoiceCard(
                            entry: group.representative,
                            size: _previewBubbleSize,
                            onTap: openTimeline,
                          ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
