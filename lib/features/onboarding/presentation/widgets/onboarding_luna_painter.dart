import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lueur_app/core/styling/app_colors.dart';

/// Paints the Luna blob character for onboarding screen 1.
/// Natural canvas size: [naturalSize]. Wrap in a SizedBox at the call site.
class OnboardingLunaPainter extends CustomPainter {
  const OnboardingLunaPainter();

  static const Size naturalSize = Size(200, 200);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final detailPaint = Paint()
      ..color = AppColors.onboardingLunaDetail
      ..style = PaintingStyle.fill;

    final smilePaint = Paint()
      ..color = AppColors.onboardingLunaDetail
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // ── Blob body: ~140w × 150h, slightly wider at bottom ──────────────────
    final bx = cx;
    final by = cy + 5;
    final blob = Path()
      ..moveTo(bx, by - 75)
      ..cubicTo(bx + 40, by - 78, bx + 72, by - 40, bx + 72, by)
      ..cubicTo(bx + 72, by + 45, bx + 52, by + 75, bx, by + 75)
      ..cubicTo(bx - 52, by + 75, bx - 72, by + 45, bx - 72, by)
      ..cubicTo(bx - 72, by - 40, bx - 40, by - 78, bx, by - 75)
      ..close();
    canvas.drawPath(blob, whitePaint);

    // ── Arms: rounded nubs extending from mid-sides of blob ────────────────
    canvas.drawOval(
      Rect.fromCenter(center: Offset(bx - 82, by + 5), width: 22, height: 12),
      whitePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(bx + 82, by + 5), width: 22, height: 12),
      whitePaint,
    );

    // ── Eyes: two 8 px circles, 20 px apart ────────────────────────────────
    final eyeY = by - 32;
    canvas.drawCircle(Offset(bx - 10, eyeY), 4, detailPaint);
    canvas.drawCircle(Offset(bx + 10, eyeY), 4, detailPaint);

    // ── Smile: arc ~24 px wide, 2 px stroke ────────────────────────────────
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(bx, by - 16),
        width: 24,
        height: 14,
      ),
      0,
      pi,
      false,
      smilePaint,
    );

    // ── Star sparkles: upper-left, upper-right, lower-right ────────────────
    _drawSparkle(canvas, Offset(cx - 68, cy - 55), 10, whitePaint);
    _drawSparkle(canvas, Offset(cx + 72, cy - 62), 10, whitePaint);
    _drawSparkle(canvas, Offset(cx + 70, cy + 60), 10, whitePaint);
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint) {
    final half = size / 2;
    final thin = size / 6;

    final vertical = Path()
      ..moveTo(center.dx, center.dy - half)
      ..lineTo(center.dx + thin, center.dy)
      ..lineTo(center.dx, center.dy + half)
      ..lineTo(center.dx - thin, center.dy)
      ..close();

    final horizontal = Path()
      ..moveTo(center.dx - half, center.dy)
      ..lineTo(center.dx, center.dy - thin)
      ..lineTo(center.dx + half, center.dy)
      ..lineTo(center.dx, center.dy + thin)
      ..close();

    canvas.drawPath(vertical, paint);
    canvas.drawPath(horizontal, paint);
  }

  @override
  bool shouldRepaint(covariant OnboardingLunaPainter oldDelegate) => false;
}
