import 'package:flutter/material.dart';
import 'package:lueur/features/draw/presentation/cubit/draw_path.dart';

/// Not [Equatable]: deep-comparing every point of every stroke on each
/// emit (which [Cubit.emit] does to skip no-op updates) is exactly the
/// kind of per-point-move cost that must stay off the UI thread here.
/// Every [copyWith] call already produces a distinct instance, so plain
/// identity is enough to tell states apart.
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
