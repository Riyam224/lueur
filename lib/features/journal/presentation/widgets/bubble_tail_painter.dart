import 'package:flutter/material.dart';

/// Small triangular "speech bubble" tail pointing left or right.
class BubbleTailPainter extends CustomPainter {
  final Color color;
  final bool pointLeft;

  const BubbleTailPainter({required this.color, required this.pointLeft});

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
  bool shouldRepaint(covariant BubbleTailPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.pointLeft != pointLeft;
}
