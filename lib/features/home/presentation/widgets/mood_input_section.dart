import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/models/mood_type.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/core/utils/app_strings.dart';
import 'package:lueur/features/home/presentation/cubit/mood_cubit.dart';
import 'package:lueur/features/home/presentation/widgets/mood_selector_widget.dart';
import 'package:lueur/features/home/presentation/widgets/thoughts_input_widget.dart';
import 'package:lueur/features/mood_choice/presentation/widgets/mood_choice_dialog.dart';

/// Combined section for mood selection and thoughts input
class MoodInputSection extends StatefulWidget {
  const MoodInputSection({super.key});

  @override
  State<MoodInputSection> createState() => _MoodInputSectionState();
}

class _MoodInputSectionState extends State<MoodInputSection> {
  MoodType? _selectedMood;
  final TextEditingController _thoughtsController = TextEditingController();

  static const List<MoodType> _moods = MoodType.values;

  String _thoughtsLabel(MoodType? mood) {
    switch (mood) {
      case MoodType.sad:
        return AppStrings.homeThoughtsLabelSad;
      case MoodType.lonely:
        return AppStrings.homeThoughtsLabelLonely;
      case MoodType.angry:
        return AppStrings.homeThoughtsLabelAngry;
      case MoodType.anxious:
      case MoodType.scared:
        return AppStrings.homeThoughtsLabelWorried;
      case MoodType.burnout:
        return AppStrings.homeThoughtsLabelBurnout;
      case MoodType.calm:
      case MoodType.contentPeaceful:
        return AppStrings.homeThoughtsLabelNeutralGood;
      case MoodType.happy:
      case MoodType.excited:
        return AppStrings.homeThoughtsLabelFeelGood;
      case MoodType.grateful:
        return AppStrings.homeThoughtsLabelGrateful;
      case MoodType.hopeful:
        return AppStrings.homeThoughtsLabelHopeful;
      case MoodType.neutral:
      case null:
        return AppStrings.homeThoughtsLabelDefault;
    }
  }

  @override
  void dispose() {
    _thoughtsController.dispose();
    super.dispose();
  }

  void _onEmojiSelected(String emoji) {
    setState(() {
      _selectedMood = _moods.firstWhere((mood) => mood.emoji == emoji);
    });
  }

  void _onTalkToLuna() {
    final thoughts = _thoughtsController.text.trim();

    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.homeMoodRequiredSnack),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (thoughts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.homeThoughtsRequiredSnack),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();

    final selectedMood = _selectedMood!;
    final emojiUnicode = selectedMood.emoji;

    if (selectedMood.isLowMood) {
      context.read<MoodCubit>().addLocalEntry(
        emoji: emojiUnicode,
        thoughts: thoughts,
      );
      showMoodChoiceDialog(context, emoji: emojiUnicode, thoughts: thoughts);
    } else {
      context.push(
        AppRoutes.response,
        extra: {
          'emojiPath': null,
          'emojiUnicode': emojiUnicode,
          'thoughts': thoughts,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final extra = context.extra;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.homeMoodPromptLabel,
          style: ThemeTextStyles.bodyMedium(context).copyWith(
            color: extra.secondaryTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.spaceLg),
        MoodSelectorWidget(
          emojis: _moods.map((mood) => mood.emoji).toList(),
          selectedEmoji: _selectedMood?.emoji,
          onEmojiSelected: _onEmojiSelected,
          moodColors: _moods.map((mood) => mood.color).toList(),
          moodBgColors: _moods.map((mood) => mood.bgColor).toList(),
          illustrationPaths: _moods.map((mood) => mood.assetPath).toList(),
          selectedLabel: _selectedMood?.label,
        ),
        SizedBox(height: AppSpacing.sectionSpacingMd),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _thoughtsLabel(_selectedMood),
              key: ValueKey(_selectedMood),
              style: ThemeTextStyles.bodyMedium(context).copyWith(
                color: extra.secondaryTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.spaceLg),
        ThoughtsInputWidget(
          controller: _thoughtsController,
          onSubmit: _onTalkToLuna,
        ),
      ],
    );
  }
}
