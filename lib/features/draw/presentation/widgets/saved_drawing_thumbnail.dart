import 'package:flutter/material.dart';
import 'package:lueur/features/draw/domain/entities/saved_drawing_entity.dart';
import 'package:lueur/features/draw/presentation/cubit/draw_path.dart';
import 'package:lueur/features/draw/presentation/widgets/draw_painter.dart';

/// Reconstructs the plain-Dart [SavedDrawingEntity] paths back into the
/// Flutter [DrawPath]s that [DrawPainter] already knows how to render —
/// reused for both the small profile thumbnail and the full-size viewer.
List<DrawPath> drawPathsFromEntity(SavedDrawingEntity drawing) {
  return drawing.paths
      .map(
        (p) => DrawPath(
          points: p.points.map((pt) => Offset(pt.$1, pt.$2)).toList(),
          color: Color(p.colorArgb),
        ),
      )
      .toList();
}

class SavedDrawingThumbnail extends StatelessWidget {
  final SavedDrawingEntity drawing;

  const SavedDrawingThumbnail({super.key, required this.drawing});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: SizedBox(
        width: 400,
        height: 400,
        child: CustomPaint(painter: DrawPainter(paths: drawPathsFromEntity(drawing))),
      ),
    );
  }
}
