import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/models/mood_type.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/home/presentation/cubit/mood_cubit.dart';
import 'package:lueur/features/home/presentation/widgets/mood_selector_widget.dart';
import 'package:lueur/features/home/presentation/widgets/thoughts_input_widget.dart';
import 'package:lueur/features/mood_choice/presentation/widgets/mood_choice_dialog.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Combined section for mood selection and thoughts input
class MoodInputSection extends StatefulWidget {
  const MoodInputSection({super.key});

  @override
  State<MoodInputSection> createState() => _MoodInputSectionState();
}

class _MoodInputSectionState extends State<MoodInputSection> {
  MoodType? _selectedMood;
  late final TextEditingController _thoughtsController;

  static const List<MoodType> _moods = MoodType.values;

  String _thoughtsLabel(BuildContext context, MoodType? mood) {
    final l10n = AppLocalizations.of(context)!;
    switch (mood) {
      case MoodType.sad:
        return l10n.homeThoughtsLabelSad;
      case MoodType.lonely:
        return l10n.homeThoughtsLabelLonely;
      case MoodType.angry:
        return l10n.homeThoughtsLabelAngry;
      case MoodType.anxious:
      case MoodType.scared:
        return l10n.homeThoughtsLabelWorried;
      case MoodType.burnout:
        return l10n.homeThoughtsLabelBurnout;
      case MoodType.calm:
      case MoodType.contentPeaceful:
        return l10n.homeThoughtsLabelNeutralGood;
      case MoodType.happy:
      case MoodType.excited:
        return l10n.homeThoughtsLabelFeelGood;
      case MoodType.grateful:
        return l10n.homeThoughtsLabelGrateful;
      case MoodType.hopeful:
        return l10n.homeThoughtsLabelHopeful;
      case MoodType.neutral:
      case null:
        return l10n.homeThoughtsLabelDefault;
    }
  }

  @override
  void initState() {
    super.initState();
    _thoughtsController = TextEditingController();
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

  void _clearDraft() {
    _thoughtsController.clear();
    setState(() => _selectedMood = null);
  }

  void _onTalkToLuna() {
    final thoughts = _thoughtsController.text.trim();

    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.homeMoodRequiredSnack),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (thoughts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.homeThoughtsRequiredSnack),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();

    final emojiUnicode = _selectedMood!.emoji;

    context.read<MoodCubit>().addLocalEntry(
      emoji: emojiUnicode,
      thoughts: thoughts,
    );
    showMoodChoiceDialog(context, emoji: emojiUnicode, thoughts: thoughts);

    _clearDraft();
  }

  @override
  Widget build(BuildContext context) {
    final extra = context.extra;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.homeMoodPromptLabel,
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
          selectedLabel: _selectedMood?.label(context),
        ),
        SizedBox(height: AppSpacing.sectionSpacingMd),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _thoughtsLabel(context, _selectedMood),
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
