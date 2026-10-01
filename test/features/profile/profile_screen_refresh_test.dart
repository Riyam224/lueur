import 'dart:async';


import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/features/draw/domain/entities/saved_drawing_entity.dart';
import 'package:lueur/features/draw/presentation/cubit/saved_drawings_state.dart';
import 'package:lueur/features/sudoku/domain/entities/sudoku_result_entity.dart';
import 'package:lueur/features/sudoku/presentation/cubit/sudoku_results_state.dart';

import 'profile_test_harness.dart';

// Stream subscriptions here are cancelled without `await`: cancel() returns a
// root-zone future (dart:_internal `nullFuture`), and awaiting it resumes the
// test body outside flutter_test's fake-async zone — the next pump (or the
// framework's own teardown pump) then waits forever. Every event is already
// collected synchronously before the cancel, so nothing is lost.
void main() {
  late ProfileHarness h;
  late GoRouter router;

  setUp(() {
    h = ProfileHarness();
    router = h.router();
  });

  tearDown(() async {
    router.dispose();
    await h.close();
  });

  Future<void> pumpProfile(WidgetTester tester) async {
    usePhoneSurface(tester);
    await h.drawings.loadDrawings();
    await h.sudoku.loadResults();
    await h.quotes.loadQuotes();
    await tester.pumpWidget(testApp(router: router));
    await tester.pumpAndSettle();
  }

  Future<void> leaveAndComeBack(WidgetTester tester) async {
    unawaited(router.push('/other'));
    await tester.pumpAndSettle();
    router.pop();
    await tester.pumpAndSettle();
  }

  testWidgets('a drawing saved elsewhere shows up on returning to Profile',
      (tester) async {
    await pumpProfile(tester);
    expect(find.text('Your creativity has a home here.'), findsOneWidget);

    h.drawingsRepo.next = Right([
      SavedDrawingEntity(id: 'd1', paths: const [], createdAt: DateTime.now()),
    ]);
    await leaveAndComeBack(tester);

    expect(find.text('Your creativity has a home here.'), findsNothing);
    expect((h.drawings.state as SavedDrawingsLoaded).drawings, hasLength(1));
  });

  testWidgets('a Sudoku result saved elsewhere shows up on returning',
      (tester) async {
    await pumpProfile(tester);

    h.sudokuRepo.next = Right([
      SudokuResultEntity(
        id: 's1',
        won: true,
        mistakes: 0,
        durationSeconds: 65,
        completedAt: DateTime.now(),
      ),
    ]);
    await leaveAndComeBack(tester);

    expect(find.text('Solved it'), findsOneWidget);
  });

  testWidgets('returning to Profile never shows a Loading state',
      (tester) async {
    await pumpProfile(tester);
    h.drawingsRepo.next = Right([
      SavedDrawingEntity(id: 'd1', paths: const [], createdAt: DateTime.now()),
    ]);
    final drawingStates = <SavedDrawingsState>[];
    final sudokuStates = <SudokuResultsState>[];
    final subs = [
      h.drawings.stream.listen(drawingStates.add),
      h.sudoku.stream.listen(sudokuStates.add),
    ];

    await leaveAndComeBack(tester);
    for (final s in subs) {
      unawaited(s.cancel());
    }

    expect(drawingStates, [isA<SavedDrawingsLoaded>()]);
    expect(sudokuStates.whereType<SudokuResultsLoading>(), isEmpty);
  });

  testWidgets('no reload while Profile stays visible', (tester) async {
    await pumpProfile(tester);
    final drawingStates = <SavedDrawingsState>[];
    final sub = h.drawings.stream.listen(drawingStates.add);

    await tester.pump(const Duration(seconds: 1));
    unawaited(sub.cancel());

    expect(drawingStates, isEmpty);
  });

  testWidgets('the route listener is removed when Profile is disposed',
      (tester) async {
    await pumpProfile(tester);

    await tester.pumpWidget(const SizedBox());
    final drawingStates = <SavedDrawingsState>[];
    final sub = h.drawings.stream.listen(drawingStates.add);
    router.go('/other');
    router.go('/profile');
    await tester.pump();
    unawaited(sub.cancel());

    expect(drawingStates, isEmpty);
  });
}
