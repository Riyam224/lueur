import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/l10n/app_localizations.dart';

Map<String, String> _arb(String path) {
  final json = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  return {
    for (final e in json.entries)
      if (!e.key.startsWith('@') && e.value is String) e.key: e.value as String,
  };
}

/// Second-person forms that are spelled differently for men and women:
/// imperatives, present-tense verbs and adjectives. Past-tense forms (أردت)
/// are spelled the same for both, so they are fine.
const _gendered = [
  'حاول', 'جرّب', 'جرب', 'أعد', 'ابدأ', 'استمر', 'تحقق', 'أدخل', 'ابحث',
  'اختر', 'خذ', 'كن', 'شاهد', 'تحدث', 'أخبرني', 'شارك', 'ارسم', 'تنفس',
  'املأ', 'بدّل', 'فعّل', 'سجّل', 'العب', 'أكمل', 'تتطلع', 'تفتح', 'تحضر',
  'تشعر', 'تريد', 'تحفظ', 'تثق', 'تستحق', 'تمسّك', 'اتبعه', 'تابع', 'تحقّق',
  'مستيقظاً', 'مستعداً', 'حزيناً', 'ممتن', 'متصل', 'سعيد', 'حزين', 'غاضب',
  'مرتاح', 'هادئ', 'متحمس', 'متفائل', 'وحيد', 'خائف', 'مستنزف', 'محبوب',
  'حاضراً',
  'التتابع', 'معلمك',
];

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final ar = lookupAppLocalizations(const Locale('ar'));

  group('Chat send-failure messages', () {
    test('are honest: nothing pretends Luna is a person with a phone', () {
      final all = [
        en.chatSendFailedMessages0,
        en.chatSendFailedMessages1,
        en.chatSendFailedMessages2,
        en.chatSendFailedMessages3,
        en.chatSendFailedMessages4,
      ];
      for (final text in all) {
        expect(text.toLowerCase(), isNot(contains('signal')));
        expect(text.toLowerCase(), isNot(contains('glitch')));
        expect(text.toLowerCase(), isNot(matches(RegExp(r'\bugh\b'))));
        expect(text.toLowerCase(), isNot(contains('catch that')));
        expect(text, isNotEmpty);
      }
      expect(en.chatSendFailedMessages0, contains("Luna can't reply right now"));
    });

    test('Arabic versions exist and do not claim to be a human with a signal',
        () {
      final all = [
        ar.chatSendFailedMessages0,
        ar.chatSendFailedMessages1,
        ar.chatSendFailedMessages2,
        ar.chatSendFailedMessages3,
        ar.chatSendFailedMessages4,
      ];
      for (final text in all) {
        expect(text, isNotEmpty);
        expect(text, isNot(contains('إشارتي')));
        expect(text, isNot(contains('حممم')));
      }
    });
  });

  group('Tone: no human feelings or promises the app cannot keep', () {
    test('report confirmation does not promise a follow-up', () {
      expect(en.chatReportSuccessSnack, 'Thanks, your report was sent.');
      expect(ar.chatReportSuccessSnack, isNot(contains('سنراجع')));
    });

    test('Luna does not claim to miss, be proud of, or be in awe of anyone',
        () {
      expect(en.loginSubtitle.toLowerCase(), isNot(contains('missed')));
      expect(en.homeGreetingMessage, isNot(contains('proud of you')));
      expect(en.streakCelebrationAllMilestonesReached, isNot(contains('awe')));
      expect(ar.loginSubtitle, isNot(contains('اشتاقت')));
      expect(ar.homeGreetingMessage, isNot(contains('فخورة')));
      expect(ar.streakCelebrationAllMilestonesReached, isNot(contains('مندهشة')));
    });

    test('the Sudoku help does not say Luna does the work', () {
      expect(en.sudokuHowToPlayMessage, isNot(contains('Luna clear')));
      expect(ar.sudokuHowToPlayMessage, isNot(contains('للونا')));
    });

    test('the delete-all warning still says what Luna remembers is deleted',
        () {
      expect(en.moodEntryDeleteAllMessage, contains('what Luna remembers'));
      expect(ar.moodEntryDeleteAllMessage, contains('تتذكره لونا'));
    });
  });

  group('Arabic is gender-neutral toward the user', () {
    final pattern = RegExp(
      '(?<!\\p{L})(${_gendered.join('|')})(?!\\p{L})',
      unicode: true,
    );
    final strings = _arb('lib/l10n/app_ar.arb');

    test('no gender-specific second-person form in any string', () {
      final offenders = <String>[];
      strings.forEach((key, value) {
        final match = pattern.firstMatch(value);
        if (match != null) offenders.add('$key: "${match.group(0)}" in "$value"');
      });
      expect(offenders, isEmpty, reason: offenders.join('\n'));
    });

    test('no string spells Luna in Latin letters (the app name Lueur is fine)',
        () {
      final latinLuna = RegExp(r'\bLuna\b', caseSensitive: false);
      final offenders = [
        for (final e in strings.entries)
          if (latinLuna.hasMatch(e.value)) '${e.key}: "${e.value}"',
      ];
      expect(offenders, isEmpty, reason: offenders.join('\n'));
    });
  });
}
