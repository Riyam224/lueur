import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/widgets/app_top_bar.dart';
import 'package:lueur/features/draw/domain/entities/saved_drawing_entity.dart';
import 'package:lueur/features/draw/presentation/widgets/draw_painter.dart';
import 'package:lueur/features/draw/presentation/widgets/saved_drawing_thumbnail.dart';
import 'package:lueur/l10n/app_localizations.dart';

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
      appBar: AppTopBar(
        title: AppLocalizations.of(context)!.drawViewerTitle,
        actions: [
          IconButton(
            onPressed: () {
              onDelete();
              context.pop();
            },
            icon: Icon(
              Icons.delete_outline_rounded,
              color: AppColors.errorColor,
              size: AppSizes.iconSm,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
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
