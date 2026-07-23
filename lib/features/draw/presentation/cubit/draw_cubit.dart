import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/core/theme/calm_mode_colors.dart';
import 'package:lueur/features/draw/presentation/cubit/draw_path.dart';
import 'package:lueur/features/draw/presentation/cubit/draw_state.dart';

/// Manages an ephemeral freehand drawing — no persistence, no domain/data
/// layers, since there's nothing here to save, sync, or coordinate through
/// a repository. Mirrors the presentation-only exception used for onboarding.
class DrawCubit extends Cubit<DrawState> {
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

    final updatedPaths = List<DrawPath>.from(state.paths);
    updatedPaths[updatedPaths.length - 1] =
        updatedPaths.last.addPoint(point);
    emit(state.copyWith(paths: updatedPaths));
  }

  void clear() {
    if (isClosed) return;
    emit(state.copyWith(paths: const []));
  }
}
