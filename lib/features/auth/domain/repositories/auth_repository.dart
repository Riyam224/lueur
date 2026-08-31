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

  /// Restores a locally persisted Firebase session, forcing an ID token
  /// refresh to catch expired/revoked sessions. Returns `Right(null)` when none exists or restore fails.
  Future<Either<Failure, UserEntity?>> checkSession();

  /// Sends a Firebase password-reset email to [email].
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  });

  /// Syncs the signed-in user's preferred language to the backend, fire-
  /// and-forget — a [Left] here should be logged and swallowed, not surfaced.
  Future<Either<Failure, void>> syncPreferredLanguage(String languageCode);
}
