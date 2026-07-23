import 'package:dartz/dartz.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/auth/domain/entities/user_entity.dart';

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

  /// Restores a locally persisted Firebase session, if any, forcing an ID
  /// token refresh to catch sessions that are locally present but expired
  /// or revoked server-side. Returns `Right(null)` when there is no signed-in
  /// user or the session could not be restored.
  Future<Either<Failure, UserEntity?>> checkSession();

  /// Sends a Firebase password-reset email to [email].
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  });
}
