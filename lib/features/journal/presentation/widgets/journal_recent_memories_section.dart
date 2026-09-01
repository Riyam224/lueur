import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/widgets/list_entrance_fade.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/journal/presentation/models/day_group.dart';
import 'package:lueur/features/journal/presentation/utils/timeline_layout.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_activity_choice_card.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_card_options_sheet.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_grid_card_widget.dart';

/// A fixed bubble size for the 3-item preview — reads calmer here than
/// Timeline's recency-scaled scatter, which fits a full page of history.
const double _previewBubbleSize = 116;
const double _scatterRange = 10;
const double _bubbleWidth =
    _previewBubbleSize * JournalGridCardWidget.widthRatio;
const double _bubbleHeight =
    _previewBubbleSize * JournalGridCardWidget.heightRatio;
const double _rowStep = _bubbleHeight * 0.6;

/// Horizontal anchor (fraction of section width) for each of the up-to-3
/// preview cards — a gentle zigzag so the connector reads as a flowing path, not a straight line.
const List<double> _centerFractions = [0.24, 0.7, 0.32];

/// Deterministic per-entry jitter, seeded by the entry's own id, so a given
/// bubble always scatters to the same spot instead of reshuffling on rebuild.
Offset _scatterFor(int entryId) {
  final random = Random(entryId);
  final dx = (random.nextDouble() * 2 - 1) * _scatterRange;
  final dy = (random.nextDouble() * 2 - 1) * _scatterRange;
  return Offset(dx, dy);
}

/// The most recent (up to 3) day-groups as scattered, pin-connected cards —
/// Journal's "taste" of the full timeline.
class JournalRecentMemoriesSection extends StatelessWidget {
  const JournalRecentMemoriesSection({super.key, required this.entries});

  final List<MoodEntryEntity> entries;

  @override
  Widget build(BuildContext context) {
    final groups = TimelineLayout.groupByDay(entries).take(3).toList();
    if (groups.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final stackHeight =
        _bubbleHeight + _rowStep * (groups.length - 1) + AppSpacing.spaceXl;

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.horizontalPaddingLg,
        AppSpacing.spaceLg,
        AppSpacing.horizontalPaddingLg,
        AppSpacing.space2Xl,
      ),
      sliver: SliverToBoxAdapter(
        child: SizedBox(
          height: stackHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final anchors = <Offset>[
                for (var i = 0; i < groups.length; i++)
                  Offset(
                    _centerFractions[i] * constraints.maxWidth,
                    i * _rowStep + _bubbleHeight * 0.06,
                  ),
              ];

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  if (anchors.length > 1)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _DashedPathPainter(anchors: anchors),
                      ),
                    ),
                  for (var i = 0; i < groups.length; i++)
                    _buildCard(
                      context,
                      groups[i],
                      i,
                      anchors[i],
                      constraints.maxWidth,
                      stackHeight,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    DayGroup group,
    int index,
    Offset anchor,
    double maxWidth,
    double maxHeight,
  ) {
    void openTimeline() =>
        context.push(AppRoutes.timeline, extra: group.date);

    final jitter = _scatterFor(group.representative.id);
    final left = (anchor.dx - _bubbleWidth / 2 + jitter.dx)
        .clamp(0.0, max(0.0, maxWidth - _bubbleWidth))
        .toDouble();
    final top = (anchor.dy + jitter.dy)
        .clamp(0.0, max(0.0, maxHeight - _bubbleHeight))
        .toDouble();

    return Positioned(
      left: left,
      top: top,
      child: ListEntranceFade(
        index: index,
        child: group.representative.entryType == 'mood_chat'
            ? JournalGridCardWidget(
                entry: group.representative,
                index: index,
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
      ),
    );
  }
}

/// Draws a soft dashed line through each anchor in order — a hand-drawn
/// path connecting the recent memory notes, like the reference moodboard.
class _DashedPathPainter extends CustomPainter {
  const _DashedPathPainter({required this.anchors});

  final List<Offset> anchors;

  static const double _dashLength = 5;
  static const double _gapLength = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.overlayBlack.withValues(alpha: 0.18)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()..moveTo(anchors.first.dx, anchors.first.dy);
    for (final anchor in anchors.skip(1)) {
      path.lineTo(anchor.dx, anchor.dy);
    }

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = min(distance + _dashLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + _gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedPathPainter oldDelegate) =>
      !listEquals(oldDelegate.anchors, anchors);
}
