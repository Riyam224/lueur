import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/draw/domain/entities/saved_drawing_entity.dart';
import 'package:lueur/features/sudoku/domain/entities/sudoku_result_entity.dart';

import 'profile_test_harness.dart';

void main() {
  late ProfileHarness h;

  setUp(() => h = ProfileHarness());
  tearDown(() => h.close());

  Future<void> pumpProfile(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) async {
    usePhoneSurface(tester);
    final router = h.router();
    addTearDown(router.dispose);
    await tester.pumpWidget(testApp(router: router, locale: locale));
    await tester.pumpAndSettle();
  }

  group('saved quotes section', () {
    testWidgets('shows a loading message before the first load',
        (tester) async {
      await pumpProfile(tester);

      expect(find.text('Loading saved quotes...'), findsOneWidget);
    });

    testWidgets('shows an error message instead of nothing on failure',
        (tester) async {
      h.quotesRepo.next = const Left(ServerFailure('boom'));
      await h.quotes.loadQuotes();
      await pumpProfile(tester);

      expect(
        find.text("Luna couldn't load your saved quotes just now."),
        findsOneWidget,
      );
    });

    testWidgets('shows the empty state once loaded with no quotes',
        (tester) async {
      await h.quotes.loadQuotes();
      await pumpProfile(tester);

      expect(
        find.text('Quotes you save stay here, on this device.'),
        findsOneWidget,
      );
    });
  });

  group('RTL layout', () {
    Future<void> seed() async {
      h.drawingsRepo.next = Right([
        SavedDrawingEntity(
          id: 'd1',
          paths: const [],
          createdAt: DateTime.now(),
        ),
      ]);
      h.sudokuRepo.next = Right([
        SudokuResultEntity(
          id: 's1',
          won: true,
          mistakes: 0,
          durationSeconds: 65,
          completedAt: DateTime.now(),
        ),
      ]);
      await h.drawings.loadDrawings();
      await h.sudoku.loadResults();
    }

    double centerX(WidgetTester tester, Finder f) => tester.getCenter(f).dx;

    for (final (locale, isRtl) in [
      (const Locale('ar'), true),
      (const Locale('en'), false),
    ]) {
      testWidgets(
          'drawing delete button sits at the leading-end corner '
          '(${locale.languageCode})', (tester) async {
        await seed();
        await pumpProfile(tester, locale: locale);

        final button = find.byIcon(Icons.close_rounded);
        expect(button, findsOneWidget);
        final tile = find.ancestor(of: button, matching: find.byType(Stack)).first;
        final onEnd = isRtl
            ? centerX(tester, button) < centerX(tester, tile)
            : centerX(tester, button) > centerX(tester, tile);
        expect(onEnd, isTrue);
      });

      testWidgets(
          'Sudoku swipe-to-delete icon shows on the revealed side '
          '(${locale.languageCode})', (tester) async {
        await seed();
        await pumpProfile(tester, locale: locale);

        final row = find.byType(Dismissible);
        await tester.ensureVisible(row);
        await tester.pumpAndSettle();
        // endToStart: drag toward the start edge (right in RTL, left in LTR).
        final gesture = await tester.startGesture(tester.getCenter(row));
        // First move only crosses the touch slop; the second one drags.
        final step = Offset(isRtl ? 30 : -30, 0);
        await gesture.moveBy(step);
        await tester.pump();
        await gesture.moveBy(step * 4);
        await tester.pump();

        // Scoped to the row — the journal-data section has the same icon.
        final icon = find.descendant(
          of: row,
          matching: find.byIcon(Icons.delete_outline_rounded),
        );
        final onRevealedSide = isRtl
            ? centerX(tester, icon) < centerX(tester, row)
            : centerX(tester, icon) > centerX(tester, row);
        expect(onRevealedSide, isTrue);

        await gesture.moveBy(-step * 5);
        await gesture.up();
        await tester.pumpAndSettle();
      });
    }
  });
}
