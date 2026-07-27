import 'package:flutter/material.dart';
import 'package:lueur/core/styling/app_colors.dart';

/// Luna reduced to just her two eyes and a closed smile, floating on a
/// solid color — the calm, minimal "loading face" moment before the app
/// takes over. Built from plain shapes, not a crop of the mascot artwork.
class LunaFace extends StatelessWidget {
  const LunaFace({super.key, required this.eyeSize});

  final double eyeSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Eye(size: eyeSize),
            SizedBox(width: eyeSize * 0.7),
            _Eye(size: eyeSize),
          ],
        ),
        SizedBox(height: eyeSize * 0.55),
        SizedBox(
          width: eyeSize * 1.1,
          height: eyeSize * 0.55,
          child: CustomPaint(painter: _SmilePainter()),
        ),
      ],
    );
  }
}

class _Eye extends StatelessWidget {
  const _Eye({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.whiteTextColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Container(
        width: size * 0.4,
        height: size * 0.4,
        decoration: const BoxDecoration(
          color: AppColors.pastelOrchid,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _SmilePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.pastelOrchid
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.35
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(size.width / 2, size.height * 1.8, size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SmilePainter oldDelegate) => false;
}
