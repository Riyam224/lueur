import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';

/// Canonical app bar used by every pushed/detail screen so back-button
/// style, title style, height, and top spacing stay identical app-wide.
/// Root tab screens (home, journal, profile) keep their own greeting-style
/// headers and don't use this widget.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    this.title,
    this.titleWidget,
    this.titleColor,
    this.actions,
    this.showBackButton = true,
    this.onBack,
  }) : assert(
          title == null || titleWidget == null,
          'Provide either title or titleWidget, not both.',
        );

  final String? title;
  final Widget? titleWidget;
  final Color? titleColor;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final extra = context.extra;

    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: AppSizes.iconSm,
                color: extra.primaryTextColor,
              ),
              onPressed: onBack ?? () => context.pop(),
            )
          : null,
      title: titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: ThemeTextStyles.headlineSmall(context)
                      .copyWith(color: titleColor),
                )
              : null),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
