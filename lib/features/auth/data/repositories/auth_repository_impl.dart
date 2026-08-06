import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/auth/data/datasources/auth_django_datasource.dart';
import 'package:lueur/features/auth/data/datasources/auth_firebase_datasource.dart';
import 'package:lueur/features/auth/data/models/django_user_model.dart';
import 'package:lueur/features/auth/data/models/user_model.dart';
import 'package:lueur/features/auth/domain/entities/user_entity.dart';
import 'package:lueur/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthFirebaseDataSource _firebaseDataSource;
  final AuthDjangoDatasource _djangoDataSource;
  final Logger _logger = Logger();

  AuthRepositoryImpl(this._firebaseDataSource, this._djangoDataSource);

  /// Verifies the Firebase token with the backend and, only the first time
  /// this account is ever created, optimistically syncs an Arabic device
  /// locale so a new Arabic-speaking user isn't stuck on the "en" default
  /// until they find language settings. Fire-and-forget — never blocks
  /// sign-in/registration and never surfaces a sync failure to the user.
  Future<DjangoUserModel> _verifyTokenAndSyncInitialLanguage(
    String idToken,
  ) async {
    final result = await _djangoDataSource.verifyToken(idToken);
    if (result.isNewUser && Platform.localeName.startsWith('ar')) {
      unawaited(syncPreferredLanguage('ar'));
    }
    return result.user;
  }

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
      final djangoUser = await _verifyTokenAndSyncInitialLanguage(idToken);
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
      final djangoUser = await _verifyTokenAndSyncInitialLanguage(idToken);
      return Right(djangoUser);
    } on FirebaseAuthException catch (e) {
      return Left(ServerFailure(_mapFirebaseError(e)));
    } catch (_) {
      return const Left(
        ServerFailure('Registration failed. Please try again.'),
      );
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
      final djangoUser = await _verifyTokenAndSyncInitialLanguage(idToken);
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
      return const Left(
        ServerFailure('Google sign-in failed. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> checkSession() async {
    final user = _firebaseDataSource.currentUser;
    if (user == null) return const Right(null);

    try {
      final djangoUser = await (() async {
        final idToken = await _firebaseDataSource.refreshIdToken();
        return _verifyTokenAndSyncInitialLanguage(idToken);
      })()
          .timeout(const Duration(seconds: 8));
      return Right(djangoUser);
    } on FirebaseAuthException catch (e, st) {
      // Only a genuine "this session is no longer valid" response from
      // Firebase should sign the user out. Anything else (network error,
      // backend hiccup) must not — we can't tell "no internet" apart from
      // "no valid session" here, so default to trusting the locally cached
      // session and let the user keep using the app.
      if (_isInvalidSessionError(e)) {
        _logger.e(
          'Session invalid, signing out',
          error: e,
          stackTrace: st,
        );
        await _firebaseDataSource.logout();
        return const Right(null);
      }
      _logger.w('Session restore failed (non-fatal): ${e.code}');
      return Right(UserModel.fromFirebaseUser(user));
    } on DioException catch (e, st) {
      // The backend explicitly rejecting the token (banned/deleted account,
      // revoked access) is a genuine "no longer valid" signal, unlike a
      // timeout or connection failure — only the latter should be trusted
      // as "probably just offline."
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) {
        _logger.e(
          'Backend rejected session, signing out',
          error: e,
          stackTrace: st,
        );
        await _firebaseDataSource.logout();
        return const Right(null);
      }
      _logger.w(
        'Session restore failed (non-fatal, likely network): ${e.message}',
      );
      return Right(UserModel.fromFirebaseUser(user));
    } catch (e, st) {
      _logger.w(
        'Session restore failed (non-fatal, likely network)',
        error: e,
        stackTrace: st,
      );
      return Right(UserModel.fromFirebaseUser(user));
    }
  }

  bool _isInvalidSessionError(FirebaseAuthException e) {
    return const {
      'invalid-user-token',
      'user-disabled',
      'user-token-expired',
      'user-not-found',
      'invalid-credential',
    }.contains(e.code);
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _firebaseDataSource.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(ServerFailure(_mapFirebaseError(e)));
    } catch (_) {
      return const Left(
        ServerFailure('Could not send reset email. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> syncPreferredLanguage(
    String languageCode,
  ) async {
    try {
      await _djangoDataSource.updatePreferredLanguage(languageCode);
      return const Right(null);
    } catch (e) {
      return const Left(
        ServerFailure('Failed to sync preferred language.'),
      );
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' => 'No account found with this email.',
      'wrong-password' ||
      'invalid-credential' =>
        'Incorrect email or password.',
      'email-already-in-use' => 'An account already exists with this email.',
      'invalid-email' => 'Please enter a valid email address.',
      'weak-password' => 'Password is too weak. Use at least 6 characters.',
      'user-disabled' => 'This account has been disabled.',
      'too-many-requests' => 'Too many attempts. Please try again later.',
      'network-request-failed' =>
        'No internet connection. Please check your network.',
      _ => e.message ?? 'Authentication failed. Please try again.',
    };
  }
}
