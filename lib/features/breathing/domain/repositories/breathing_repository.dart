import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/breathing/domain/entities/breathing_config_entity.dart';

abstract class BreathingRepository {
  Future<Either<Failure, BreathingConfigEntity>> getConfig();
}
