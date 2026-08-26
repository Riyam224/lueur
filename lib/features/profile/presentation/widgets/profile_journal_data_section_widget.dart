import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/home/presentation/cubit/mood_cubit.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Destructive data actions live under Profile, not Home/Journal, which
/// stay focused on check-in and reflection.
class ProfileJournalDataSectionWidget extends StatelessWidget {
  const ProfileJournalDataSectionWidget({super.key});

  Future<void> _confirmDeleteAll(BuildContext context) async {
    final moodCubit = context.read<MoodCubit>();
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.moodEntryDeleteAllTitle),
            content: Text(l10n.moodEntryDeleteAllMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.commonCancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(
                  l10n.moodEntryDeleteAllConfirm,
                  style: const TextStyle(color: AppColors.errorColor),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;
    await moodCubit.deleteAllEntries();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.profileJournalDataSectionLabel,
          style: ThemeTextStyles.labelSmall(context).copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: AppSpacing.verticalPaddingSm),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(
            Icons.delete_outline_rounded,
            color: AppColors.errorColor,
          ),
          title: Text(
            l10n.profileDeleteAllEntriesLabel,
            style: const TextStyle(color: AppColors.errorColor),
          ),
          onTap: () => _confirmDeleteAll(context),
        ),
      ],
    );
  }
}
