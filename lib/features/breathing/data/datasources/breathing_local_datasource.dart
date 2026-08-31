import 'package:lueur/features/breathing/domain/entities/breathing_config_entity.dart';

/// Local source of the breathing exercise's pacing. Static today; the seam
/// exists so a user-tunable pace can back this later without touching the contract.
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
