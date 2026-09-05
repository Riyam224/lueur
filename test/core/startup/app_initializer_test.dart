import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lueur/core/startup/app_initializer.dart';
import 'package:lueur/features/draw/data/datasources/saved_drawings_local_datasource.dart';
import 'package:lueur/features/draw/data/models/saved_drawing_model.dart';
import 'package:lueur/features/home/data/datasources/mood_local_datasource.dart';
import 'package:lueur/features/sudoku/data/datasources/sudoku_results_local_datasource.dart';
import 'package:lueur/features/sudoku/data/models/sudoku_result_model.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('app_initializer_test');
    Hive.init(tempDir.path);
    await Hive.openBox<String>(MoodLocalDatasource.boxName);
    await Hive.openBox<String>(SavedDrawingsLocalDatasource.boxName);
    await Hive.openBox<String>(SudokuResultsLocalDatasource.boxName);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  test(
      'clearGuestOnlyData wipes guest drawings and sudoku results but leaves authenticated users untouched',
      () async {
    final drawings = SavedDrawingsLocalDatasource();
    final results = SudokuResultsLocalDatasource();
    final drawing = SavedDrawingModel(
      id: 'd1',
      paths: const [],
      createdAt: DateTime(2026),
    );
    final result = SudokuResultModel(
      id: 'r1',
      won: true,
      mistakes: 0,
      durationSeconds: 60,
      completedAt: DateTime(2026),
    );

    await drawings.saveDrawing(drawing, userId: SavedDrawingsLocalDatasource.guestUserId);
    await drawings.saveDrawing(drawing, userId: 'uid-1');
    await results.saveResult(result, userId: SudokuResultsLocalDatasource.guestUserId);
    await results.saveResult(result, userId: 'uid-1');

    await clearGuestOnlyData();

    expect(
      await drawings.getDrawings(userId: SavedDrawingsLocalDatasource.guestUserId),
      isEmpty,
    );
    expect(await drawings.getDrawings(userId: 'uid-1'), hasLength(1));
    expect(
      await results.getResults(userId: SudokuResultsLocalDatasource.guestUserId),
      isEmpty,
    );
    expect(await results.getResults(userId: 'uid-1'), hasLength(1));
  });
}
