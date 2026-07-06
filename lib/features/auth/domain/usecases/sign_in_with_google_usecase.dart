import 'package:ai_therapist_app/core/errors/failures.dart';
import 'package:ai_therapist_app/features/auth/domain/entities/user_entity.dart';
import 'package:ai_therapist_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class SignInWithGoogleUseCase {
  final AuthRepository _repository;
  const SignInWithGoogleUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call() => _repository.signInWithGoogle();
}
