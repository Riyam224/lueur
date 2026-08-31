import 'package:flutter/material.dart';

/// A single freehand stroke — an ordered list of points in one color.
/// [points] is mutated in place via [addPoint]; rebuilding the list per pointer-move made a stroke O(n^2) and froze the UI on longer drawings.
class DrawPath {
  final List<Offset> points;
  final Color color;

  DrawPath({required List<Offset> points, required this.color})
      : points = List<Offset>.of(points);

  void addPoint(Offset point) => points.add(point);
}
