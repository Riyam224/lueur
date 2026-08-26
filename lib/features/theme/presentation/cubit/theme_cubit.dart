import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/features/theme/domain/entities/app_theme_mode.dart';
import 'package:lueur/features/theme/domain/usecases/get_theme_mode_usecase.dart';
import 'package:lueur/features/theme/domain/usecases/set_theme_mode_usecase.dart';

/// Defaults to [ThemeModeOption.system] until the user overrides it.
class ThemeCubit extends Cubit<ThemeModeOption> {
  final GetThemeModeUseCase _getThemeModeUseCase;
  final SetThemeModeUseCase _setThemeModeUseCase;

  ThemeCubit({
    required GetThemeModeUseCase getThemeModeUseCase,
    required SetThemeModeUseCase setThemeModeUseCase,
  })  : _getThemeModeUseCase = getThemeModeUseCase,
        _setThemeModeUseCase = setThemeModeUseCase,
        super(ThemeModeOption.system) {
    unawaited(_loadInitial());
  }

  Future<void> _loadInitial() async {
    final result = await _getThemeModeUseCase();
    if (isClosed) return;
    result.fold(
      (_) {}, // keep the safe system default on a read failure
      emit,
    );
  }

  Future<void> setThemeMode(ThemeModeOption mode) async {
    final result = await _setThemeModeUseCase(mode);
    if (isClosed) return;
    result.fold(
      (_) {}, // persistence failed — leave the UI on the current mode
      (_) => emit(mode),
    );
  }
}

extension ThemeModeOptionMapping on ThemeModeOption {
  ThemeMode toThemeMode() => switch (this) {
        ThemeModeOption.light => ThemeMode.light,
        ThemeModeOption.dark => ThemeMode.dark,
        ThemeModeOption.system => ThemeMode.system,
      };
}
