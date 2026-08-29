import 'package:flutter/material.dart';
import 'package:lueur/core/styling/app_colors.dart';

/// A small rotated washi-tape strip laid across a note's top edge — the
/// "pinned" accent for a sticky-note-style journal card.
class JournalNoteTape extends StatelessWidget {
  const JournalNoteTape({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final width = size * 0.9;
    final height = size * 0.32;
    return Transform.rotate(
      angle: -0.06,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.whiteTextColor.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(2),
          boxShadow: [
            BoxShadow(
              color: AppColors.overlayBlack.withValues(alpha: 0.08),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }
}
