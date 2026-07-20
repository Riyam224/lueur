import 'package:equatable/equatable.dart';

/// Timing for the guided breathing exercise. A single seam so the pace and
/// total length can be tuned later without touching the cubit or screen.
class BreathingConfigEntity extends Equatable {
  final int breatheInSeconds;
  final int breatheOutSeconds;
  final int totalDurationSeconds;

  const BreathingConfigEntity({
    required this.breatheInSeconds,
    required this.breatheOutSeconds,
    required this.totalDurationSeconds,
  });

  int get cycleSeconds => breatheInSeconds + breatheOutSeconds;

  @override
  List<Object?> get props =>
      [breatheInSeconds, breatheOutSeconds, totalDurationSeconds];
}
