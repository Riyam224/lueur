import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lueur/features/home/data/datasources/mood_local_datasource.dart';
import 'package:lueur/features/home/data/models/mood_entry_model.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';

MoodEntryModel _entry(int id, String thoughts, {DateTime? at}) => MoodEntryModel(
      id: id,
      userId: 'uid',
      emoji: '🌱',
      thoughts: thoughts,
      aiResponse: '',
      createdAt: at ?? DateTime(2026, 10, 2),
    );

MoodEntryEntity _target(MoodEntryModel m) => m.toEntity();

void main() {
  late Directory tempDir;
  late MoodLocalDatasource datasource;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('mood_local_delete_test');
    Hive.init(tempDir.path);
    await Hive.openBox<String>(MoodLocalDatasource.boxName);
    datasource = MoodLocalDatasource();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  test('deleting id 0 removes one id-0 entry, not all of them', () async {
    await datasource.cacheHistory(
      [_entry(0, 'a'), _entry(0, 'b'), _entry(7, 'c')],
      userId: 'uid',
    );

    await datasource.deleteEntry(_target(_entry(0, 'a')), userId: 'uid');

    final left = await datasource.getCachedHistory(userId: 'uid');
    expect(left.map((e) => e.thoughts), ['b', 'c']);
  });

  test('deleting the second of two id-0 entries removes it, keeps the first',
      () async {
    await datasource.cacheHistory(
      [_entry(0, 'first'), _entry(0, 'second'), _entry(7, 'c')],
      userId: 'uid',
    );

    await datasource.deleteEntry(_target(_entry(0, 'second')), userId: 'uid');

    final left = await datasource.getCachedHistory(userId: 'uid');
    expect(left.map((e) => e.thoughts), ['first', 'c']);
  });

  test('id-0 entries are told apart by createdAt too', () async {
    await datasource.cacheHistory(
      [
        _entry(0, 'same', at: DateTime(2026, 10, 3)),
        _entry(0, 'same', at: DateTime(2026, 10, 2)),
      ],
      userId: 'uid',
    );

    await datasource.deleteEntry(
      _target(_entry(0, 'same', at: DateTime(2026, 10, 2))),
      userId: 'uid',
    );

    final left = await datasource.getCachedHistory(userId: 'uid');
    expect(left.map((e) => e.createdAt), [DateTime(2026, 10, 3)]);
  });

  test('a negative id entry is removed by its secondary key', () async {
    await datasource.cacheHistory(
      [_entry(-1, 'a'), _entry(-1, 'b')],
      userId: 'uid',
    );

    await datasource.deleteEntry(_target(_entry(-1, 'b')), userId: 'uid');

    final left = await datasource.getCachedHistory(userId: 'uid');
    expect(left.map((e) => e.thoughts), ['a']);
  });

  test('deleting a real id removes exactly that entry', () async {
    await datasource.cacheHistory(
      [_entry(0, 'a'), _entry(7, 'c'), _entry(8, 'd')],
      userId: 'uid',
    );

    await datasource.deleteEntry(_target(_entry(7, 'c')), userId: 'uid');

    final left = await datasource.getCachedHistory(userId: 'uid');
    expect(left.map((e) => e.id), [0, 8]);
  });

  test('deleting an unknown id changes nothing', () async {
    await datasource.cacheHistory([_entry(7, 'c')], userId: 'uid');

    await datasource.deleteEntry(_target(_entry(99, 'x')), userId: 'uid');

    final left = await datasource.getCachedHistory(userId: 'uid');
    expect(left.map((e) => e.id), [7]);
  });

  test('adding a second local entry keeps the first one', () async {
    await datasource.addEntry(_entry(-5, 'first'), userId: 'uid');
    await datasource.addEntry(_entry(-6, 'second'), userId: 'uid');

    final cached = await datasource.getCachedHistory(userId: 'uid');
    expect(cached.map((e) => e.thoughts), ['second', 'first']);
  });

  test('setCardColor and setPinned change only the entry with that id',
      () async {
    await datasource.cacheHistory(
      [_entry(-5, 'a'), _entry(-6, 'b')],
      userId: 'uid',
    );

    await datasource.setCardColor(-6, 'blue', userId: 'uid');
    await datasource.setPinned(-5, true, userId: 'uid');

    final cached = await datasource.getCachedHistory(userId: 'uid');
    final a = cached.firstWhere((e) => e.id == -5);
    final b = cached.firstWhere((e) => e.id == -6);
    expect([a.cardColor, a.pinned], [null, true]);
    expect([b.cardColor, b.pinned], ['blue', false]);
  });
}
