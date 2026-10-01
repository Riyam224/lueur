import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/styling/app_theme.dart';
import 'package:lueur/features/chat/domain/entities/chat_message.dart';
import 'package:lueur/features/chat/presentation/cubit/chat_state.dart';
import 'package:lueur/features/chat/presentation/widgets/chat_messages_list.dart';
import 'package:lueur/l10n/app_localizations.dart';

Future<void> _pump(WidgetTester tester, List<ChatMessage> messages) {
  return tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) => MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ChatMessagesList(
            scrollController: ScrollController(),
            state: ChatState(messages: messages),
            onBookmarkMessage: (_) {},
            onReportMessage: (_) {},
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('a real Luna reply can be bookmarked and reported',
      (tester) async {
    await _pump(tester, const [
      ChatMessage(role: ChatMessage.roleAssistant, content: 'Hello'),
    ]);

    expect(find.byIcon(Icons.bookmark_border_rounded), findsOneWidget);
    expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
  });

  testWidgets('a send-failed bubble has no bookmark or report button',
      (tester) async {
    await _pump(tester, const [
      ChatMessage(
        role: ChatMessage.roleAssistant,
        content: '${ChatMessage.sendFailedSentinelPrefix}2',
      ),
    ]);

    expect(find.byIcon(Icons.bookmark_border_rounded), findsNothing);
    expect(find.byIcon(Icons.flag_outlined), findsNothing);
  });
}
