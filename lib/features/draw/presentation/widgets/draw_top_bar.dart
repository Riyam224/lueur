import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/draw/presentation/cubit/draw_cubit.dart';
import 'package:lueur/features/draw/presentation/cubit/draw_state.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Back button, title, undo/save/clear controls for the free-draw screen.
class DrawTopBar extends StatelessWidget {
  const DrawTopBar({super.key, required this.onBack, required this.onSave});

  final VoidCallback onBack;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final extra = context.extra;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontalPaddingMd,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: extra.primaryTextColor,
              size: AppSizes.iconSm,
            ),
          ),
          Flexible(
            child: Text(
              l10n.drawTopBarTitle,
              overflow: TextOverflow.ellipsis,
              style: ThemeTextStyles.bodyMedium(context).copyWith(
                color: extra.secondaryTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          BlocBuilder<DrawCubit, DrawState>(
            buildWhen: (previous, current) =>
                previous.paths.isEmpty != current.paths.isEmpty,
            builder: (context, state) {
              final hasStrokes = state.paths.isNotEmpty;
              return IconButton(
                onPressed: hasStrokes
                    ? () => context.read<DrawCubit>().undoLastStroke()
                    : null,
                tooltip: l10n.drawUndoButton,
                icon: Icon(
                  Icons.undo_rounded,
                  color:
                      hasStrokes ? extra.primaryTextColor : extra.borderColor,
                  size: AppSizes.iconSm,
                ),
              );
            },
          ),
          IconButton(
            onPressed: onSave,
            icon: Icon(
              Icons.save_alt_rounded,
              color: extra.primaryColor,
              size: AppSizes.iconSm,
            ),
          ),
          Flexible(
            child: TextButton(
              onPressed: () => context.read<DrawCubit>().clear(),
              child: Text(
                l10n.drawClearButton,
                overflow: TextOverflow.ellipsis,
                style: ThemeTextStyles.bodyMedium(context).copyWith(
                  color: extra.secondaryTextColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
