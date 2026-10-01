import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/l10n/app_localizations.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final ar = lookupAppLocalizations(const Locale('ar'));

  group('Profile error subtitles', () {
    test('no longer promise a pull-to-refresh gesture', () {
      for (final text in [
        en.profileDrawingsErrorSubtitle,
        en.profileSudokuHistoryErrorSubtitle,
      ]) {
        expect(text.toLowerCase(), isNot(contains('pull')));
      }
      for (final text in [
        ar.profileDrawingsErrorSubtitle,
        ar.profileSudokuHistoryErrorSubtitle,
      ]) {
        expect(text, isNot(contains('اسحب')));
      }
    });
  });

  group('Delete-all confirmation', () {
    test('says drawings, quotes and Sudoku history stay', () {
      expect(
        en.moodEntryDeleteAllMessage,
        allOf(
          contains('drawings'),
          contains('quotes'),
          contains('Sudoku history stay'),
        ),
      );
      expect(ar.moodEntryDeleteAllMessage, contains('تبقى على هذا الجهاز'));
    });
  });

  group('Saved quotes empty state', () {
    test('only promises device storage', () {
      for (final text in [en.quotesEmptySubtitle, en.profileQuotesEmptySubtitle]) {
        expect(text, contains('on this device'));
        expect(text.toLowerCase(), isNot(contains('remember')));
      }
      for (final text in [ar.quotesEmptySubtitle, ar.profileQuotesEmptySubtitle]) {
        expect(text, contains('جهازك'));
        expect(text, isNot(contains('ستتذكر')));
      }
    });
  });

  group('Arabic plurals', () {
    test('days ago uses the right form per count', () {
      expect(ar.profileSudokuRelativeDaysAgo(1), 'قبل يوم');
      expect(ar.profileSudokuRelativeDaysAgo(2), 'قبل يومين');
      expect(ar.profileSudokuRelativeDaysAgo(3), 'قبل 3 أيام');
      expect(ar.profileSudokuRelativeDaysAgo(10), 'قبل 10 أيام');
      expect(ar.profileSudokuRelativeDaysAgo(11), 'قبل 11 يومًا');
      expect(ar.profileSudokuRelativeDaysAgo(100), 'قبل 100 يوم');
    });

    test('mistakes uses the right form per count', () {
      expect(ar.profileSudokuMistakesCount(0), 'بلا أخطاء');
      expect(ar.profileSudokuMistakesCount(1), 'خطأ واحد');
      expect(ar.profileSudokuMistakesCount(2), 'خطآن');
      expect(ar.profileSudokuMistakesCount(3), '3 أخطاء');
      expect(ar.profileSudokuMistakesCount(11), '11 خطأً');
    });
  });

  group('Arabic Profile copy is gender-neutral', () {
    test('no masculine imperatives or second-person verbs', () {
      final texts = [
        ar.profileDrawingsErrorSubtitle,
        ar.profileSudokuHistoryErrorSubtitle,
        ar.profileSudokuHistoryEmptySubtitle,
        ar.profileSudokuSolvedIt,
        ar.profileSudokuGaveItAGo,
        ar.profileSubtitle,
        ar.profileGuestSubtitle,
        ar.profileFallbackName,
        ar.drawSaveErrorSnack,
        ar.drawTalkToLunaLink,
        ar.moodEntryDeleteAllFailedSnack,
        ar.accountDeleteTitle,
        ar.accountDeleteFailedSnack,
      ];
      // Whole words only — "محاولة" (an attempt) is the neutral noun form
      // and must not be flagged for containing "حاول".
      const masculine = ['حاول', 'اسحب', 'العب', 'تشعر', 'تريد', 'عضو', 'صديق'];
      for (final text in texts) {
        final words = text.split(RegExp(r'[\s،.؟?!—✓]+'));
        for (final word in masculine) {
          expect(words, isNot(contains(word)), reason: '"$text" has "$word"');
        }
      }
    });
  });
}
