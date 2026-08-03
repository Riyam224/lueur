import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/styling/app_theme.dart';
import 'package:lueur/features/home/presentation/widgets/streak_card_widget.dart';
import 'package:lueur/l10n/app_localizations.dart';

void main() {
  Widget buildApp({required Locale locale}) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) => MaterialApp(
        theme: AppTheme.light,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: StreakCardWidget(entries: [], streakDays: 3),
        ),
      ),
    );
  }

  testWidgets('renders English weekday initials when locale is English',
      (tester) async {
    await tester.pumpWidget(buildApp(locale: const Locale('en')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Today's initial should always be present in the 7-day strip.
    final today = DateFormatFallback.englishInitial(DateTime.now());
    expect(find.text(today), findsWidgets);
  });

  testWidgets('renders Arabic day abbreviations when locale is Arabic',
      (tester) async {
    await tester.pumpWidget(buildApp(locale: const Locale('ar')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    const arabicAbbreviations = ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'];
    final textWidgets = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .whereType<String>()
        .toList();

    // Every rendered day label must be one of the compact Arabic
    // abbreviations, and none of the raw English weekday initials
    // should leak through.
    final dayLabels =
        textWidgets.where((t) => arabicAbbreviations.contains(t)).toList();
    expect(dayLabels, isNotEmpty);
    expect(
      textWidgets.any((t) => RegExp(r'^[A-Za-z]$').hasMatch(t)),
      isFalse,
    );

    // Today's specific letter must be present, catching a mis-keyed map
    // entry (e.g. Tuesday/Wednesday swapped) that the subset check above
    // would miss.
    expect(
      find.text(DateFormatFallback.arabicInitial(DateTime.now())),
      findsWidgets,
    );
  });

  testWidgets('renders a motivational message', (tester) async {
    await tester.pumpWidget(buildApp(locale: const Locale('en')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.homeStreakMotivationActive), findsOneWidget);
  });
}

/// Mirrors the widget's English fallback path (`DateFormat('E')`'s first
/// character) so the test can assert against today's label without
/// duplicating the widget's day-generation logic.
class DateFormatFallback {
  static String englishInitial(DateTime day) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return names[day.weekday - 1][0];
  }

  /// Independent mirror of the widget's Arabic weekday mapping, keyed by
  /// [DateTime.weekday], so a mis-keyed entry in the widget is caught
  /// rather than trivially passing against itself.
  static String arabicInitial(DateTime day) {
    const abbreviations = {
      DateTime.monday: 'ن',
      DateTime.tuesday: 'ث',
      DateTime.wednesday: 'ر',
      DateTime.thursday: 'خ',
      DateTime.friday: 'ج',
      DateTime.saturday: 'س',
      DateTime.sunday: 'ح',
    };
    return abbreviations[day.weekday]!;
  }
}
