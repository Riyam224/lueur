import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// A single freehand stroke — an ordered list of points in one color.
class DrawPath extends Equatable {
  final List<Offset> points;
  final Color color;

  const DrawPath({required this.points, required this.color});

  DrawPath addPoint(Offset point) =>
      DrawPath(points: [...points, point], color: color);

  @override
  List<Object?> get props => [points, color];
}
