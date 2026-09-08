import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_assets.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/core/widgets/app_top_bar.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Chat screen's app bar — back button + Luna avatar/name title.
class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final extra = context.extra;
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AppTopBar(
      titleWidget: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36.w,
            height: 36.h,
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Image.asset(AppAssets.lunaCharacter, fit: BoxFit.contain),
          ),
          SizedBox(width: AppSpacing.spaceSm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.lunaName,
                style: ThemeTextStyles.titleMedium(context)
                    .copyWith(color: cs.primary),
              ),
              Text(
                l10n.lunaName,
                style: ThemeTextStyles.captionSmall(context)
                    .copyWith(color: extra.secondaryTextColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
