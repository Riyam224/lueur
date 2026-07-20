import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/breathing/data/datasources/breathing_local_datasource.dart';
import 'package:lueur/features/breathing/domain/entities/breathing_config_entity.dart';
import 'package:lueur/features/breathing/domain/repositories/breathing_repository.dart';

class BreathingRepositoryImpl implements BreathingRepository {
  final BreathingLocalDatasource _localDataSource;

  const BreathingRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, BreathingConfigEntity>> getConfig() async {
    try {
      return Right(_localDataSource.getDefaultConfig());
    } catch (_) {
      return const Left(
        ServerFailure('Could not load the breathing exercise settings.'),
      );
    }
  }
}
