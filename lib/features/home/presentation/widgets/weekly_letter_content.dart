import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/home/data/models/weekly_letter_model.dart';
import 'package:lueur/features/home/presentation/utils/weekly_letter_copy.dart';
import 'package:lueur/features/home/presentation/widgets/weekly_letter_stat_chip.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Title/dismiss row, stat chips, and the (expandable) letter body itself.
class WeeklyLetterContent extends StatefulWidget {
  const WeeklyLetterContent({
    super.key,
    required this.data,
    required this.onDismiss,
  });

  final WeeklyLetterModel data;
  final VoidCallback onDismiss;

  @override
  State<WeeklyLetterContent> createState() => _WeeklyLetterContentState();
}

class _WeeklyLetterContentState extends State<WeeklyLetterContent> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stats = widget.data.stats;
    final hasLetter =
        widget.data.letter != null && widget.data.letter!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.spaceLg,
        AppSpacing.spaceSm,
        AppSpacing.spaceMd,
        AppSpacing.spaceSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: title + dismiss ──────────────────────────
          Row(
            children: [
              Text(
                '✉️',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontFamilyFallback: const [
                    'Apple Color Emoji',
                    'Noto Color Emoji',
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.spaceSm),
              Expanded(
                child: Text(
                  l10n.weeklyLetterBannerTitle,
                  style: ThemeTextStyles.labelMedium(context).copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              // A visually small icon inside a full 44dp tap target — the
              // extra hit area is transparent, so it doesn't change the
              // card's visible height while still meeting the minimum
              // accessible touch-target size.
              SizedBox(
                width: AppSizes.minTouchTarget,
                height: AppSizes.minTouchTarget,
                child: IconButton(
                  onPressed: widget.onDismiss,
                  icon: Icon(Icons.close_rounded, size: 18.sp),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  color: context.extra.secondaryTextColor,
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.spaceSm),

          // ── Stats row ─────────────────────────────────────────
          Row(
            children: [
              Flexible(
                child: WeeklyLetterStatChip(
                  label: l10n.weeklyLetterEntriesChip(stats.entryCount),
                  icon: Icons.edit_note_rounded,
                ),
              ),
              SizedBox(width: AppSpacing.spaceSm),
              Flexible(
                child: WeeklyLetterStatChip(
                  label: l10n.weeklyLetterStreakChip(stats.streak),
                  isEmoji: true,
                ),
              ),
              SizedBox(width: AppSpacing.spaceSm),
              Flexible(
                child: WeeklyLetterStatChip(
                  label: cuteWeeklyEmoji(stats.dominantEmoji),
                  isEmoji: true,
                ),
              ),
            ],
          ),

          // ── Letter body (expandable) ───────────────────────────
          if (hasLetter) ...[
            SizedBox(height: AppSpacing.spaceSm),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Text(
                  widget.data.letter!,
                  key: ValueKey(_expanded),
                  maxLines: _expanded ? null : 1,
                  overflow: _expanded ? null : TextOverflow.ellipsis,
                  style: ThemeTextStyles.bodySmall(context).copyWith(
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.spaceXs),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.spaceXs),
                child: Text(
                  _expanded
                      ? l10n.weeklyLetterShowLess
                      : l10n.weeklyLetterReadMore,
                  style: ThemeTextStyles.labelSmall(context).copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ] else ...[
            SizedBox(height: AppSpacing.spaceSm),
            Text(
              l10n.weeklyLetterWaitingMessage,
              style: ThemeTextStyles.bodySmall(context).copyWith(
                color: context.extra.secondaryTextColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
