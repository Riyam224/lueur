import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:lueur/features/draw/presentation/cubit/draw_path.dart';

class DrawState extends Equatable {
  final List<DrawPath> paths;
  final Color currentColor;

  const DrawState({this.paths = const [], required this.currentColor});

  DrawState copyWith({List<DrawPath>? paths, Color? currentColor}) {
    return DrawState(
      paths: paths ?? this.paths,
      currentColor: currentColor ?? this.currentColor,
    );
  }

  @override
  List<Object?> get props => [paths, currentColor];
}
