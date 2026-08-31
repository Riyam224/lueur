import 'package:flutter/material.dart';
import 'package:lueur/features/draw/presentation/cubit/draw_path.dart';

/// Not [Equatable]: deep-comparing every point on each emit is exactly the
/// per-point-move cost that must stay off the UI thread — every [copyWith] already produces a distinct instance, so identity suffices.
class DrawState {
  final List<DrawPath> paths;
  final Color currentColor;

  const DrawState({this.paths = const [], required this.currentColor});

  DrawState copyWith({List<DrawPath>? paths, Color? currentColor}) {
    return DrawState(
      paths: paths ?? this.paths,
      currentColor: currentColor ?? this.currentColor,
    );
  }
}
