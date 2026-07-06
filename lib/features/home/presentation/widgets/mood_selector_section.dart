import 'package:ai_therapist_app/core/constants/app_spacing.dart';
import 'package:ai_therapist_app/core/styling/theme_text_styles.dart';
import 'package:ai_therapist_app/core/utils/app_strings.dart';
import 'package:ai_therapist_app/core/widgets/spacing_widgets.dart';
import 'package:ai_therapist_app/features/home/presentation/widgets/emoji_entry_mood_list_view.dart';
import 'package:flutter/material.dart';

/// Browsable gallery of mood illustrations, separate from the mood log input
class MoodSelectorSection extends StatelessWidget {
  const MoodSelectorSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.homeMoodGalleryTitle,
          style: ThemeTextStyles.labelLarge(context),
        ),
        HeightSpace(AppSpacing.spaceLg),
        const EmojiEntryMoodListView(),
      ],
    );
  }
}
