import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/auth/data/datasources/auth_django_datasource.dart';
import 'package:lueur/features/auth/data/datasources/auth_firebase_datasource.dart';
import 'package:lueur/features/auth/domain/entities/user_entity.dart';
import 'package:lueur/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthFirebaseDataSource _firebaseDataSource;
  final AuthDjangoDatasource _djangoDataSource;
  final Logger _logger = Logger();

  AuthRepositoryImpl(this._firebaseDataSource, this._djangoDataSource);

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final (:user, :idToken) = await _firebaseDataSource.login(
        email: email,
        password: password,
      );
      final djangoUser = await _djangoDataSource.verifyToken(idToken);
      return Right(djangoUser);
    } on FirebaseAuthException catch (e) {
      return Left(ServerFailure(_mapFirebaseError(e)));
    } catch (_) {
      return const Left(ServerFailure('Login failed. Please try again.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final (:user, :idToken) = await _firebaseDataSource.register(
        email: email,
        password: password,
        name: name,
      );
      final djangoUser = await _djangoDataSource.verifyToken(idToken);
      return Right(djangoUser);
    } on FirebaseAuthException catch (e) {
      return Left(ServerFailure(_mapFirebaseError(e)));
    } catch (_) {
      return const Left(ServerFailure('Registration failed. Please try again.'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _firebaseDataSource.logout();
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure('Logout failed. Please try again.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final (:user, :idToken) = await _firebaseDataSource.signInWithGoogle();
      final djangoUser = await _djangoDataSource.verifyToken(idToken);
      return Right(djangoUser);
    } on GoogleSignInCancelledException {
      return const Left(CancellationFailure());
    } on FirebaseAuthException catch (e) {
      _logger.e('Google sign-in Firebase error: ${e.code} ${e.message}');
      return Left(ServerFailure(_mapFirebaseError(e)));
    } on DioException catch (e) {
      _logger.e(
        'Google sign-in backend verify error: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
      );
      return const Left(
        ServerFailure(
          'Signed in with Google, but syncing your account failed. Please try again.',
        ),
      );
    } catch (e, st) {
      _logger.e('Google sign-in unexpected error', error: e, stackTrace: st);
      return const Left(ServerFailure('Google sign-in failed. Please try again.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> checkSession() async {
    final user = _firebaseDataSource.currentUser;
    if (user == null) return const Right(null);

    try {
      final idToken = await _firebaseDataSource.refreshIdToken();
      final djangoUser = await _djangoDataSource.verifyToken(idToken);
      return Right(djangoUser);
    } catch (e, st) {
      _logger.e(
        'Session restore failed, signing out',
        error: e,
        stackTrace: st,
      );
      await _firebaseDataSource.logout();
      return const Right(null);
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' => 'No account found with this email.',
      'wrong-password' || 'invalid-credential' => 'Incorrect email or password.',
      'email-already-in-use' => 'An account already exists with this email.',
      'invalid-email' => 'Please enter a valid email address.',
      'weak-password' => 'Password is too weak. Use at least 6 characters.',
      'user-disabled' => 'This account has been disabled.',
      'too-many-requests' => 'Too many attempts. Please try again later.',
      'network-request-failed' => 'No internet connection. Please check your network.',
      _ => e.message ?? 'Authentication failed. Please try again.',
    };
  }
}
