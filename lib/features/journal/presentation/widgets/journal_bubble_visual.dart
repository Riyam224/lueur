import 'package:flutter/material.dart';
import 'package:lueur/core/models/mood_type.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/journal/presentation/widgets/bubble_tail_painter.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_bubble_content.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_bubble_sticker.dart';

/// The bubble container (with pin icon + content), tail, and sticker accent
/// that make up a journal card's static visuals — everything except the
/// press/drag interaction, which stays in [JournalGridCardWidget].
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
    required this.tailOnLeft,
    required this.cardColor,
    required this.stickerColor,
  });

  final MoodEntryEntity entry;
  final MoodType? moodType;
  final double size;
  final Duration? duration;
  final bool showSummary;
  final double bubbleWidth;
  final double bubbleHeight;
  final bool tailOnLeft;
  final Color cardColor;
  final Color stickerColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: bubbleHeight,
          child: Container(
            padding: EdgeInsets.all(size * 0.1),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(size * 0.24),
            ),
            child: Stack(
              children: [
                if (entry.pinned)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(
                      Icons.push_pin_rounded,
                      size: 14,
                      color: AppColors.lightOnBackground
                          .withValues(alpha: 0.55),
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
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: tailOnLeft ? size * 0.18 : null,
          right: tailOnLeft ? null : size * 0.18,
          child: CustomPaint(
            size: const Size(18, 12),
            painter: BubbleTailPainter(color: cardColor, pointLeft: tailOnLeft),
          ),
        ),
        Positioned(
          top: -size * 0.08,
          right: tailOnLeft ? -size * 0.06 : null,
          left: tailOnLeft ? null : -size * 0.06,
          child: JournalBubbleSticker(color: stickerColor, size: size * 0.26),
        ),
      ],
    );
  }
}
