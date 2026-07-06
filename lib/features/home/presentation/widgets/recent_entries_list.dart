import 'package:ai_therapist_app/core/constants/app_spacing.dart';
import 'package:ai_therapist_app/core/models/mood_entry.dart';
import 'package:ai_therapist_app/core/styling/app_colors.dart';
import 'package:ai_therapist_app/core/widgets/mood_entry_card.dart';
import 'package:flutter/material.dart';

/// List of recent mood entries
class RecentEntriesList extends StatelessWidget {
  const RecentEntriesList({
    required this.entries,
    required this.onDelete,
    super.key,
  });

  final List<MoodEntry> entries;
  final void Function(int id) onDelete;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final entry = entries[index];
          return Dismissible(
            key: ValueKey(entry.id),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => onDelete(entry.id),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: AppColors.errorColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.whiteTextColor,
                size: 26,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.spaceMd),
              child: MoodEntryCard(
                emoji: entry.emoji,
                title: entry.title,
                preview: entry.preview,
                sideColor: entry.sideColor,
                date: entry.date,
                isEmojiImage: entry.isEmojiImage,
                onTap: () {},
              ),
            ),
          );
        },
        childCount: entries.length,
      ),
    );
  }
}
