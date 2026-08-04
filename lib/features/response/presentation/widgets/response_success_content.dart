import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/response/presentation/widgets/action_buttons_widget.dart';
import 'package:lueur/features/response/presentation/widgets/after_feeling_selector_widget.dart';
import 'package:lueur/features/response/presentation/widgets/ai_response_card_widget.dart';
import 'package:lueur/features/response/presentation/widgets/luna_avatar_widget.dart';
import 'package:lueur/features/response/presentation/widgets/luna_info_widget.dart';
import 'package:lueur/features/response/presentation/widgets/mood_tags_row_widget.dart';
import 'package:lueur/features/response/presentation/widgets/user_mood_card_widget.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Luna's avatar, the user's mood entry, and (once generated) the AI
/// response with its bookmark/share/talk-again actions.
class ResponseSuccessContent extends StatelessWidget {
  const ResponseSuccessContent({
    super.key,
    required this.emojiImagePath,
    required this.emojiUnicode,
    required this.displayThoughts,
    required this.aiResponse,
    required this.onBookmark,
    required this.onDone,
    required this.onTalkAgain,
    required this.onShare,
  });

  final String? emojiImagePath;
  final String? emojiUnicode;
  final String displayThoughts;
  final String aiResponse;
  final VoidCallback onBookmark;
  final VoidCallback onDone;
  final VoidCallback? onTalkAgain;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPaddingLg),
      child: Column(
        children: [
          SizedBox(height: AppSpacing.spaceLg),
          const LunaAvatarWidget(),
          SizedBox(height: AppSpacing.spaceMd),
          const LunaInfoWidget(),
          SizedBox(height: AppSpacing.sectionSpacingMd),
          UserMoodCardWidget(
            emoji: emojiImagePath ?? emojiUnicode ?? '😔',
            thoughts: displayThoughts,
            isEmojiImage: emojiImagePath != null,
          ),
          SizedBox(height: AppSpacing.spaceLg),
          if (aiResponse.isNotEmpty) ...[
            AiResponseCardWidget(response: aiResponse, onBookmark: onBookmark),
            SizedBox(height: AppSpacing.spaceLg),
            MoodTagsRowWidget(
              tags: [
                l10n.responseMoodTagExpressing,
                l10n.responseMoodTagReflecting,
                l10n.responseMoodTagGrowing,
              ],
            ),
            SizedBox(height: AppSpacing.sectionSpacingMd),
            ActionButtonsWidget(
              saveLabel: l10n.responseDoneLabel,
              talkAgainLabel: l10n.responseKeepChattingLabel,
              onSave: onDone,
              onTalkAgain: onTalkAgain,
            ),
            SizedBox(height: AppSpacing.spaceMd),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onShare,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.spaceLg),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: Text(
                  l10n.responseShareButton,
                  style: ThemeTextStyles.labelMedium(context).copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.spaceLg),
            const AfterFeelingSelectorWidget(),
            SizedBox(height: AppSpacing.sectionSpacingMd),
          ],
        ],
      ),
    );
  }
}
