import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lueur/features/home/data/datasources/mood_local_datasource.dart';
import 'package:lueur/features/home/data/models/mood_entry_model.dart';

void main() {
  late Directory tempDir;
  late MoodLocalDatasource datasource;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('mood_local_test');
    Hive.init(tempDir.path);
    await Hive.openBox<String>(MoodLocalDatasource.boxName);
    datasource = MoodLocalDatasource();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  test('guest cleanup deletes only anonymous history', () async {
    final entry = MoodEntryModel(
      id: 1,
      userId: 'uid-1',
      emoji: '🌱',
      thoughts: 'A thought',
      aiResponse: '',
      createdAt: DateTime(2026),
    );
    await datasource.cacheHistory(
      [entry],
      userId: MoodLocalDatasource.guestUserId,
    );
    await datasource.cacheHistory([entry], userId: 'uid-1');

    await datasource.clearGuestHistory();

    expect(
      datasource.getCachedHistory(userId: MoodLocalDatasource.guestUserId),
      isEmpty,
    );
    expect(datasource.getCachedHistory(userId: 'uid-1'), hasLength(1));
  });
}
