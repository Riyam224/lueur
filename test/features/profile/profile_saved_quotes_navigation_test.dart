import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/features/profile/presentation/screens/profile_screen.dart';
import 'package:lueur/features/quotes/domain/entities/saved_quote_entity.dart';
import 'package:lueur/features/quotes/presentation/screens/saved_quotes_screen.dart';

import 'profile_test_harness.dart';

SavedQuoteEntity _quote(String id, String text) =>
    SavedQuoteEntity(id: id, text: text, savedAt: DateTime.now());

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

  Future<void> pumpProfileWithQuotes(WidgetTester tester) async {
    usePhoneSurface(tester);
    h.quotesRepo.next = Right([_quote('q1', 'first'), _quote('q2', 'second')]);
    await h.quotes.loadQuotes();
    await tester.pumpWidget(testApp(router: router));
    await tester.pumpAndSettle();
  }

  testWidgets('opening saved quotes keeps Profile underneath', (tester) async {
    await pumpProfileWithQuotes(tester);

    await tester.tap(find.byIcon(Icons.chevron_right_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(SavedQuotesScreen), findsOneWidget);
    expect(find.byType(ProfileScreen, skipOffstage: false), findsOneWidget);
    expect(router.canPop(), isTrue);
  });

  testWidgets('the back button returns to Profile', (tester) async {
    await pumpProfileWithQuotes(tester);
    await tester.tap(find.byIcon(Icons.chevron_right_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(SavedQuotesScreen), findsNothing);
    expect(find.byType(ProfileScreen), findsOneWidget);
  });

  testWidgets('a quote removed on the saved quotes screen is gone on return',
      (tester) async {
    await pumpProfileWithQuotes(tester);
    expect(find.text('"second"'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_right_rounded));
    await tester.pumpAndSettle();

    h.quotesRepo.next = Right([_quote('q1', 'first')]);
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(find.text('"second"'), findsNothing);
  });
}
