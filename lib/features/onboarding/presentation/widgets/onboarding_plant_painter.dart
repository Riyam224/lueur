import 'dart:math';
import 'package:flutter/material.dart';

/// Paints a plant sprout for onboarding screen 3.
/// Natural canvas size: [naturalSize]. Wrap in a SizedBox at the call site.
class OnboardingPlantPainter extends CustomPainter {
  const OnboardingPlantPainter();

  static const Size naturalSize = Size(120, 160);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // ── Soil mound: half-ellipse, 90×26 px, anchored at bottom ─────────────
    final soilCy = size.height - 6;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, soilCy), width: 90, height: 26),
      whitePaint,
    );

    // ── Stem: 5 px wide, 75 px tall, grows from soil top ───────────────────
    final stemBottom = soilCy - 13;
    final stemTop = stemBottom - 75;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 2.5, stemTop, 5, 75),
        const Radius.circular(2.5),
      ),
      whitePaint,
    );

    // ── Left leaf: 48×28 px oval, -35°, at 40 % stem height ────────────────
    final leftLeafY = stemBottom - 75 * 0.40;
    canvas.save();
    canvas.translate(cx, leftLeafY);
    canvas.rotate(-35 * pi / 180);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-22, 0), width: 48, height: 28),
      whitePaint,
    );
    canvas.restore();

    // ── Right leaf: 48×28 px oval, +35°, at 60 % stem height ───────────────
    final rightLeafY = stemBottom - 75 * 0.60;
    canvas.save();
    canvas.translate(cx, rightLeafY);
    canvas.rotate(35 * pi / 180);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(22, 0), width: 48, height: 28),
      whitePaint,
    );
    canvas.restore();

    // ── Bud: 14 px circle at stem top ──────────────────────────────────────
    canvas.drawCircle(Offset(cx, stemTop), 7, whitePaint);
  }

  @override
  bool shouldRepaint(covariant OnboardingPlantPainter oldDelegate) => false;
}
