import 'package:ai_therapist_app/core/errors/failures.dart';
import 'package:ai_therapist_app/features/auth/domain/entities/user_entity.dart';
import 'package:ai_therapist_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class RegisterUseCase {
  final AuthRepository repository;
  const RegisterUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required String name,
  }) {
    return repository.register(email: email, password: password, name: name);
  }
}
