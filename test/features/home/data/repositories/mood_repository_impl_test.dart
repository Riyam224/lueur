import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/home/data/datasources/mood_local_datasource.dart';
import 'package:lueur/features/home/data/datasources/mood_remote_datasource.dart';
import 'package:lueur/features/home/data/models/mood_entry_model.dart';
import 'package:lueur/features/home/data/repositories/mood_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockMoodLocalDatasource extends Mock implements MoodLocalDatasource {}

class MockMoodRemoteDatasource extends Mock implements MoodRemoteDatasource {}

void main() {
  late MockFirebaseAuth firebaseAuth;
  late MockMoodLocalDatasource local;
  late MockMoodRemoteDatasource remote;
  late MoodRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      MoodEntryModel(
        id: 0,
        userId: '',
        emoji: '',
        thoughts: '',
        aiResponse: '',
        createdAt: DateTime(2026),
      ),
    );
  });

  setUp(() {
    firebaseAuth = MockFirebaseAuth();
    local = MockMoodLocalDatasource();
    remote = MockMoodRemoteDatasource();
    repository = MoodRepositoryImpl(remote, local, firebaseAuth);
  });

  test('guest history reads local storage without calling Django', () async {
    when(() => firebaseAuth.currentUser).thenReturn(null);
    when(
      () => local.getCachedHistory(
        userId: MoodLocalDatasource.guestUserId,
      ),
    ).thenAnswer((_) async => []);

    final result = await repository.getHistory();

    expect(result.getOrElse(() => throw StateError('failed')), isEmpty);
    verifyNever(() => remote.getHistory(userId: any(named: 'userId')));
  });

  test(
      'guest Luna request is blocked before reaching Django, with no local caching',
      () async {
    when(() => firebaseAuth.currentUser).thenReturn(null);

    final result =
        await repository.generateResponse(emoji: '🌱', thoughts: 'Trying Luna');

    expect(result.isLeft(), isTrue);
    expect(
      result.fold((f) => f, (_) => null),
      isA<GuestSignInRequiredFailure>(),
    );
    verifyNever(() => remote.generateResponse(any()));
    verifyNever(() => local.addEntry(any(), userId: any(named: 'userId')));
  });

  test('authenticated Luna request is unaffected and still calls Django',
      () async {
    when(() => firebaseAuth.currentUser).thenReturn(MockUser());
    final response = MoodEntryModel(
      id: 1,
      userId: 'uid',
      emoji: '🌱',
      thoughts: 'Trying Luna',
      aiResponse: 'I am here.',
      createdAt: DateTime(2026),
    );
    when(() => remote.generateResponse(any()))
        .thenAnswer((_) async => response);
    when(
      () => local.addEntry(response, userId: 'uid'),
    ).thenAnswer((_) async {});

    final result =
        await repository.generateResponse(emoji: '🌱', thoughts: 'Trying Luna');

    expect(result.isRight(), isTrue);
    final body = verify(() => remote.generateResponse(captureAny()))
        .captured
        .single as Map<String, dynamic>;
    expect(body, containsPair('emoji', '🌱'));
    expect(body, containsPair('thoughts', 'Trying Luna'));
    expect(body, containsPair('user_id', 'uid'));
  });

  test('authenticated delete calls Django then clears local cache', () async {
    when(() => firebaseAuth.currentUser).thenReturn(MockUser());
    when(() => remote.deleteEntry('1')).thenAnswer((_) async {});
    when(() => local.deleteEntry(1, userId: 'uid')).thenAnswer((_) async {});

    final result = await repository.deleteEntry(1);

    expect(result.isRight(), isTrue);
    verify(() => remote.deleteEntry('1')).called(1);
    verify(() => local.deleteEntry(1, userId: 'uid')).called(1);
  });

  test('authenticated delete leaves local cache untouched when Django fails',
      () async {
    when(() => firebaseAuth.currentUser).thenReturn(MockUser());
    when(() => remote.deleteEntry('1')).thenThrow(Exception('network down'));

    final result = await repository.deleteEntry(1);

    expect(result.isLeft(), isTrue);
    verifyNever(() => local.deleteEntry(any(), userId: any(named: 'userId')));
  });

  test('guest delete skips Django and only clears local cache', () async {
    when(() => firebaseAuth.currentUser).thenReturn(null);
    when(() => local.deleteEntry(1, userId: '')).thenAnswer((_) async {});

    final result = await repository.deleteEntry(1);

    expect(result.isRight(), isTrue);
    verifyNever(() => remote.deleteEntry(any()));
    verify(() => local.deleteEntry(1, userId: '')).called(1);
  });

  test('authenticated delete-all calls Django then clears local cache',
      () async {
    when(() => firebaseAuth.currentUser).thenReturn(MockUser());
    when(() => remote.deleteAllEntries()).thenAnswer((_) async => 3);
    when(() => local.deleteAllEntries(userId: 'uid')).thenAnswer((_) async {});

    final result = await repository.deleteAllEntries();

    expect(result.isRight(), isTrue);
    verify(() => remote.deleteAllEntries()).called(1);
    verify(() => local.deleteAllEntries(userId: 'uid')).called(1);
  });

  test(
      'authenticated delete-all leaves local cache untouched when Django fails',
      () async {
    when(() => firebaseAuth.currentUser).thenReturn(MockUser());
    when(() => remote.deleteAllEntries()).thenThrow(Exception('network down'));

    final result = await repository.deleteAllEntries();

    expect(result.isLeft(), isTrue);
    verifyNever(() => local.deleteAllEntries(userId: any(named: 'userId')));
  });

  test('guest delete-all skips Django and only clears local cache', () async {
    when(() => firebaseAuth.currentUser).thenReturn(null);
    when(() => local.deleteAllEntries(userId: '')).thenAnswer((_) async {});

    final result = await repository.deleteAllEntries();

    expect(result.isRight(), isTrue);
    verifyNever(() => remote.deleteAllEntries());
    verify(() => local.deleteAllEntries(userId: '')).called(1);
  });

  test('delete returns failure when local cache clear fails after Django succeeds',
      () async {
    when(() => firebaseAuth.currentUser).thenReturn(MockUser());
    when(() => remote.deleteEntry('1')).thenAnswer((_) async {});
    when(() => local.deleteEntry(1, userId: 'uid'))
        .thenThrow(Exception('hive error'));

    final result = await repository.deleteEntry(1);

    expect(result.isLeft(), isTrue);
  });

  test(
      'guest logActivity skips Django entirely and returns success silently',
      () async {
    when(() => firebaseAuth.currentUser).thenReturn(null);

    final result = await repository.logActivity(
      entryType: 'breathing',
      payload: {'duration_seconds': 240},
    );

    expect(result.isRight(), isTrue);
    verifyNever(
      () => remote.postActivity(
        entryType: any(named: 'entryType'),
        payload: any(named: 'payload'),
      ),
    );
    verifyNever(() => local.addEntry(any(), userId: any(named: 'userId')));
  });

  test('authenticated logActivity is unaffected and still calls Django',
      () async {
    when(() => firebaseAuth.currentUser).thenReturn(MockUser());
    final response = MoodEntryModel(
      id: 1,
      userId: 'uid',
      emoji: '',
      thoughts: '',
      aiResponse: '',
      createdAt: DateTime(2026),
      entryType: 'breathing',
      payload: const {'duration_seconds': 240},
    );
    when(
      () => remote.postActivity(
        entryType: 'breathing',
        payload: {'duration_seconds': 240},
      ),
    ).thenAnswer((_) async => response);
    when(() => local.addEntry(response, userId: 'uid'))
        .thenAnswer((_) async {});

    final result = await repository.logActivity(
      entryType: 'breathing',
      payload: {'duration_seconds': 240},
    );

    expect(result.isRight(), isTrue);
    verify(
      () => remote.postActivity(
        entryType: 'breathing',
        payload: {'duration_seconds': 240},
      ),
    ).called(1);
    verify(() => local.addEntry(response, userId: 'uid')).called(1);
  });
}

class MockUser extends Mock implements User {
  @override
  String get uid => 'uid';
}
