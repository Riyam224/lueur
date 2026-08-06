import 'package:flutter/material.dart';

/// A single freehand stroke — an ordered list of points in one color.
///
/// [points] is deliberately mutated in place via [addPoint] while a stroke
/// is being drawn. Rebuilding the whole list on every pointer-move event
/// turned a single stroke into O(n^2) work and froze the UI thread on
/// longer or more elaborate drawings.
class DrawPath {
  final List<Offset> points;
  final Color color;

  DrawPath({required List<Offset> points, required this.color})
      : points = List<Offset>.of(points);

  void addPoint(Offset point) => points.add(point);
}
