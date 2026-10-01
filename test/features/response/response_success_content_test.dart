import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/styling/app_theme.dart';
import 'package:lueur/features/response/presentation/widgets/response_success_content.dart';
import 'package:lueur/l10n/app_localizations.dart';

Future<void> _pump(WidgetTester tester, {required bool isFallback}) {
  tester.view.physicalSize = const Size(1170, 4000);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) => MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ResponseSuccessContent(
            emojiImagePath: null,
            emojiUnicode: '🌱',
            displayThoughts: 'hi',
            aiResponse: 'Luna is resting.',
            isFallback: isFallback,
            onBookmark: () {},
            onDone: () {},
            onTalkAgain: () {},
            onShare: () {},
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('a normal response can be saved and shared', (tester) async {
    await _pump(tester, isFallback: false);

    expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
  });

  testWidgets('a fallback response is shown without Save-quote and Share',
      (tester) async {
    await _pump(tester, isFallback: true);

    expect(find.text('Luna is resting.'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_border), findsNothing);
    expect(find.text('Share'), findsNothing);
  });
}
