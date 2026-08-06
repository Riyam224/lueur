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

/// Rescales [paths] so their own ink bounding box fills [frameSize] (minus
/// [padding] on every side), instead of assuming the strokes were drawn on
/// a canvas the same size as [frameSize]. The saved points are recorded in
/// the original free-draw canvas's pixel space — which varies by device and
/// is usually a tall rectangle, not a square — so painting them unscaled
/// into a small square reference frame left most of the ink outside the
/// visible area.
List<DrawPath> _fitToFrame(
  List<DrawPath> paths, {
  required double frameSize,
  double padding = 24,
}) {
  final allPoints = paths.expand((p) => p.points);
  if (allPoints.isEmpty) return paths;

  var minX = double.infinity;
  var minY = double.infinity;
  var maxX = double.negativeInfinity;
  var maxY = double.negativeInfinity;
  for (final point in allPoints) {
    if (point.dx < minX) minX = point.dx;
    if (point.dy < minY) minY = point.dy;
    if (point.dx > maxX) maxX = point.dx;
    if (point.dy > maxY) maxY = point.dy;
  }

  final inkWidth = maxX - minX;
  final inkHeight = maxY - minY;
  final available = frameSize - padding * 2;
  final longestSide = [inkWidth, inkHeight, 1.0].reduce((a, b) => a > b ? a : b);
  // A single dot (near-zero bounding box) would otherwise blow up to an
  // enormous circle at the frame's full scale — cap how far anything gets
  // magnified.
  final scale = (available / longestSide).clamp(0.05, 4.0);

  final offsetX = padding + (available - inkWidth * scale) / 2;
  final offsetY = padding + (available - inkHeight * scale) / 2;

  return paths
      .map(
        (p) => DrawPath(
          color: p.color,
          points: p.points
              .map(
                (pt) => Offset(
                  (pt.dx - minX) * scale + offsetX,
                  (pt.dy - minY) * scale + offsetY,
                ),
              )
              .toList(),
        ),
      )
      .toList();
}

class SavedDrawingThumbnail extends StatefulWidget {
  final SavedDrawingEntity drawing;

  const SavedDrawingThumbnail({super.key, required this.drawing});

  static const double _frameSize = 400;

  @override
  State<SavedDrawingThumbnail> createState() => _SavedDrawingThumbnailState();
}

class _SavedDrawingThumbnailState extends State<SavedDrawingThumbnail> {
  late List<DrawPath> _fittedPaths = _compute();

  List<DrawPath> _compute() => _fitToFrame(
        drawPathsFromEntity(widget.drawing),
        frameSize: SavedDrawingThumbnail._frameSize,
      );

  @override
  void didUpdateWidget(covariant SavedDrawingThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.drawing != widget.drawing) {
      _fittedPaths = _compute();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: ClipRect(
        child: SizedBox(
          width: SavedDrawingThumbnail._frameSize,
          height: SavedDrawingThumbnail._frameSize,
          child: CustomPaint(painter: DrawPainter(paths: _fittedPaths)),
        ),
      ),
    );
  }
}
