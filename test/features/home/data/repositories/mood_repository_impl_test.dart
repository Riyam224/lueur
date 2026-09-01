import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
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

  test('guest Luna request omits user_id but still calls Django', () async {
    when(() => firebaseAuth.currentUser).thenReturn(null);
    final response = MoodEntryModel(
      id: 1,
      userId: '',
      emoji: '🌱',
      thoughts: 'Trying Luna',
      aiResponse: 'I am here.',
      createdAt: DateTime(2026),
    );
    when(() => remote.generateResponse(any()))
        .thenAnswer((_) async => response);
    when(
      () => local.addEntry(
        response,
        userId: MoodLocalDatasource.guestUserId,
      ),
    ).thenAnswer((_) async {});

    await repository.generateResponse(emoji: '🌱', thoughts: 'Trying Luna');

    final body = verify(() => remote.generateResponse(captureAny()))
        .captured
        .single as Map<String, dynamic>;
    expect(body, containsPair('emoji', '🌱'));
    expect(body, containsPair('thoughts', 'Trying Luna'));
    expect(body, isNot(contains('user_id')));
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
}

class MockUser extends Mock implements User {
  @override
  String get uid => 'uid';
}
