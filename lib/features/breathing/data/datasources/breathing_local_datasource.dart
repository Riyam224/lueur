import 'package:lueur/features/breathing/domain/entities/breathing_config_entity.dart';

/// Local source of the breathing exercise's pacing. Static today; the seam
/// exists so a user-tunable pace (e.g. from settings) can back this later
/// without touching the repository contract or the cubit.
class BreathingLocalDatasource {
  const BreathingLocalDatasource();

  BreathingConfigEntity getDefaultConfig() {
    return const BreathingConfigEntity(
      breatheInSeconds: 4,
      breatheOutSeconds: 4,
      totalDurationSeconds: 48,
    );
  }
}
