import 'package:flutter/material.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_activity_choice_card.dart';

/// Surfaces other activity types that happened the same day as a card
/// showing only one entry (e.g. a breathing dot next to a mood_chat card).
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

  static Widget _columnFor(List<String> entryTypes, ValueChanged<String> onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < entryTypes.length; i++) ...[
          if (i > 0) const SizedBox(height: 2),
          _ActivityLine(entryType: entryTypes[i], onTap: onTap),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final types = activityTypes.where((type) => type != excluding).toList();

    // An invisible worst-case column (every known activity type) reserves
    // this widget's layout height at a constant value, regardless of how
    // many activity types actually happened that day. Without it, a day
    // with none of these dots and a day with several take different
    // amounts of vertical space, which changes how much the ancestor
    // FittedBox (in JournalBubbleContent) has to shrink its whole bubble
    // to fit — so the "same" text style would render at different sizes
    // card to card. This reserves real measured space, not a guessed one.
    final stacked = Stack(
      alignment: Alignment.topCenter,
      children: [
        Visibility(
          visible: false,
          maintainState: true,
          maintainAnimation: true,
          maintainSize: true,
          child: _columnFor(JournalActivityChoiceCard.knownActivityTypes, onTap),
        ),
        if (types.isNotEmpty) _columnFor(types, onTap),
      ],
    );

    return maxWidth == null ? stacked : SizedBox(width: maxWidth, child: stacked);
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
              border: Border.all(color: AppColors.whiteTextColor),
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
