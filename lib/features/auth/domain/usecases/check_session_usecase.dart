import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/auth/domain/entities/user_entity.dart';
import 'package:lueur/features/auth/domain/repositories/auth_repository.dart';

class CheckSessionUseCase {
  final AuthRepository repository;
  const CheckSessionUseCase(this.repository);

  Future<Either<Failure, UserEntity?>> call() {
    return repository.checkSession();
  }
}
