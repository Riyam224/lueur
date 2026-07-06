import 'package:ai_therapist_app/core/constants/app_spacing.dart';
import 'package:ai_therapist_app/features/response/presentation/widgets/mood_tag_chip_widget.dart';
import 'package:flutter/material.dart';

/// Row of mood tags displayed as chips
class MoodTagsRowWidget extends StatelessWidget {
  final List<String> tags;

  const MoodTagsRowWidget({
    super.key,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.spaceSm,
      runSpacing: AppSpacing.spaceSm,
      children: tags.map((tag) => MoodTagChipWidget(label: tag)).toList(),
    );
  }
}
