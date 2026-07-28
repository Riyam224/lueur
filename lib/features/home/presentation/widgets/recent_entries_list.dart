import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/models/mood_entry.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/widgets/mood_entry_card.dart';

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
              padding: EdgeInsets.only(right: AppSpacing.spaceXl),
              decoration: BoxDecoration(
                color: AppColors.errorColor,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.whiteTextColor,
                size: 26.sp,
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
