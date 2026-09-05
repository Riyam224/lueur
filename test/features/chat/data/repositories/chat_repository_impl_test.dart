import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:lueur/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:lueur/features/chat/domain/entities/chat_message.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockChatRemoteDataSource extends Mock implements ChatRemoteDataSource {}

class MockUser extends Mock implements User {
  @override
  String get uid => 'uid';
}

void main() {
  late MockFirebaseAuth firebaseAuth;
  late MockChatRemoteDataSource remote;
  late ChatRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(<ChatMessage>[]);
  });

  setUp(() {
    firebaseAuth = MockFirebaseAuth();
    remote = MockChatRemoteDataSource();
    repository = ChatRepositoryImpl(
      remoteDataSource: remote,
      firebaseAuth: firebaseAuth,
    );
  });

  test(
      'guest sendMessage is blocked before reaching Django, with no network call',
      () async {
    when(() => firebaseAuth.currentUser).thenReturn(null);

    final result = await repository.sendMessage(
      userId: '',
      emoji: '🌱',
      thoughts: 'Trying Luna',
      history: const [],
    );

    expect(result.isLeft(), isTrue);
    expect(
      result.fold((f) => f, (_) => null),
      isA<GuestSignInRequiredFailure>(),
    );
    verifyNever(
      () => remote.sendMessage(
        userId: any(named: 'userId'),
        emoji: any(named: 'emoji'),
        thoughts: any(named: 'thoughts'),
        history: any(named: 'history'),
      ),
    );
  });

  test('authenticated sendMessage is unaffected and still calls Django',
      () async {
    when(() => firebaseAuth.currentUser).thenReturn(MockUser());
    when(
      () => remote.sendMessage(
        userId: 'uid',
        emoji: '🌱',
        thoughts: 'Trying Luna',
        history: const [],
      ),
    ).thenAnswer((_) async => 'I am here.');

    final result = await repository.sendMessage(
      userId: 'uid',
      emoji: '🌱',
      thoughts: 'Trying Luna',
      history: const [],
    );

    expect(result.getOrElse(() => throw StateError('failed')), 'I am here.');
    verify(
      () => remote.sendMessage(
        userId: 'uid',
        emoji: '🌱',
        thoughts: 'Trying Luna',
        history: const [],
      ),
    ).called(1);
  });
}
