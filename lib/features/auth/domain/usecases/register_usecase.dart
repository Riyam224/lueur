import 'package:dartz/dartz.dart';
import 'package:lueur_app/core/errors/failures.dart';
import 'package:lueur_app/features/auth/domain/entities/user_entity.dart';
import 'package:lueur_app/features/auth/domain/repositories/auth_repository.dart';

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
