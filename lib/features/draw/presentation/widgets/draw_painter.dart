import 'package:flutter/material.dart';
import 'package:lueur/features/draw/presentation/cubit/draw_path.dart';

class DrawPainter extends CustomPainter {
  final List<DrawPath> paths;

  const DrawPainter({required this.paths});

  @override
  void paint(Canvas canvas, Size size) {
    for (final path in paths) {
      if (path.points.length < 2) {
        if (path.points.isNotEmpty) {
          canvas.drawCircle(path.points.first, 3, Paint()..color = path.color);
        }
        continue;
      }

      final paint = Paint()
        ..color = path.color
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final uiPath = Path()
        ..moveTo(path.points.first.dx, path.points.first.dy);
      for (final point in path.points.skip(1)) {
        uiPath.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(uiPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DrawPainter oldDelegate) =>
      oldDelegate.paths != paths;
}
