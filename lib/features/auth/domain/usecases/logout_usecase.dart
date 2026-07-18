import 'package:dartz/dartz.dart';
import 'package:lueur_app/core/errors/failures.dart';
import 'package:lueur_app/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;
  const LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.logout();
  }
}
