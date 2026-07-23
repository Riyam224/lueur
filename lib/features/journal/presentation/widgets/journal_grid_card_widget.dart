import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lueur/core/models/journal_card_color.dart';
import 'package:lueur/core/models/mood_type.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';

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

  String _formatDate(DateTime date) => DateFormat('MMM d').format(date);

  String _preview(MoodEntryEntity entry, int maxChars) {
    final source =
        entry.aiResponse.isNotEmpty ? entry.aiResponse : entry.thoughts;
    final trimmed = source.trim();
    if (trimmed.length <= maxChars) return trimmed;
    return '${trimmed.substring(0, maxChars).trimRight()}…';
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = (JournalCardColor.fromName(widget.entry.cardColor) ??
            JournalCardColor.fromIndex(widget.index))
        .color;
    final stickerColor = JournalCardColor.fromIndex(widget.index + 1).color;
    final moodType = moodTypeFromEmoji(widget.entry.emoji);
    final showSummary =
        widget.size >= JournalGridCardWidget.summaryVisibilityThreshold;

    final bubbleWidth = widget.size * 1.15;
    final bubbleHeight = widget.size * 0.86;
    final tailOnLeft = widget.index.isEven;

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
            height: bubbleHeight + 10,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: bubbleHeight,
                  child: Container(
                    padding: EdgeInsets.all(widget.size * 0.1),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(widget.size * 0.24),
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
                              color: AppColors.lightOnBackground
                                  .withValues(alpha: 0.55),
                            ),
                          ),
                        Positioned.fill(
                          child: Center(
                            // FittedBox absorbs any leftover overflow —
                            // text-scale settings and long previews would
                            // otherwise blow past the bubble's fixed bounds.
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (moodType != null)
                                    Image.asset(
                                      moodType.assetPath,
                                      width: widget.size * 0.34,
                                      height: widget.size * 0.34,
                                      fit: BoxFit.contain,
                                    ),
                                  SizedBox(height: widget.size * 0.05),
                                  Text(
                                    _formatDate(widget.entry.createdAt),
                                    style: ThemeTextStyles.captionSmall(context)
                                        .copyWith(
                                      color: AppColors.lightOnBackground
                                          .withValues(alpha: 0.6),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (showSummary) ...[
                                    SizedBox(height: widget.size * 0.03),
                                    SizedBox(
                                      width: bubbleWidth * 0.82,
                                      child: Text(
                                        _preview(
                                          widget.entry,
                                          (widget.size / 4).round(),
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: ThemeTextStyles.bodySmall(context)
                                            .copyWith(
                                          color: AppColors.lightOnBackground,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: tailOnLeft ? widget.size * 0.18 : null,
                  right: tailOnLeft ? null : widget.size * 0.18,
                  child: CustomPaint(
                    size: const Size(18, 12),
                    painter: _BubbleTailPainter(
                      color: cardColor,
                      pointLeft: tailOnLeft,
                    ),
                  ),
                ),
                Positioned(
                  top: -widget.size * 0.08,
                  right: tailOnLeft ? -widget.size * 0.06 : null,
                  left: tailOnLeft ? null : -widget.size * 0.06,
                  child: _StickerSquare(
                    color: stickerColor,
                    size: widget.size * 0.26,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  final Color color;
  final bool pointLeft;

  const _BubbleTailPainter({required this.color, required this.pointLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    if (pointLeft) {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width * 0.25, size.height)
        ..close();
    } else {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width * 0.75, size.height)
        ..close();
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BubbleTailPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.pointLeft != pointLeft;
}

/// The small rounded, slightly-rotated smiley square that overlaps a
/// bubble's corner — the poster's signature accent.
class _StickerSquare extends StatelessWidget {
  final Color color;
  final double size;

  const _StickerSquare({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.18,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size * 0.28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CustomPaint(painter: _SmileyPainter()),
      ),
    );
  }
}

class _SmileyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..color = Colors.black.withValues(alpha: 0.75);
    final eyeRadius = size.width * 0.07;
    final eyeY = size.height * 0.42;
    canvas.drawCircle(Offset(size.width * 0.35, eyeY), eyeRadius, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.65, eyeY), eyeRadius, dotPaint);

    final smilePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.07
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.48),
      width: size.width * 0.34,
      height: size.height * 0.28,
    );
    canvas.drawArc(rect, 0.25 * 3.14159, 0.5 * 3.14159, false, smilePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
