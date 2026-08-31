import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/quotes/domain/entities/saved_quote_entity.dart';

/// The bordered "quote" card shared by [SavedQuotesScreen]'s list and
/// [ProfileScreen]'s saved-quotes preview.
class SavedQuoteCard extends StatelessWidget {
  const SavedQuoteCard({
    super.key,
    required this.quote,
    this.emojiFontSize = 20,
    this.showBookmarkIcon = false,
  });

  final SavedQuoteEntity quote;
  final double emojiFontSize;
  final bool showBookmarkIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: AppSpacing.spaceMd),
      padding: EdgeInsets.all(AppSpacing.spaceLg),
      decoration: BoxDecoration(
        color: context.extra.cardBackgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
        border: Border.all(
          color: context.extra.borderColor ??
              Theme.of(context).colorScheme.outline,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (quote.emoji != null) ...[
                Text(
                  quote.emoji!,
                  style: TextStyle(
                    fontSize: emojiFontSize.sp,
                    fontFamilyFallback: const [
                      'Apple Color Emoji',
                      'Noto Color Emoji',
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.spaceSm),
              ],
              Expanded(
                child: Text(
                  '"${quote.text}"',
                  style: ThemeTextStyles.bodyMedium(context),
                ),
              ),
              if (showBookmarkIcon) ...[
                SizedBox(width: AppSpacing.spaceSm),
                Icon(
                  Icons.bookmark_rounded,
                  size: 18.sp,
                  color:
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                ),
              ],
            ],
          ),
          if (quote.thoughts != null && quote.thoughts!.isNotEmpty) ...[
            SizedBox(height: AppSpacing.spaceXs),
            Text(
              quote.thoughts!,
              style: ThemeTextStyles.bodySmall(context).copyWith(
                color: context.extra.secondaryTextColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
