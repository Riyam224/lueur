import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_theme.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_activity_choice_card.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_day_activity_dots.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_grid_card_widget.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_recent_memories_section.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// A same-day mood check-in followed by a later breathing session — the
/// scenario where the card face should show only the later activity.
List<MoodEntryEntity> _sameDayMoodThenBreathing() => [
      MoodEntryEntity(
        id: 1,
        userId: 'u1',
        emoji: '😊',
        thoughts: 'feeling okay',
        aiResponse: 'glad to hear it',
        createdAt: DateTime(2026, 1, 1, 9),
      ),
      MoodEntryEntity(
        id: 2,
        userId: 'u1',
        emoji: '',
        thoughts: '',
        aiResponse: '',
        createdAt: DateTime(2026, 1, 1, 15),
        entryType: 'breathing',
        payload: const {'duration_seconds': 120},
      ),
    ];

Future<void> _pumpSection(
  WidgetTester tester, {
  required List<MoodEntryEntity> entries,
  required GlobalKey<NavigatorState> navigatorKey,
}) async {
  final router = GoRouter(
    initialLocation: '/',
    navigatorKey: navigatorKey,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(
          body: CustomScrollView(
            slivers: [JournalRecentMemoriesSection(entries: entries)],
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.timeline,
        builder: (context, state) => const Scaffold(body: Text('TIMELINE')),
      ),
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) => const Scaffold(body: Text('CHAT')),
      ),
    ],
  );

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) => MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'card shows only the latest same-day entry, with no activity footer',
    (tester) async {
      await _pumpSection(
        tester,
        entries: _sameDayMoodThenBreathing(),
        navigatorKey: GlobalKey<NavigatorState>(),
      );

      // Latest entry that day is the breathing session — card should be
      // the activity-choice pill, not the mood bubble.
      expect(find.byType(JournalActivityChoiceCard), findsOneWidget);
      expect(find.byType(JournalGridCardWidget), findsNothing);

      // No footer/other-activity indicator on the card face.
      expect(find.byType(JournalDayActivityDots), findsNothing);
      expect(find.text('feeling okay'), findsNothing);
    },
  );

  testWidgets(
    'tapping a card opens Timeline, not the chat screen',
    (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      await _pumpSection(
        tester,
        entries: _sameDayMoodThenBreathing(),
        navigatorKey: navigatorKey,
      );

      await tester.tap(find.byType(JournalActivityChoiceCard));
      await tester.pumpAndSettle();

      expect(find.text('TIMELINE'), findsOneWidget);
      expect(find.text('CHAT'), findsNothing);
    },
  );
}
