import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/models/mood_entry.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/core/widgets/mood_entry_card.dart';

class MoodEntryListView extends StatelessWidget {
  final List<MoodEntry> moodEntries;
  final Function(MoodEntry)? onEntryTap;

  const MoodEntryListView({
    super.key,
    required this.moodEntries,
    this.onEntryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (moodEntries.isEmpty) {
      return SizedBox(
        height: 100.h,
        child: Center(
          child: Text(
            'No mood entries yet',
            style: ThemeTextStyles.bodyLarge(context).copyWith(
              color: context.extra.secondaryTextColor,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200.h,
      child: ListView.builder(
        itemCount: moodEntries.length,
        itemBuilder: (context, index) {
          final entry = moodEntries[index];
          return Padding(
            padding: EdgeInsets.only(
              right: index < moodEntries.length - 1 ? AppSpacing.spaceMd : 0,
            ),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: MoodEntryCard(
                emoji: entry.emoji,
                title: entry.title,
                preview: entry.preview,
                sideColor: entry.sideColor,
                date: entry.date,
                isEmojiImage: entry.isEmojiImage,
                onTap: () {
                  onEntryTap?.call(entry);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
