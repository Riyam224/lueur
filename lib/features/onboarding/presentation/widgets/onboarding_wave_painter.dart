import 'package:flutter/material.dart';

/// Paints an organic blob/wave filling the top portion of the canvas with a
/// smooth curved bottom edge, used as the colored backdrop behind each
/// onboarding page's illustration.
class OnboardingWavePainter extends CustomPainter {
  final Color color;

  const OnboardingWavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.58)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.62,
        0,
        size.height * 0.58,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant OnboardingWavePainter oldDelegate) =>
      oldDelegate.color != color;
}
