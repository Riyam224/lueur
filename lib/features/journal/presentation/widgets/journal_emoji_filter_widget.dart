import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lueur_app/core/constants/app_sizes.dart';
import 'package:lueur_app/core/constants/app_spacing.dart';
import 'package:lueur_app/core/models/mood_type.dart';
import 'package:lueur_app/core/styling/theme_extensions.dart';

/// Horizontal scrollable mood filter row — uses the same illustration set
/// (and full 13-mood coverage) as the home mood picker.
class JournalEmojiFilterWidget extends StatelessWidget {
  final String? selectedEmoji;
  final ValueChanged<String?> onEmojiSelected;

  const JournalEmojiFilterWidget({
    super.key,
    required this.selectedEmoji,
    required this.onEmojiSelected,
  });

  static const List<MoodType> _filterMoods = MoodType.values;

  Widget _buildEmojiImage(MoodType moodType) {
    final assetPath = moodType.assetPath;
    return assetPath.endsWith('.svg')
        ? SvgPicture.asset(assetPath, width: AppSizes.iconMd, height: AppSizes.iconMd)
        : Image.asset(assetPath, width: AppSizes.iconMd, height: AppSizes.iconMd, fit: BoxFit.contain);
  }

  @override
  Widget build(BuildContext context) {
    final extraColors = context.extra;

    return SizedBox(
      height: AppSizes.emojiButtonSize,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filterMoods.length,
        itemBuilder: (context, index) {
          final moodType = _filterMoods[index];
          final emoji = moodType.emoji;
          final isSelected = selectedEmoji == emoji;

          return Padding(
            padding: EdgeInsets.only(right: AppSpacing.spaceMd),
            child: GestureDetector(
              onTap: () => onEmojiSelected(isSelected ? null : emoji),
              child: Container(
                width: AppSizes.emojiButtonSize,
                height: AppSizes.emojiButtonSize,
                decoration: BoxDecoration(
                  color: isSelected
                      ? extraColors.primaryColor!.withValues(alpha: 0.3)
                      : extraColors.cardBackgroundColor,
                  borderRadius:
                      BorderRadius.circular(AppSizes.borderRadiusCircle),
                  border: isSelected
                      ? Border.all(
                          color: extraColors.primaryColor!,
                          width: 2.w,
                        )
                      : null,
                ),
                child: Center(
                  child: _buildEmojiImage(moodType),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
