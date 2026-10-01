import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/features/home/data/datasources/mood_local_datasource.dart';
import 'package:lueur/features/home/data/datasources/mood_remote_datasource.dart';
import 'package:lueur/features/home/data/models/mood_entry_model.dart';
import 'package:lueur/features/home/data/repositories/mood_repository_impl.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

class _MockLocal extends Mock implements MoodLocalDatasource {}

class _MockRemote extends Mock implements MoodRemoteDatasource {}

MoodEntryEntity _unwrap(dynamic either) =>
    (either as dynamic).getOrElse(() => throw StateError('failed'))
        as MoodEntryEntity;

void main() {
  late _MockAuth auth;
  late _MockLocal local;
  late _MockRemote remote;
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
    auth = _MockAuth();
    local = _MockLocal();
    remote = _MockRemote();
    repository = MoodRepositoryImpl(remote, local, auth);
    when(
      () => local.addEntry(any(), userId: any(named: 'userId')),
    ).thenAnswer((_) async {});
  });

  test('addLocalEntry gives each local entry its own negative id', () async {
    final user = _MockUser();
    when(() => user.uid).thenReturn('uid');
    when(() => auth.currentUser).thenReturn(user);

    final first = _unwrap(
      await repository.addLocalEntry(emoji: '🌱', thoughts: 'a'),
    );
    final second = _unwrap(
      await repository.addLocalEntry(emoji: '🌱', thoughts: 'b'),
    );

    expect(first.id, isNegative);
    expect(second.id, isNegative);
    expect(first.id, isNot(second.id));
  });

  test('guest activity entries get distinct negative ids', () async {
    when(() => auth.currentUser).thenReturn(null);

    final first = _unwrap(
      await repository.logActivity(entryType: 'breathing', payload: {}),
    );
    final second = _unwrap(
      await repository.logActivity(entryType: 'breathing', payload: {}),
    );

    expect(first.id, isNegative);
    expect(first.id, isNot(second.id));
  });

  group('generateResponse with a fallback reply', () {
    MoodEntryModel reply({required bool fallback}) => MoodEntryModel(
          id: 0,
          userId: 'uid',
          emoji: '🌱',
          thoughts: 'hi',
          aiResponse: 'Luna is resting.',
          createdAt: DateTime(2026),
          fallback: fallback,
        );

    setUp(() {
      final user = _MockUser();
      when(() => user.uid).thenReturn('uid');
      when(() => auth.currentUser).thenReturn(user);
    });

    test('is returned for display but never written to the cache', () async {
      when(() => remote.generateResponse(any()))
          .thenAnswer((_) async => reply(fallback: true));

      final entry = _unwrap(
        await repository.generateResponse(emoji: '🌱', thoughts: 'hi'),
      );

      expect(entry.isFallback, isTrue);
      expect(entry.aiResponse, 'Luna is resting.');
      expect(entry.id, isNegative);
      verifyNever(() => local.addEntry(any(), userId: any(named: 'userId')));
    });

    test('a normal reply is still cached', () async {
      when(() => remote.generateResponse(any()))
          .thenAnswer((_) async => reply(fallback: false));

      final entry = _unwrap(
        await repository.generateResponse(emoji: '🌱', thoughts: 'hi'),
      );

      expect(entry.isFallback, isFalse);
      verify(() => local.addEntry(any(), userId: 'uid')).called(1);
    });
  });
}
