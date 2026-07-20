import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/breathing/domain/entities/breathing_config_entity.dart';
import 'package:lueur/features/breathing/domain/repositories/breathing_repository.dart';

class GetBreathingConfigUseCase {
  final BreathingRepository repository;
  const GetBreathingConfigUseCase(this.repository);

  Future<Either<Failure, BreathingConfigEntity>> call() => repository.getConfig();
}
