import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lueur/core/models/journal_card_color.dart';
import 'package:lueur/core/models/mood_type.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';

/// An organic "blob" bubble — Luna's soft blob-cat shape rather than a
/// rectangular card. Size and border-radius asymmetry vary per bubble so a
/// [Wrap] of these reads as a natural, staggered cluster instead of a grid.
class JournalGridCardWidget extends StatefulWidget {
  /// Below this bubble size the AI summary line is dropped — only the
  /// mood illustration and date still fit comfortably.
  static const double summaryVisibilityThreshold = 112;

  /// Fractional corner radii (of the bubble's own size), cycled by index
  /// so neighboring bubbles don't all share the exact same blob shape.
  static const List<List<double>> _blobPresets = [
    [0.58, 0.42, 0.45, 0.55],
    [0.45, 0.60, 0.55, 0.40],
    [0.50, 0.38, 0.60, 0.48],
  ];

  final MoodEntryEntity entry;
  final int index;
  final double size;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const JournalGridCardWidget({
    super.key,
    required this.entry,
    required this.index,
    required this.size,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<JournalGridCardWidget> createState() => _JournalGridCardWidgetState();
}

class _JournalGridCardWidgetState extends State<JournalGridCardWidget> {
  static const Curve _bounceBackCurve = Cubic(0.34, 1.56, 0.64, 1.0);

  bool _pressed = false;

  void _setPressed(bool value) {
    if (!mounted) return;
    setState(() => _pressed = value);
  }

  String _formatDate(DateTime date) => DateFormat('MMM d').format(date);

  String _preview(MoodEntryEntity entry, int maxChars) {
    final source =
        entry.aiResponse.isNotEmpty ? entry.aiResponse : entry.thoughts;
    final trimmed = source.trim();
    if (trimmed.length <= maxChars) return trimmed;
    return '${trimmed.substring(0, maxChars).trimRight()}…';
  }

  BorderRadius _blobRadius(double size) {
    final preset = JournalGridCardWidget
        ._blobPresets[widget.index % JournalGridCardWidget._blobPresets.length];
    return BorderRadius.only(
      topLeft: Radius.circular(size * preset[0]),
      topRight: Radius.circular(size * preset[1]),
      bottomLeft: Radius.circular(size * preset[2]),
      bottomRight: Radius.circular(size * preset[3]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = (JournalCardColor.fromName(widget.entry.cardColor) ??
            JournalCardColor.fromIndex(widget.index))
        .color;
    final moodType = moodTypeFromEmoji(widget.entry.emoji);
    final showSummary =
        widget.size >= JournalGridCardWidget.summaryVisibilityThreshold;

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1.0,
        duration: Duration(milliseconds: _pressed ? 120 : 300),
        curve: _pressed ? Curves.easeOut : _bounceBackCurve,
        child: Container(
          width: widget.size,
          height: widget.size,
          padding: EdgeInsets.all(widget.size * 0.12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: _blobRadius(widget.size),
          ),
          child: Stack(
            children: [
              if (widget.entry.pinned)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(
                    Icons.push_pin_rounded,
                    size: 14,
                    color: AppColors.lightOnBackground.withValues(alpha: 0.55),
                  ),
                ),
              Positioned.fill(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (moodType != null)
                        Image.asset(
                          moodType.assetPath,
                          width: widget.size * 0.36,
                          height: widget.size * 0.36,
                          fit: BoxFit.contain,
                        ),
                      SizedBox(height: widget.size * 0.05),
                      Text(
                        _formatDate(widget.entry.createdAt),
                        style: ThemeTextStyles.captionSmall(context).copyWith(
                          color: AppColors.lightOnBackground
                              .withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (showSummary) ...[
                        SizedBox(height: widget.size * 0.03),
                        Text(
                          _preview(widget.entry, (widget.size / 4).round()),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: ThemeTextStyles.bodySmall(context).copyWith(
                            color: AppColors.lightOnBackground,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
