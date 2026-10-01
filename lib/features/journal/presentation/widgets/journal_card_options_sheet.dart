import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/models/journal_card_color.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/home/domain/entities/mood_entry_entity.dart';
import 'package:lueur/features/journal/presentation/cubit/journal_grid_cubit.dart';
import 'package:lueur/features/journal/presentation/cubit/journal_grid_state.dart';
import 'package:lueur/l10n/app_localizations.dart';

Future<void> showJournalCardOptionsSheet(
  BuildContext context, {
  required MoodEntryEntity entry,
}) {
  final cubit = context.read<JournalGridCubit>();
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.transparent,
    isScrollControlled: true,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _JournalCardOptionsSheetContent(entry: entry),
    ),
  );
}

class _JournalCardOptionsSheetContent extends StatelessWidget {
  final MoodEntryEntity entry;

  const _JournalCardOptionsSheetContent({required this.entry});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.journalCardOptionsDeleteTitle),
            content: Text(
              AppLocalizations.of(context)!.journalCardOptionsDeleteMessage,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(AppLocalizations.of(context)!.commonCancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(
                  AppLocalizations.of(context)!.commonDelete,
                  style: ThemeTextStyles.bodyMedium(
                    context,
                  ).copyWith(color: AppColors.errorColor),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;
    if (!context.mounted) return;

    context.read<JournalGridCubit>().deleteEntry(entry);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: context.extra.cardBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.borderRadiusXl)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.horizontalPaddingLg,
            AppSpacing.spaceMd,
            AppSpacing.horizontalPaddingLg,
            AppSpacing.space2Xl,
          ),
          child: BlocBuilder<JournalGridCubit, JournalGridState>(
            builder: (context, state) {
              // The live copy of this entry, so color/pin changes show up.
              final liveEntry = state is JournalGridLoaded
                  ? state.entries.where(entry.isSameEntryAs).firstOrNull
                  : null;
              if (liveEntry == null) return const SizedBox.shrink();

              final selected = JournalCardColor.fromName(liveEntry.cardColor);

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.lightBorder,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.spaceLg),
                  Text(
                    AppLocalizations.of(context)!.journalCardOptionsColorLabel,
                    style: ThemeTextStyles.bodySmall(context).copyWith(
                      color: AppColors.lightSecondaryText,
                    ),
                  ),
                  SizedBox(height: AppSpacing.spaceMd),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: JournalCardColor.values.map((option) {
                      final isSelected = selected == option;
                      return GestureDetector(
                        onTap: () => context
                            .read<JournalGridCubit>()
                            .setCardColor(entry.id, option.name),
                        child: Container(
                          width: AppSizes.avatarSm,
                          height: AppSizes.avatarSm,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: option.color,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.lightOnBackground
                                  : AppColors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: AppSpacing.spaceLg),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      AppLocalizations.of(context)!.journalCardOptionsPinLabel,
                      style: ThemeTextStyles.bodyLarge(context),
                    ),
                    value: liveEntry.pinned,
                    onChanged: (value) => context
                        .read<JournalGridCubit>()
                        .togglePinned(entry.id, value),
                  ),
                  SizedBox(height: AppSpacing.spaceSm),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.errorColor,
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.journalCardOptionsDeleteLabel,
                      style: ThemeTextStyles.bodyLarge(
                        context,
                      ).copyWith(color: AppColors.errorColor),
                    ),
                    onTap: () => _confirmDelete(context),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
