import 'package:ai_therapist_app/core/constants/app_spacing.dart';
import 'package:ai_therapist_app/core/styling/app_colors.dart';
import 'package:ai_therapist_app/core/styling/theme_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Removes all emoji and non-text Unicode symbols from [text].
String _stripEmojis(String text) {
  return text
      .replaceAll(
        RegExp(
          r'[\u{1F000}-\u{1FFFF}]'
          r'|[\u{2600}-\u{27BF}]'
          r'|[\u{FE00}-\u{FEFF}]'
          r'|[\u{1F900}-\u{1F9FF}]'
          r'|[\u{E0000}-\u{E007F}]'
          r'|[\u2700-\u27BF]'
          r'|[\u2300-\u23FF]'
          r'|[\u2B00-\u2BFF]'
          r'|\u200D'
          r'|\uFE0F',
          unicode: true,
        ),
        '',
      )
      .replaceAll(RegExp(r'  +'), ' ')
      .trim();
}

/// AI response card with lavender background showing Luna's response
class AiResponseCardWidget extends StatelessWidget {
  final String response;
  final VoidCallback? onBookmark;

  const AiResponseCardWidget({
    super.key,
    required this.response,
    this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final responseStyle = ThemeTextStyles.bodyMedium(context);
    final cleanedResponse = _stripEmojis(response);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.space2Xl),
      decoration: BoxDecoration(
        color: AppColors.lavender.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.lavender.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Label
          Row(
            children: [
              Text(
                'LUNA SAYS',
                style: ThemeTextStyles.labelSmall(context).copyWith(
                  color: AppColors.lavender,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              if (onBookmark != null)
                IconButton(
                  onPressed: onBookmark,
                  icon: const Icon(Icons.bookmark_border),
                  color: AppColors.lavender,
                  tooltip: 'Save quote',
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          SizedBox(height: AppSpacing.spaceMd),

          // AI Response — emojis stripped to avoid broken glyph rendering
          GestureDetector(
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: cleanedResponse));
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard 🌿')),
              );
            },
            child: Text(
              cleanedResponse,
              style: responseStyle,
            ),
          ),
        ],
      ),
    );
  }
}
