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
    ).thenReturn([]);

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
}
