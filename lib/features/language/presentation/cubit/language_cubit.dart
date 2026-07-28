import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/features/language/domain/entities/app_language.dart';
import 'package:lueur/features/language/domain/usecases/get_language_preference_usecase.dart';
import 'package:lueur/features/language/domain/usecases/set_language_preference_usecase.dart';

class LanguageCubit extends Cubit<Locale> {
  final GetLanguagePreferenceUseCase _getLanguagePreferenceUseCase;
  final SetLanguagePreferenceUseCase _setLanguagePreferenceUseCase;

  LanguageCubit({
    required GetLanguagePreferenceUseCase getLanguagePreferenceUseCase,
    required SetLanguagePreferenceUseCase setLanguagePreferenceUseCase,
  })  : _getLanguagePreferenceUseCase = getLanguagePreferenceUseCase,
        _setLanguagePreferenceUseCase = setLanguagePreferenceUseCase,
        super(const Locale('en')) {
    unawaited(_loadInitial());
  }

  Locale _toLocale(AppLanguage language) => Locale(language.code);

  Future<void> _loadInitial() async {
    final result = await _getLanguagePreferenceUseCase();
    if (isClosed) return;
    result.fold(
      (_) {}, // keep the safe English default on a read failure
      (language) => emit(_toLocale(language)),
    );
  }

  Future<void> changeLanguage(AppLanguage language) async {
    final result = await _setLanguagePreferenceUseCase(language);
    if (isClosed) return;
    result.fold(
      (_) {}, // persistence failed — leave the UI on the current language
      (_) => emit(_toLocale(language)),
    );
  }
}
