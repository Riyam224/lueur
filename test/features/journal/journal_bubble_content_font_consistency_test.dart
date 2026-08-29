import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/styling/app_theme.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_bubble_content.dart';
import 'package:lueur/features/journal/presentation/widgets/journal_day_activity_dots.dart';

MoodEntryEntity _entry({required String thoughts}) => MoodEntryEntity(
      id: 1,
      userId: 'u1',
      emoji: '😊',
      thoughts: thoughts,
      aiResponse: thoughts,
      createdAt: DateTime(2026, 1, 1),
    );

/// Renders [JournalBubbleContent] at a fixed bubble size and returns the
/// un-scaled intrinsic size of the Column FittedBox wraps — i.e. the size
/// FittedBox computes its scale factor from.
Future<Size> _pumpAndMeasure(
  WidgetTester tester, {
  required String thoughts,
  required Widget? footer,
}) async {
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, _) => MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 133,
              height: 100,
              child: JournalBubbleContent(
                entry: _entry(thoughts: thoughts),
                moodType: null,
                size: 116,
                bubbleWidth: 133,
                showSummary: true,
                duration: null,
                footer: footer,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final columnFinder = find.descendant(
    of: find.byType(FittedBox),
    matching: find.byType(Column).first,
  );
  return tester.getSize(columnFinder);
}

void main() {
  testWidgets(
    'FittedBox scale input is identical whether the footer is empty or full '
    '— same short thoughts text, varying only footer content',
    (tester) async {
      final withoutFooter = await _pumpAndMeasure(
        tester,
        thoughts: 'ok',
        footer: const JournalDayActivityDots(
          activityTypes: {'mood_chat'},
          excluding: 'mood_chat',
          onTap: _noop,
          maxWidth: 133 * 0.82,
        ),
      );

      final withFullFooter = await _pumpAndMeasure(
        tester,
        thoughts: 'ok',
        footer: const JournalDayActivityDots(
          activityTypes: {'mood_chat', 'breathing', 'sudoku', 'drawing'},
          excluding: 'mood_chat',
          onTap: _noop,
          maxWidth: 133 * 0.82,
        ),
      );

      expect(
        withFullFooter.height,
        closeTo(withoutFooter.height, 0.5),
        reason: 'A day with 0 vs 3 other activities should reserve the same '
            'layout footprint, so FittedBox scales both cards identically '
            'and the preview/date text renders at the same apparent size.',
      );
    },
  );
}

void _noop(String _) {}
