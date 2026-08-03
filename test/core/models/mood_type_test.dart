import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/models/mood_type.dart';
import 'package:lueur/core/styling/app_colors.dart';

void main() {
  group('MoodType.journalBubbleColor', () {
    test('groups moods into the same pastel by emotional family', () {
      expect(MoodType.happy.journalBubbleColor, AppColors.journalCardYellow);
      expect(MoodType.excited.journalBubbleColor, AppColors.journalCardPeach);
      expect(
        MoodType.grateful.journalBubbleColor,
        AppColors.journalCardPink,
      );
      expect(
        MoodType.hopeful.journalBubbleColor,
        AppColors.journalCardGreen,
      );
      expect(MoodType.calm.journalBubbleColor, AppColors.journalCardMint);
      expect(
        MoodType.contentPeaceful.journalBubbleColor,
        AppColors.journalCardMint,
      );
      expect(MoodType.neutral.journalBubbleColor, AppColors.journalCardMint);
      expect(MoodType.sad.journalBubbleColor, AppColors.journalCardBlue);
      expect(MoodType.lonely.journalBubbleColor, AppColors.journalCardBlue);
      expect(MoodType.burnout.journalBubbleColor, AppColors.journalCardBlue);
      expect(
        MoodType.anxious.journalBubbleColor,
        AppColors.journalCardLavender,
      );
      expect(
        MoodType.scared.journalBubbleColor,
        AppColors.journalCardLavender,
      );
      expect(MoodType.angry.journalBubbleColor, AppColors.journalCardCoral);
    });

    test('every MoodType maps to a color, none left unhandled', () {
      for (final moodType in MoodType.values) {
        expect(moodType.journalBubbleColor, isNotNull);
      }
    });
  });
}
