import 'dart:math';
import 'package:flutter/material.dart';

/// Draws a rounded-rect outline with a subtle hand-drawn "wobble" — small
/// deterministic per-edge offsets seeded from canvas size, so it stays stable across rebuilds instead of jittering.
class SketchyBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double wobble;

  const SketchyBorderPainter({
    required this.color,
    this.strokeWidth = 1.6,
    this.radius = 20,
    this.wobble = 1.6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random((size.width * 1000 + size.height).toInt());
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final basePath = Path()..addRRect(rrect);

    final wobblyPath = Path();
    for (final metric in basePath.computeMetrics()) {
      const step = 14.0;
      var distance = 0.0;
      var first = true;
      while (distance < metric.length) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          final jitter = (random.nextDouble() * 2 - 1) * wobble;
          final normal = Offset(-tangent.vector.dy, tangent.vector.dx);
          final point = tangent.position + normal * jitter;
          if (first) {
            wobblyPath.moveTo(point.dx, point.dy);
            first = false;
          } else {
            wobblyPath.lineTo(point.dx, point.dy);
          }
        }
        distance += step;
      }
      wobblyPath.close();
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(wobblyPath, paint);
  }

  @override
  bool shouldRepaint(SketchyBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.radius != radius ||
      oldDelegate.wobble != wobble;
}
