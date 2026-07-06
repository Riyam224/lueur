import 'package:ai_therapist_app/core/styling/app_colors.dart';
import 'package:flutter/material.dart';

/// Paints two stacked speech bubbles for onboarding screen 2.
/// Natural canvas size: [naturalSize]. Wrap in a SizedBox at the call site.
class OnboardingChatPainter extends CustomPainter {
  const OnboardingChatPainter();

  static const Size naturalSize = Size(200, 140);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    final bubblePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final detailPaint = Paint()
      ..color = AppColors.onboardingChatDetail
      ..style = PaintingStyle.fill;

    const topW = 180.0;
    const topH = 52.0;
    const bottomW = 140.0;
    const bottomH = 52.0;
    const gap = 14.0;
    const r = Radius.circular(16);

    // Centre the two bubbles vertically: total height = 52 + 14 + 52 = 118
    const startY = (140 - (topH + gap + bottomH)) / 2;

    // ── Top bubble (Luna typing) ────────────────────────────────────────────
    final topLeft = cx - topW / 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(topLeft, startY, topW, topH),
        r,
      ),
      bubblePaint,
    );

    // Tail: bottom-left, pointing down-left
    canvas.drawPath(
      Path()
        ..moveTo(topLeft + 12, startY + topH - 2)
        ..lineTo(topLeft - 6, startY + topH + 10)
        ..lineTo(topLeft + 28, startY + topH)
        ..close(),
      bubblePaint,
    );

    // Typing indicator: 3 dots, 8 px each, 10 px gap between edges
    const dotY = startY + topH / 2;
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(Offset(cx - 18 + i * 18.0, dotY), 4, detailPaint);
    }

    // ── Bottom bubble (user) ────────────────────────────────────────────────
    const bottomY = startY + topH + gap;
    final bottomLeft = cx - bottomW / 2;
    final bottomRight = bottomLeft + bottomW;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bottomLeft, bottomY, bottomW, bottomH),
        r,
      ),
      bubblePaint,
    );

    // Tail: bottom-right, pointing down-right
    canvas.drawPath(
      Path()
        ..moveTo(bottomRight - 12, bottomY + bottomH - 2)
        ..lineTo(bottomRight + 6, bottomY + bottomH + 10)
        ..lineTo(bottomRight - 28, bottomY + bottomH)
        ..close(),
      bubblePaint,
    );

    // Text line: 80 px wide, 3 px tall, fully rounded
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, bottomY + bottomH / 2),
          width: 80,
          height: 3,
        ),
        const Radius.circular(1.5),
      ),
      detailPaint,
    );
  }

  @override
  bool shouldRepaint(covariant OnboardingChatPainter oldDelegate) => false;
}
