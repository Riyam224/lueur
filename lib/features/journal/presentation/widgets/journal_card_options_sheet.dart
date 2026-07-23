import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/models/journal_card_color.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/journal/presentation/cubit/journal_grid_cubit.dart';
import 'package:lueur/features/journal/presentation/cubit/journal_grid_state.dart';

Future<void> showJournalCardOptionsSheet(
  BuildContext context, {
  required int entryId,
}) {
  final cubit = context.read<JournalGridCubit>();
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _JournalCardOptionsSheetContent(entryId: entryId),
    ),
  );
}

class _JournalCardOptionsSheetContent extends StatelessWidget {
  final int entryId;

  const _JournalCardOptionsSheetContent({required this.entryId});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Delete this entry?'),
            content: const Text(
              'This will remove it from your journal for good.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: AppColors.errorColor),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;
    if (!context.mounted) return;

    context.read<JournalGridCubit>().deleteEntry(entryId);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.horizontalPaddingLg,
            AppSpacing.spaceMd,
            AppSpacing.horizontalPaddingLg,
            AppSpacing.space2Xl,
          ),
          child: BlocBuilder<JournalGridCubit, JournalGridState>(
            builder: (context, state) {
              final entry = state is JournalGridLoaded
                  ? state.entries.where((e) => e.id == entryId).firstOrNull
                  : null;
              if (entry == null) return const SizedBox.shrink();

              final selected = JournalCardColor.fromName(entry.cardColor);

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.lightBorder,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.spaceLg),
                  Text(
                    'card color',
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
                            .setCardColor(entryId, option.name),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: option.color,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.lightOnBackground
                                  : Colors.transparent,
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
                      'pin this entry',
                      style: ThemeTextStyles.bodyLarge(context),
                    ),
                    value: entry.pinned,
                    onChanged: (value) => context
                        .read<JournalGridCubit>()
                        .togglePinned(entryId, value),
                  ),
                  SizedBox(height: AppSpacing.spaceSm),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.errorColor,
                    ),
                    title: const Text(
                      'delete entry',
                      style: TextStyle(color: AppColors.errorColor),
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
