import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/draw/domain/entities/saved_drawing_entity.dart';
import 'package:lueur/features/draw/presentation/cubit/saved_drawings_cubit.dart';
import 'package:lueur/features/draw/presentation/cubit/saved_drawings_state.dart';
import 'package:lueur/features/draw/presentation/widgets/saved_drawing_thumbnail.dart';
import 'package:lueur/l10n/app_localizations.dart';

class ProfileSavedDrawingsSectionWidget extends StatelessWidget {
  const ProfileSavedDrawingsSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SavedDrawingsCubit, SavedDrawingsState>(
      builder: (context, state) {
        if (state is SavedDrawingsError) {
          return _EmptyCard(
            emoji: '🎨',
            title: AppLocalizations.of(context)!.profileDrawingsTitle,
            subtitle: AppLocalizations.of(context)!.profileDrawingsErrorSubtitle,
          );
        }
        if (state is! SavedDrawingsLoaded) return const SizedBox.shrink();

        if (state.drawings.isEmpty) {
          return _EmptyCard(
            emoji: '🎨',
            title: AppLocalizations.of(context)!.profileDrawingsTitle,
            subtitle: AppLocalizations.of(context)!.profileDrawingsEmptySubtitle,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.profileDrawingsTitle, style: ThemeTextStyles.headlineSmall(context)),
            SizedBox(height: AppSpacing.spaceSm),
            SizedBox(
              height: 96.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: state.drawings.length,
                separatorBuilder: (_, __) => SizedBox(width: AppSpacing.spaceSm),
                itemBuilder: (context, index) {
                  final drawing = state.drawings[index];
                  return _DrawingTile(drawing: drawing);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DrawingTile extends StatelessWidget {
  final SavedDrawingEntity drawing;

  const _DrawingTile({required this.drawing});

  void _delete(BuildContext context) {
    context.read<SavedDrawingsCubit>().deleteDrawing(drawing.id);
  }

  void _open(BuildContext context) {
    context.push(
      AppRoutes.savedDrawingViewer,
      extra: {'drawing': drawing, 'onDelete': () => _delete(context)},
    );
  }

  @override
  Widget build(BuildContext context) {
    final extra = context.extra;

    return GestureDetector(
      onTap: () => _open(context),
      child: Stack(
        children: [
          Container(
            width: 96.w,
            height: 96.h,
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: extra.cardBackgroundColor,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
              border: Border.all(
                color: extra.borderColor ?? AppColors.cardBorder,
              ),
            ),
            child: SavedDrawingThumbnail(drawing: drawing),
          ),
          Positioned(
            top: 2.h,
            right: 2.w,
            child: GestureDetector(
              onTap: () => _delete(context),
              child: Container(
                width: 22.w,
                height: 22.w,
                decoration: const BoxDecoration(
                  color: AppColors.errorColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: AppColors.whiteTextColor,
                  size: 14.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const _EmptyCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.spaceLg),
      decoration: BoxDecoration(
        color: context.extra.cardBackgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
        border: Border.all(
          color: context.extra.borderColor ?? Theme.of(context).colorScheme.outline,
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: AppSizes.iconLg)),
          SizedBox(height: AppSpacing.spaceSm),
          Text(title, style: ThemeTextStyles.titleMedium(context)),
          SizedBox(height: AppSpacing.spaceXs),
          Text(
            subtitle,
            style: ThemeTextStyles.bodySmall(context)
                .copyWith(color: context.extra.secondaryTextColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
