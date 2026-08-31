import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lueur/features/auth/data/datasources/auth_firebase_datasource.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

void main() {
  late MockFirebaseAuth firebaseAuth;
  late MockGoogleSignIn googleSignIn;
  late MockUserCredential credential;
  late AuthFirebaseDataSource dataSource;

  setUp(() {
    firebaseAuth = MockFirebaseAuth();
    googleSignIn = MockGoogleSignIn();
    credential = MockUserCredential();
    dataSource = AuthFirebaseDataSource(
      firebaseAuth: firebaseAuth,
      googleSignIn: googleSignIn,
    );
  });

  group('login', () {
    test(
      'throws a clear StateError instead of a null-check error when '
      'Firebase returns a null user on success',
      () async {
        when(() => credential.user).thenReturn(null);
        when(() => firebaseAuth.signInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),).thenAnswer((_) async => credential);

        expect(
          () => dataSource.login(email: 'a@b.com', password: 'pw'),
          throwsA(isA<StateError>()),
        );
      },
    );
  });

  group('register', () {
    test(
      'throws a clear StateError when the created user is unexpectedly null',
      () async {
        when(() => credential.user).thenReturn(null);
        when(() => firebaseAuth.createUserWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),).thenAnswer((_) async => credential);

        expect(
          () => dataSource.register(
            email: 'a@b.com',
            password: 'pw',
            name: 'Name',
          ),
          throwsA(isA<StateError>()),
        );
      },
    );
  });
}
