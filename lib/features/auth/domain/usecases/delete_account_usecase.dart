import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/auth/domain/repositories/auth_repository.dart';

class DeleteAccountUseCase {
  final AuthRepository repository;
  const DeleteAccountUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.deleteAccount();
  }
}
