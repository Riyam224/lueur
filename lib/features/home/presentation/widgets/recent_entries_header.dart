import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/core/widgets/spacing_widgets.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Header for recent mood entries with "See all" navigation
class RecentEntriesHeader extends StatelessWidget {
  const RecentEntriesHeader({super.key, this.onDeleteAll});

  final VoidCallback? onDeleteAll;

  @override
  Widget build(BuildContext context) {
    final extraColors = context.extra;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            AppLocalizations.of(context)!.homeRecentEntriesLabel,
            overflow: TextOverflow.ellipsis,
            style: ThemeTextStyles.labelLarge(context),
          ),
        ),
        WidthSpace(AppSpacing.spaceSm),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onDeleteAll != null) ...[
                GestureDetector(
                  onTap: onDeleteAll,
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: extraColors.primaryColor,
                    size: AppSizes.iconSm,
                  ),
                ),
                WidthSpace(AppSpacing.spaceSm),
              ],
              Flexible(
                child: GestureDetector(
                  onTap: () => GoRouter.of(context).push(AppRoutes.timeline),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          AppLocalizations.of(context)!.homeSeeAllLabel,
                          overflow: TextOverflow.ellipsis,
                          style: ThemeTextStyles.labelMedium(context).copyWith(
                            color: extraColors.primaryColor,
                          ),
                        ),
                      ),
                      WidthSpace(AppSpacing.spaceXs),
                      Icon(
                        Icons.arrow_forward,
                        color: extraColors.primaryColor,
                        size: AppSizes.iconSm,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
