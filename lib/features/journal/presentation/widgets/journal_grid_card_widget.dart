import 'package:flutter/material.dart';
import 'package:lueur/core/models/journal_card_color.dart';
import 'package:lueur/core/models/mood_type.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_bubble_visual.dart';

/// A speech-bubble card — a rounded rectangle with a small tail and a
/// smiley "sticker" accent overlapping one corner, echoing the playful
/// chat-bubble poster look rather than a plain grid card.
class JournalGridCardWidget extends StatefulWidget {
  /// Below this bubble size the AI summary line is dropped — only the
  /// mood illustration and date still fit comfortably.
  static const double summaryVisibilityThreshold = 112;

  /// How far a bubble can be dragged from its natural spot before it's
  /// clamped — its "limited space" to move around in.
  static const double dragBoundRadius = 42;

  final MoodEntryEntity entry;
  final int index;
  final double size;
  final Duration? duration;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  /// Extra content shown below the bubble's date/summary — see
  /// [JournalBubbleContent.footer].
  final Widget? footer;

  const JournalGridCardWidget({
    super.key,
    required this.entry,
    required this.index,
    required this.size,
    required this.onTap,
    required this.onLongPress,
    this.duration,
    this.footer,
  });

  @override
  State<JournalGridCardWidget> createState() => _JournalGridCardWidgetState();
}

class _JournalGridCardWidgetState extends State<JournalGridCardWidget>
    with SingleTickerProviderStateMixin {
  static const Curve _bounceBackCurve = Cubic(0.34, 1.56, 0.64, 1.0);

  bool _pressed = false;
  Offset _dragOffset = Offset.zero;
  late final AnimationController _springController;
  Animation<Offset>? _springAnimation;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(() {
        final animation = _springAnimation;
        if (animation == null || !mounted) return;
        setState(() => _dragOffset = animation.value);
      });
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  void _setPressed(bool value) {
    if (!mounted) return;
    setState(() => _pressed = value);
  }

  void _onDragStart(DragStartDetails _) => _springController.stop();

  void _onDragUpdate(DragUpdateDetails details) {
    if (!mounted) return;
    final next = _dragOffset + details.delta;
    final distance = next.distance;
    final clamped = distance > JournalGridCardWidget.dragBoundRadius
        ? next * (JournalGridCardWidget.dragBoundRadius / distance)
        : next;
    setState(() => _dragOffset = clamped);
  }

  void _onDragEnd(DragEndDetails _) {
    _springAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _springController, curve: _bounceBackCurve),
    );
    _springController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final moodType = moodTypeFromEmoji(widget.entry.emoji);
    // A manually-picked color (via the card options sheet) always wins;
    // otherwise the bubble is colored by its primary emotion so the
    // timeline reads as a recognizable emotional map instead of a random
    // per-card rotation.
    final cardColor =
        JournalCardColor.fromName(widget.entry.cardColor)?.color ??
            moodType?.journalBubbleColor ??
            JournalCardColor.fromIndex(widget.index).color;
    final showSummary =
        widget.size >= JournalGridCardWidget.summaryVisibilityThreshold;

    final bubbleWidth = widget.size * 1.15;
    final bubbleHeight = widget.size * 0.86;

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onPanStart: _onDragStart,
      onPanUpdate: _onDragUpdate,
      onPanEnd: _onDragEnd,
      child: Transform.translate(
        offset: _dragOffset,
        child: AnimatedScale(
          scale: _pressed ? 0.88 : 1.0,
          duration: Duration(milliseconds: _pressed ? 120 : 300),
          curve: _pressed ? Curves.easeOut : _bounceBackCurve,
          child: SizedBox(
            width: bubbleWidth,
            height: bubbleHeight,
            child: JournalBubbleVisual(
              entry: widget.entry,
              moodType: moodType,
              size: widget.size,
              duration: widget.duration,
              showSummary: showSummary,
              bubbleWidth: bubbleWidth,
              bubbleHeight: bubbleHeight,
              cardColor: cardColor,
              footer: widget.footer,
            ),
          ),
        ),
      ),
    );
  }
}
