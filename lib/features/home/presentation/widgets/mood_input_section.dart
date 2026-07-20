import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/models/mood_type.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/home/presentation/cubit/mood_cubit.dart';
import 'package:lueur/features/home/presentation/widgets/mood_selector_widget.dart';
import 'package:lueur/features/home/presentation/widgets/thoughts_input_widget.dart';

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
        return 'What\'s weighing on you?';
      case MoodType.lonely:
        return 'What\'s been on your mind?';
      case MoodType.angry:
        return 'What set this off?';
      case MoodType.anxious:
      case MoodType.scared:
        return 'What\'s worrying you?';
      case MoodType.burnout:
        return 'What\'s been draining you?';
      case MoodType.calm:
      case MoodType.contentPeaceful:
        return 'What\'s going on today?';
      case MoodType.happy:
      case MoodType.excited:
        return 'What\'s making you feel good?';
      case MoodType.grateful:
        return 'What are you grateful for?';
      case MoodType.hopeful:
        return 'What are you looking forward to?';
      case MoodType.neutral:
      case null:
        return 'Tell me what\'s going on...';
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
          content: Text('Please select your mood first'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (thoughts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please share your thoughts'),
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
      context.go(AppRoutes.breathing, extra: emojiUnicode);
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
          'How are you feeling today?',
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
