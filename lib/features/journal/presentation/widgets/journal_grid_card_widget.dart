import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/models/journal_card_color.dart';
import 'package:lueur/core/models/mood_type.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';

class JournalGridCardWidget extends StatefulWidget {
  final MoodEntryEntity entry;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const JournalGridCardWidget({
    super.key,
    required this.entry,
    required this.index,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<JournalGridCardWidget> createState() => _JournalGridCardWidgetState();
}

class _JournalGridCardWidgetState extends State<JournalGridCardWidget> {
  double _scale = 1;

  void _setScale(double value) {
    if (!mounted) return;
    setState(() => _scale = value);
  }

  String _formatDate(DateTime date) => DateFormat('MMM d').format(date);

  String _preview(String thoughts) {
    final trimmed = thoughts.trim();
    if (trimmed.length <= 40) return trimmed;
    return '${trimmed.substring(0, 40).trimRight()}…';
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = (JournalCardColor.fromName(widget.entry.cardColor) ??
            JournalCardColor.fromIndex(widget.index))
        .color;
    final moodType = moodTypeFromEmoji(widget.entry.emoji);

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: (_) => _setScale(0.95),
      onTapUp: (_) => _setScale(1),
      onTapCancel: () => _setScale(1),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          padding: EdgeInsets.all(AppSpacing.spaceMd),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (moodType != null)
                    Image.asset(
                      moodType.assetPath,
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                  if (widget.entry.pinned)
                    Icon(
                      Icons.push_pin_rounded,
                      size: 16,
                      color: AppColors.lightOnBackground.withValues(alpha: 0.55),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                _formatDate(widget.entry.createdAt),
                style: ThemeTextStyles.captionSmall(context).copyWith(
                  color: AppColors.lightOnBackground.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _preview(widget.entry.thoughts),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: ThemeTextStyles.bodySmall(context).copyWith(
                  color: AppColors.lightOnBackground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
