import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';

/// A "Month Year" divider row used to separate month sections in the
/// timeline.
class MonthSeparatorWidget extends StatelessWidget {
  const MonthSeparatorWidget({super.key, required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final label = DateFormat('MMMM yyyy', locale).format(month);
    final color = context.extra.secondaryTextColor;

    return Row(
      children: [
        Expanded(child: Divider(color: color?.withValues(alpha: 0.3))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.spaceMd),
          child: Text(
            label,
            style: ThemeTextStyles.labelMedium(context).copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(child: Divider(color: color?.withValues(alpha: 0.3))),
      ],
    );
  }
}
