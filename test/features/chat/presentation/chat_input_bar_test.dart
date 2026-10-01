import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/constants/app_limits.dart';
import 'package:lueur/core/styling/app_theme.dart';
import 'package:lueur/features/chat/presentation/widgets/chat_input_bar.dart';
import 'package:lueur/l10n/app_localizations.dart';

Future<TextEditingController> _pump(WidgetTester tester) async {
  final controller = TextEditingController();
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) => MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: ChatInputBar(
              controller: controller,
              isLoading: false,
              onSend: () {},
            ),
          ),
        ),
      ),
    ),
  );
  return controller;
}

void main() {
  testWidgets('typing past the limit is cut at the chat message maximum',
      (tester) async {
    final controller = await _pump(tester);

    await tester.enterText(find.byType(TextField), 'a' * 1500);
    await tester.pump();

    expect(controller.text.length, AppLimits.chatMessageMaxLength);
  });

  testWidgets('the character counter stays hidden for short messages',
      (tester) async {
    await _pump(tester);

    await tester.enterText(find.byType(TextField), 'hello');
    await tester.pump();

    expect(find.text('5/1000'), findsNothing);
  });

  testWidgets('the counter appears when the limit is near', (tester) async {
    await _pump(tester);

    await tester.enterText(find.byType(TextField), 'a' * 950);
    await tester.pump();

    expect(find.text('950/1000'), findsOneWidget);
  });
}
