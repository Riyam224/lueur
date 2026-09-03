import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lueur/core/networking/api_endpoints.dart';
import 'package:lueur/features/auth/data/datasources/auth_django_datasource.dart';
import 'package:lueur/features/auth/data/datasources/auth_firebase_datasource.dart';
import 'package:lueur/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:lueur/features/auth/domain/entities/user_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockDio extends Mock implements Dio {}

void main() {
  late MockFirebaseAuth firebaseAuth;
  late MockUser user;
  late MockGoogleSignIn googleSignIn;
  late MockDio dio;
  late AuthRepositoryImpl repository;

  const cachedUid = 'uid-1';
  const cachedEmail = 'user@example.com';
  const cachedName = 'User Name';

  setUp(() {
    firebaseAuth = MockFirebaseAuth();
    user = MockUser();
    googleSignIn = MockGoogleSignIn();
    dio = MockDio();

    repository = AuthRepositoryImpl(
      AuthFirebaseDataSource(firebaseAuth: firebaseAuth, googleSignIn: googleSignIn),
      AuthDjangoDatasource(dio),
    );

    when(() => firebaseAuth.currentUser).thenReturn(user);
    when(() => user.uid).thenReturn(cachedUid);
    when(() => user.email).thenReturn(cachedEmail);
    when(() => user.displayName).thenReturn(cachedName);
    when(() => firebaseAuth.signOut()).thenAnswer((_) async {});
    when(() => googleSignIn.signOut()).thenAnswer((_) async => null);
  });

  Response<dynamic> backendSuccessResponse() => Response(
        requestOptions: RequestOptions(path: ApiEndpoints.authVerify),
        statusCode: 200,
        data: {
          'firebase_uid': cachedUid,
          'email': cachedEmail,
          'name': cachedName,
          'is_new_user': false,
        },
      );

  group('checkSession', () {
    test('returns Right(null) when there is no cached Firebase user', () async {
      when(() => firebaseAuth.currentUser).thenReturn(null);

      final result = await repository.checkSession();

      expect(result, const Right<Object, UserEntity?>(null));
      verifyNever(() => firebaseAuth.signOut());
    });

    test('returns the verified backend user when refresh and verify succeed', () async {
      when(() => user.getIdToken(true)).thenAnswer((_) async => 'fresh-token');
      when(() => dio.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => backendSuccessResponse());

      final result = await repository.checkSession();

      final entity = result.fold((_) => null, (u) => u);
      expect(entity?.id, cachedUid);
      expect(entity?.email, cachedEmail);
      verifyNever(() => firebaseAuth.signOut());
    });

    test(
      'signs out and returns Right(null) when Firebase reports the session as invalid',
      () async {
        when(() => user.getIdToken(true)).thenThrow(
          FirebaseAuthException(code: 'user-token-expired'),
        );

        final result = await repository.checkSession();

        expect(result, const Right<Object, UserEntity?>(null));
        verify(() => firebaseAuth.signOut()).called(1);
      },
    );

    test(
      'keeps the cached session on a non-invalidating FirebaseAuthException '
      '(e.g. a network error surfaced through Firebase)',
      () async {
        when(() => user.getIdToken(true)).thenThrow(
          FirebaseAuthException(code: 'network-request-failed'),
        );

        final result = await repository.checkSession();

        final entity = result.fold((_) => null, (u) => u);
        expect(entity?.id, cachedUid);
        expect(entity?.email, cachedEmail);
        verifyNever(() => firebaseAuth.signOut());
      },
    );

    test('signs out and returns Right(null) when the backend rejects the token (401)', () async {
      when(() => user.getIdToken(true)).thenAnswer((_) async => 'fresh-token');
      when(() => dio.post(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.authVerify),
          response: Response(
            requestOptions: RequestOptions(path: ApiEndpoints.authVerify),
            statusCode: 401,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final result = await repository.checkSession();

      expect(result, const Right<Object, UserEntity?>(null));
      verify(() => firebaseAuth.signOut()).called(1);
    });

    test('keeps the cached session on a transport-level DioException (offline)', () async {
      when(() => user.getIdToken(true)).thenAnswer((_) async => 'fresh-token');
      when(() => dio.post(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.authVerify),
          type: DioExceptionType.connectionError,
        ),
      );

      final result = await repository.checkSession();

      final entity = result.fold((_) => null, (u) => u);
      expect(entity?.id, cachedUid);
      expect(entity?.email, cachedEmail);
      verifyNever(() => firebaseAuth.signOut());
    });

    test('keeps the cached session on an unexpected non-Dio, non-Firebase error', () async {
      when(() => user.getIdToken(true)).thenThrow(StateError('boom'));

      final result = await repository.checkSession();

      final entity = result.fold((_) => null, (u) => u);
      expect(entity?.id, cachedUid);
      expect(entity?.email, cachedEmail);
      verifyNever(() => firebaseAuth.signOut());
    });
  });

  group('sendPasswordResetEmail', () {
    test('returns Right(null) when Firebase sends the email successfully',
        () async {
      when(() => firebaseAuth.sendPasswordResetEmail(
            email: any(named: 'email'),
          ),).thenAnswer((_) async {});

      final result =
          await repository.sendPasswordResetEmail(email: cachedEmail);

      expect(result, const Right<Object, void>(null));
    });

    test('maps a FirebaseAuthException to its known error code', () async {
      when(() => firebaseAuth.sendPasswordResetEmail(
            email: any(named: 'email'),
          ),).thenThrow(FirebaseAuthException(code: 'user-not-found'));

      final result =
          await repository.sendPasswordResetEmail(email: cachedEmail);

      final code = result.fold((f) => f.message, (_) => null);
      expect(code, 'user-not-found');
    });

    test(
      'maps a SocketException (offline, no Firebase call reached) to '
      'network-request-failed instead of the generic reset-email-failed code',
      () async {
        when(() => firebaseAuth.sendPasswordResetEmail(
              email: any(named: 'email'),
            ),).thenThrow(const SocketException('Failed host lookup'));

        final result =
            await repository.sendPasswordResetEmail(email: cachedEmail);

        final code = result.fold((f) => f.message, (_) => null);
        expect(code, 'network-request-failed');
      },
    );

    test('maps an unexpected error to the generic reset-email-failed code',
        () async {
      when(() => firebaseAuth.sendPasswordResetEmail(
            email: any(named: 'email'),
          ),).thenThrow(StateError('boom'));

      final result =
          await repository.sendPasswordResetEmail(email: cachedEmail);

      final code = result.fold((f) => f.message, (_) => null);
      expect(code, 'reset-email-failed');
    });
  });

  group('deleteAccount', () {
    test(
      'calls the backend before signing out locally, and returns Right on success',
      () async {
        final callOrder = <String>[];
        when(() => dio.delete(ApiEndpoints.deleteAccount)).thenAnswer((_) async {
          callOrder.add('backend-delete');
          return Response(
            requestOptions: RequestOptions(path: ApiEndpoints.deleteAccount),
            statusCode: 204,
          );
        });
        when(() => firebaseAuth.signOut()).thenAnswer((_) async {
          callOrder.add('firebase-sign-out');
        });

        final result = await repository.deleteAccount();

        expect(result, const Right<Object, void>(null));
        expect(callOrder, ['backend-delete', 'firebase-sign-out']);
      },
    );

    test(
      'returns Left and never signs out locally when the backend call fails',
      () async {
        when(() => dio.delete(ApiEndpoints.deleteAccount)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ApiEndpoints.deleteAccount),
            response: Response(
              requestOptions: RequestOptions(path: ApiEndpoints.deleteAccount),
              statusCode: 502,
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        final result = await repository.deleteAccount();

        final code = result.fold((f) => f.message, (_) => null);
        expect(code, 'delete-account-failed');
        verifyNever(() => firebaseAuth.signOut());
      },
    );
  });
}
