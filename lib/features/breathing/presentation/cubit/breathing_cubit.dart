import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/core/journal/journal_refresh_signal.dart';
import 'package:lueur/features/breathing/domain/entities/breathing_config_entity.dart';
import 'package:lueur/features/breathing/domain/entities/breathing_phase.dart';
import 'package:lueur/features/breathing/domain/usecases/get_breathing_config_usecase.dart';
import 'package:lueur/features/breathing/presentation/cubit/breathing_state.dart';
import 'package:lueur/features/home/domain/usecases/log_activity_usecase.dart';

/// Drives the guided-breathing timeline: which phase is active and how far
/// through. Purely a ticking clock — the scale animation lives in the widget layer.
class BreathingCubit extends Cubit<BreathingState> {
  final GetBreathingConfigUseCase _getConfigUseCase;
  final LogActivityUseCase _logActivityUseCase;
  final JournalRefreshSignal _journalRefreshSignal;

  Timer? _ticker;
  BreathingConfigEntity? _config;
  int _elapsedSeconds = 0;

  BreathingCubit(
    this._getConfigUseCase,
    this._logActivityUseCase,
    this._journalRefreshSignal,
  ) : super(const BreathingLoading());

  Future<void> start() async {
    _ticker?.cancel();
    _elapsedSeconds = 0;

    final result = await _getConfigUseCase();
    if (isClosed) return;

    result.fold(
      (failure) => emit(BreathingError(failure.message)),
      (config) {
        _config = config;
        emit(
          BreathingInProgress(
            phase: BreathingPhase.breatheIn,
            elapsedSeconds: 0,
            config: config,
          ),
        );
        _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
      },
    );
  }

  void _tick() {
    if (isClosed) return;
    final config = _config;
    if (config == null) return;

    _elapsedSeconds++;
    if (_elapsedSeconds >= config.totalDurationSeconds) {
      _ticker?.cancel();
      emit(const BreathingFinished());
      unawaited(
        _logActivityUseCase(
          entryType: 'breathing',
          payload: {'duration_seconds': _elapsedSeconds},
        ).then((result) => result.fold((_) {}, (_) => _journalRefreshSignal.bump())),
      );
      return;
    }

    final positionInCycle = _elapsedSeconds % config.cycleSeconds;
    final phase = positionInCycle < config.breatheInSeconds
        ? BreathingPhase.breatheIn
        : BreathingPhase.breatheOut;

    emit(
      BreathingInProgress(
        phase: phase,
        elapsedSeconds: _elapsedSeconds,
        config: config,
      ),
    );
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
