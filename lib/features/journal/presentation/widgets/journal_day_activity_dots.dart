import 'package:flutter/material.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_activity_choice_card.dart';

/// A small stack of colored dot + short-label rows surfacing the activity
/// types present on a day whose card only shows one entry — e.g. a
/// mood_chat card that also had a breathing session that day gets a blue
/// dot next to "took a breather". Rendered inside the card's own content
/// area (passed in as a card's `footer`), not overlaid on top of it.
/// Purely a tap-reporter: no navigation logic lives here.
class JournalDayActivityDots extends StatelessWidget {
  static const double _dotSize = 7;

  const JournalDayActivityDots({
    super.key,
    required this.activityTypes,
    required this.excluding,
    required this.onTap,
    this.maxWidth,
  });

  final Set<String> activityTypes;
  final String excluding;
  final ValueChanged<String> onTap;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final types = activityTypes.where((type) => type != excluding).toList();
    if (types.isEmpty) return const SizedBox.shrink();

    final column = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < types.length; i++) ...[
          if (i > 0) const SizedBox(height: 2),
          _ActivityLine(entryType: types[i], onTap: onTap),
        ],
      ],
    );

    return maxWidth == null ? column : SizedBox(width: maxWidth, child: column);
  }
}

class _ActivityLine extends StatelessWidget {
  const _ActivityLine({required this.entryType, required this.onTap});

  final String entryType;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final color = JournalActivityChoiceCard.colorForType(entryType);
    final label = JournalActivityChoiceCard.labelForType(entryType);
    if (color == null || label == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => onTap(entryType),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: JournalDayActivityDots._dotSize,
            height: JournalDayActivityDots._dotSize,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white),
            ),
          ),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ThemeTextStyles.captionSmall(context).copyWith(
                color: AppColors.lightOnBackground.withValues(alpha: 0.65),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
