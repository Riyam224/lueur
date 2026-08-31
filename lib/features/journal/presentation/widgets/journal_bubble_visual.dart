import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lueur/core/models/mood_type.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_bubble_content.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_pushpin.dart';

/// A deterministic small tilt for a sticky-note card, seeded by the entry's
/// id, so a note always leans the same way instead of reshuffling on rebuild.
double noteTiltFor(int entryId) {
  final random = Random(entryId);
  const maxTiltRadians = 0.05; // ~3 degrees
  return (random.nextDouble() * 2 - 1) * maxTiltRadians;
}

/// The sticky-note container (tape accent + content) making up a journal
/// card's static visuals — everything except press/drag, which stays in [JournalGridCardWidget].
class JournalBubbleVisual extends StatelessWidget {
  const JournalBubbleVisual({
    super.key,
    required this.entry,
    required this.moodType,
    required this.size,
    required this.duration,
    required this.showSummary,
    required this.bubbleWidth,
    required this.bubbleHeight,
    required this.cardColor,
    this.footer,
  });

  final MoodEntryEntity entry;
  final MoodType? moodType;
  final double size;
  final Duration? duration;
  final bool showSummary;
  final double bubbleWidth;
  final double bubbleHeight;
  final Color cardColor;

  /// Extra content shown below the bubble's date/summary — see
  /// [JournalBubbleContent.footer].
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: noteTiltFor(entry.id),
      child: Container(
        width: bubbleWidth,
        height: bubbleHeight,
        padding: EdgeInsets.all(size * 0.1),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(size * 0.08),
          boxShadow: [
            BoxShadow(
              color: AppColors.overlayBlack.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -size * 0.07,
              left: 0,
              right: 0,
              child: Center(
                child: JournalPushpin(
                  size: size * 0.16,
                  cardColor: cardColor,
                  isFavorite: entry.pinned,
                ),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: JournalBubbleContent(
                  entry: entry,
                  moodType: moodType,
                  size: size,
                  bubbleWidth: bubbleWidth,
                  showSummary: showSummary,
                  duration: duration,
                  footer: footer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
