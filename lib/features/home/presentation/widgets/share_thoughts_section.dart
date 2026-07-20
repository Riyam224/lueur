import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/core/widgets/spacing_widgets.dart';

/// Section for users to share their thoughts and talk to Luna
class ShareThoughtsSection extends StatefulWidget {
  const ShareThoughtsSection({super.key});

  @override
  State<ShareThoughtsSection> createState() => _ShareThoughtsSectionState();
}

class _ShareThoughtsSectionState extends State<ShareThoughtsSection> {
  final TextEditingController _thoughtsController = TextEditingController();

  @override
  void dispose() {
    _thoughtsController.dispose();
    super.dispose();
  }

  void _onTalkToLuna() {
    final thoughts = _thoughtsController.text.trim();
    if (thoughts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please share your thoughts first')),
      );
      return;
    }

    // TODO: Implement share mood functionality with selected emoji and thoughts
    GoRouter.of(context).push('/response');
    debugPrint('Talk to Luna button pressed with: $thoughts');
  }

  @override
  Widget build(BuildContext context) {
    final extraColors = context.extra;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SHARE YOUR THOUGHTS', style: ThemeTextStyles.labelLarge(context)),
        HeightSpace(AppSpacing.spaceLg),

        // Thoughts Input Field
        TextField(
          controller: _thoughtsController,
          maxLines: 5,
          maxLength: 500,
          style: ThemeTextStyles.bodyMedium(context),
          decoration: InputDecoration(
            hintText: 'What\'s on your mind today...',
            hintStyle: ThemeTextStyles.bodySmall(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
              borderSide: BorderSide(
                color: extraColors.primaryColor!,
                width: 1.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
              borderSide: BorderSide(
                color: extraColors.primaryColor!,
                width: 2.w,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
              borderSide: BorderSide(
                color: extraColors.borderColor!,
                width: 1.w,
              ),
            ),
            contentPadding: EdgeInsets.all(AppSpacing.horizontalPaddingMd),
          ),
        ),
        HeightSpace(AppSpacing.spaceLg),

        // Talk to Luna Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _onTalkToLuna,
            style: ElevatedButton.styleFrom(
              backgroundColor: extraColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.horizontalPaddingXl,
                vertical: AppSpacing.verticalPaddingLg,
              ),
            ),
            child: Text(
              'Talk to Luna ✨',
              style: ThemeTextStyles.whiteButton(context),
            ),
          ),
        ),
      ],
    );
  }
}
