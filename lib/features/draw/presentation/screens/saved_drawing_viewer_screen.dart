import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/core/utils/app_strings.dart';
import 'package:lueur/features/draw/domain/entities/saved_drawing_entity.dart';
import 'package:lueur/features/draw/presentation/widgets/draw_painter.dart';
import 'package:lueur/features/draw/presentation/widgets/saved_drawing_thumbnail.dart';

/// Read-only replay of a saved drawing — no editing controls, just a
/// full-size look and a way to delete it.
class SavedDrawingViewerScreen extends StatelessWidget {
  final SavedDrawingEntity drawing;
  final VoidCallback onDelete;

  const SavedDrawingViewerScreen({
    super.key,
    required this.drawing,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final extra = context.extra;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.horizontalPaddingMd,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: extra.primaryTextColor,
                      size: 20,
                    ),
                  ),
                  Text(
                    AppStrings.drawViewerTitle,
                    style: ThemeTextStyles.bodyMedium(context).copyWith(
                      color: extra.secondaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      onDelete();
                      context.pop();
                    },
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.errorColor,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.spaceMd),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.horizontalPaddingLg,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.r),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: extra.cardBackgroundColor,
                      border: Border.all(
                        color: extra.borderColor ?? AppColors.cardBorder,
                      ),
                    ),
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: DrawPainter(paths: drawPathsFromEntity(drawing)),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.spaceLg),
          ],
        ),
      ),
    );
  }
}
