import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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

  /// Verifies the Firebase token and, only on first account creation,
  /// optimistically syncs an Arabic device locale — fire-and-forget, never blocks sign-in or surfaces a sync failure.
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
      return const Left(ServerFailure('login-failed'));
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
      return const Left(ServerFailure('register-failed'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _firebaseDataSource.logout();
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure('logout-failed'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      // Backend-first while the Firebase session is still active, so the
      // auth interceptor attaches a valid token; the backend hard-deletes
      // the Firebase user server-side, so no client-side User.delete() call.
      await _djangoDataSource.deleteAccount();
      // Local-only sign-out to clear the cached Firebase/Google session;
      // never a delete() call against an already-deleted Firebase user.
      await _firebaseDataSource.logout();
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure('delete-account-failed'));
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
      return const Left(ServerFailure('google-sync-failed'));
    } catch (e, st) {
      _logger.e('Google sign-in unexpected error', error: e, stackTrace: st);
      return const Left(ServerFailure('google-sign-in-failed'));
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
      // Only a genuine "session no longer valid" response should sign the
      // user out — we can't tell "no internet" apart from "no valid session" here, so default to trusting the cached session.
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
      // The backend explicitly rejecting the token is a genuine "no longer
      // valid" signal, unlike a timeout/connection failure, which is trusted as "probably just offline."
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
    } on SocketException {
      return const Left(ServerFailure('network-request-failed'));
    } catch (_) {
      return const Left(ServerFailure('reset-email-failed'));
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
      // Local debug visibility only — never the language value itself, and
      // gated on kDebugMode so nothing is emitted (or transmitted) in release
      // builds, since debugPrint alone is not stripped from release binaries.
      if (kDebugMode) {
        debugPrint('syncPreferredLanguage failed: ${e.runtimeType}: $e');
      }
      return const Left(ServerFailure('sync-language-failed'));
    }
  }

  /// Maps a Firebase error to a stable, unlocalized failure code, never a
  /// display string — the presentation layer localizes it via AppLocalizations.
  String _mapFirebaseError(FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' => 'user-not-found',
      'wrong-password' || 'invalid-credential' => 'wrong-password',
      'email-already-in-use' => 'email-already-in-use',
      'invalid-email' => 'invalid-email',
      'weak-password' => 'weak-password',
      'user-disabled' => 'user-disabled',
      'too-many-requests' => 'too-many-requests',
      'network-request-failed' => 'network-request-failed',
      _ => _unmappedFirebaseError(e),
    };
  }

  String _unmappedFirebaseError(FirebaseAuthException e) {
    _logger.w('Unmapped FirebaseAuthException: ${e.code} — ${e.message}');
    return 'auth-generic';
  }
}
