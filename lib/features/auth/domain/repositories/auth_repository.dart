import 'package:ai_therapist_app/core/errors/failures.dart';
import 'package:ai_therapist_app/features/auth/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String name,
  });

  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserEntity>> signInWithGoogle();
}
