import 'package:flutter/material.dart';
import 'package:lueur/core/styling/app_colors.dart';

/// The small rounded, slightly-rotated smiley square that overlaps a
/// bubble's corner — the poster's signature accent.
class JournalBubbleSticker extends StatelessWidget {
  final Color color;
  final double size;

  const JournalBubbleSticker({
    super.key,
    required this.color,
    required this.size,
  });

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
              color: AppColors.overlayBlack.withValues(alpha: 0.08),
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
    final dotPaint = Paint()
      ..color = AppColors.overlayBlack.withValues(alpha: 0.75);
    final eyeRadius = size.width * 0.07;
    final eyeY = size.height * 0.42;
    canvas.drawCircle(Offset(size.width * 0.35, eyeY), eyeRadius, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.65, eyeY), eyeRadius, dotPaint);

    final smilePaint = Paint()
      ..color = AppColors.overlayBlack.withValues(alpha: 0.75)
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
