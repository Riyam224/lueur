import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/auth/domain/repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository repository;
  const ForgotPasswordUseCase(this.repository);

  Future<Either<Failure, void>> call({required String email}) {
    return repository.sendPasswordResetEmail(email: email);
  }
}
