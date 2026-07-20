import 'package:equatable/equatable.dart';
import 'package:lueur/features/breathing/domain/entities/breathing_config_entity.dart';
import 'package:lueur/features/breathing/domain/entities/breathing_phase.dart';

sealed class BreathingState extends Equatable {
  const BreathingState();

  @override
  List<Object?> get props => [];
}

final class BreathingLoading extends BreathingState {
  const BreathingLoading();
}

final class BreathingInProgress extends BreathingState {
  final BreathingPhase phase;
  final int elapsedSeconds;
  final BreathingConfigEntity config;

  const BreathingInProgress({
    required this.phase,
    required this.elapsedSeconds,
    required this.config,
  });

  @override
  List<Object?> get props => [phase, elapsedSeconds, config];
}

final class BreathingFinished extends BreathingState {
  const BreathingFinished();
}

final class BreathingError extends BreathingState {
  final String message;
  const BreathingError(this.message);

  @override
  List<Object?> get props => [message];
}
