import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/core/theme/calm_mode_colors.dart';
import 'package:lueur/features/draw/presentation/cubit/draw_path.dart';
import 'package:lueur/features/draw/presentation/cubit/draw_state.dart';

/// Manages an ephemeral freehand drawing — no persistence, no domain/data
/// layers to save/sync/coordinate through. Mirrors onboarding's presentation-only exception.
class DrawCubit extends Cubit<DrawState> {
  static const double _minimumPointDistanceSquared = 6.25;
  static const int _maximumPointsPerStroke = 12000;

  DrawCubit()
      : super(const DrawState(currentColor: CalmModeColors.lavenderGlow));

  void selectColor(Color color) {
    if (isClosed) return;
    emit(state.copyWith(currentColor: color));
  }

  void startStroke(Offset point) {
    if (isClosed) return;
    emit(
      state.copyWith(
        paths: [
          ...state.paths,
          DrawPath(points: [point], color: state.currentColor),
        ],
      ),
    );
  }

  void extendStroke(Offset point) {
    if (isClosed) return;
    if (state.paths.isEmpty) return;

    final activePath = state.paths.last;
    if (activePath.points.length >= _maximumPointsPerStroke) return;

    final lastPoint = activePath.points.last;
    if ((point - lastPoint).distanceSquared < _minimumPointDistanceSquared) {
      return;
    }

    // Mutate the in-progress stroke's points in place (O(1)) instead of
    // copying on every move; the outer list copy stays O(stroke count) to still trigger DrawPainter's repaint.
    activePath.addPoint(point);
    emit(state.copyWith(paths: List<DrawPath>.of(state.paths)));
  }

  void clear() {
    if (isClosed) return;
    emit(state.copyWith(paths: const []));
  }

  /// Removes only the most recent stroke, letting the user step back one
  /// mistake at a time instead of wiping the whole canvas via [clear].
  void undoLastStroke() {
    if (isClosed) return;
    if (state.paths.isEmpty) return;
    emit(state.copyWith(paths: state.paths.sublist(0, state.paths.length - 1)));
  }
}
