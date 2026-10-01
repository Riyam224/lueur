import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/features/draw/domain/entities/saved_drawing_entity.dart';
import 'package:lueur/features/draw/presentation/cubit/saved_drawings_state.dart';
import 'package:lueur/features/draw/presentation/screens/saved_drawing_viewer_screen.dart';
import 'package:lueur/features/draw/presentation/widgets/saved_drawing_thumbnail.dart';
import 'package:lueur/features/sudoku/domain/entities/sudoku_result_entity.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_results_state.dart';

import 'profile_test_harness.dart';

SavedDrawingEntity _drawing(String id) =>
    SavedDrawingEntity(id: id, paths: const [], createdAt: DateTime.now());

SudokuResultEntity _result(String id) => SudokuResultEntity(
      id: id,
      won: true,
      mistakes: 0,
      durationSeconds: 65,
      completedAt: DateTime.now(),
    );

List<String> _drawingIds(SavedDrawingsState s) =>
    (s as SavedDrawingsLoaded).drawings.map((d) => d.id).toList();

List<String> _resultIds(SudokuResultsState s) =>
    (s as SudokuResultsLoaded).results.map((r) => r.id).toList();

void main() {
  late ProfileHarness h;

  setUp(() => h = ProfileHarness());
  tearDown(() => h.close());

  group('SavedDrawingsCubit undoable delete', () {
    setUp(() async {
      h.drawingsRepo.next = Right([_drawing('d1'), _drawing('d2')]);
      await h.drawings.loadDrawings();
    });

    test('hideForDelete removes it from the list without deleting', () {
      h.drawings.hideForDelete('d1');

      expect(_drawingIds(h.drawings.state), ['d2']);
      expect(h.drawingsRepo.deletedIds, isEmpty);
    });

    test('undoDelete brings it back in its original place', () async {
      h.drawings.hideForDelete('d1');
      await h.drawings.undoDelete('d1');

      expect(_drawingIds(h.drawings.state), ['d1', 'd2']);
      expect(h.drawingsRepo.deletedIds, isEmpty);
    });

    test('a silent refresh during the undo window keeps it hidden', () async {
      h.drawings.hideForDelete('d1');
      await h.drawings.refresh();

      expect(_drawingIds(h.drawings.state), ['d2']);
    });

    test('commitDelete deletes it for real', () async {
      h.drawings.hideForDelete('d1');
      await h.drawings.commitDelete('d1');

      expect(h.drawingsRepo.deletedIds, ['d1']);
      expect(_drawingIds(h.drawings.state), ['d2']);
    });

    test('commitDelete still deletes after the cubit was closed', () async {
      h.drawings.hideForDelete('d1');
      await h.drawings.close();
      await h.drawings.commitDelete('d1');

      expect(h.drawingsRepo.deletedIds, ['d1']);
    });

    test('commitDelete after an undo does nothing', () async {
      h.drawings.hideForDelete('d1');
      await h.drawings.undoDelete('d1');
      await h.drawings.commitDelete('d1');

      expect(h.drawingsRepo.deletedIds, isEmpty);
    });
  });

  group('SudokuResultsCubit undoable delete', () {
    setUp(() async {
      h.sudokuRepo.next = Right([_result('s1'), _result('s2')]);
      await h.sudoku.loadResults();
    });

    test('hideForDelete removes it from the list without deleting', () {
      h.sudoku.hideForDelete('s1');

      expect(_resultIds(h.sudoku.state), ['s2']);
      expect(h.sudokuRepo.deletedIds, isEmpty);
    });

    test('undoDelete brings it back', () async {
      h.sudoku.hideForDelete('s1');
      await h.sudoku.undoDelete('s1');

      expect(_resultIds(h.sudoku.state), ['s1', 's2']);
    });

    test('a silent refresh during the undo window keeps it hidden', () async {
      h.sudoku.hideForDelete('s1');
      await h.sudoku.refresh();

      expect(_resultIds(h.sudoku.state), ['s2']);
    });

    test('commitDelete deletes it for real', () async {
      h.sudoku.hideForDelete('s1');
      await h.sudoku.commitDelete('s1');

      expect(h.sudokuRepo.deletedIds, ['s1']);
    });
  });

  group('Profile undo snackbar', () {
    late GoRouter router;

    Future<void> pumpProfile(WidgetTester tester) async {
      usePhoneSurface(tester);
      h.drawingsRepo.next = Right([_drawing('d1')]);
      h.sudokuRepo.next = Right([_result('s1')]);
      await h.drawings.loadDrawings();
      await h.sudoku.loadResults();
      await h.quotes.loadQuotes();
      router = h.router();
      addTearDown(router.dispose);
      await tester.pumpWidget(testApp(router: router));
      await tester.pumpAndSettle();
    }

    testWidgets('drawing X then Undo keeps the drawing', (tester) async {
      await pumpProfile(tester);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Drawing deleted'), findsOneWidget);
      expect(_drawingIds(h.drawings.state), isEmpty);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(_drawingIds(h.drawings.state), ['d1']);
      expect(h.drawingsRepo.deletedIds, isEmpty);
    });

    testWidgets('drawing X without Undo deletes once the snackbar closes',
        (tester) async {
      await pumpProfile(tester);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(h.drawingsRepo.deletedIds, isEmpty);

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      expect(find.text('Drawing deleted'), findsNothing);
      expect(h.drawingsRepo.deletedIds, ['d1']);
    });

    testWidgets('the viewer delete button is undoable, even after the '
        'return to Profile triggers a refresh', (tester) async {
      await pumpProfile(tester);

      await tester.tap(find.byType(SavedDrawingThumbnail));
      await tester.pumpAndSettle();
      expect(find.byType(SavedDrawingViewerScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
      await tester.pumpAndSettle();

      expect(find.byType(SavedDrawingViewerScreen), findsNothing);
      expect(find.text('Drawing deleted'), findsOneWidget);
      expect(_drawingIds(h.drawings.state), isEmpty);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(_drawingIds(h.drawings.state), ['d1']);
      expect(h.drawingsRepo.deletedIds, isEmpty);
    });

    testWidgets('Sudoku swipe then Undo keeps the result', (tester) async {
      await pumpProfile(tester);

      final row = find.byType(Dismissible);
      await tester.ensureVisible(row);
      await tester.pumpAndSettle();
      await tester.drag(row, const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(find.text('Result deleted'), findsOneWidget);
      expect(_resultIds(h.sudoku.state), isEmpty);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(_resultIds(h.sudoku.state), ['s1']);
      expect(h.sudokuRepo.deletedIds, isEmpty);
    });
  });
}
