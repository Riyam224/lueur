import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lueur_app/core/constants/app_sizes.dart';
import 'package:lueur_app/core/constants/app_spacing.dart';
import 'package:lueur_app/core/models/mood_type.dart';
import 'package:lueur_app/core/widgets/emoji_entry_mood.dart';

/// Horizontal gallery of mood illustrations. Tapping a mood pops it and
/// floats its name above it.
class EmojiEntryMoodListView extends StatefulWidget {
  const EmojiEntryMoodListView({super.key});

  @override
  State<EmojiEntryMoodListView> createState() => _EmojiEntryMoodListViewState();
}

class _EmojiEntryMoodListViewState extends State<EmojiEntryMoodListView> {
  MoodType? _selectedMood;

  void _onMoodTapped(MoodType moodType) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedMood = _selectedMood == moodType ? null : moodType;
    });
  }

  @override
  Widget build(BuildContext context) {
    final listHeight = AppSizes.emojiButtonSize +
        AppSizes.moodLabelPopupGap +
        AppSizes.moodLabelPopupHeight;

    return SizedBox(
      height: listHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: MoodType.values.length,
        itemBuilder: (context, index) {
          final moodType = MoodType.values[index];
          return Padding(
            padding: EdgeInsets.only(right: AppSpacing.spaceXl),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: EmojiEntryMood(
                moodType: moodType,
                isSelected: _selectedMood == moodType,
                onTap: () => _onMoodTapped(moodType),
              ),
            ),
          );
        },
      ),
    );
  }
}
