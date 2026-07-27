// lib/features/draw/presentation/screens/free_draw_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/injection/injection.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/core/utils/app_strings.dart';
import 'package:lueur/features/draw/domain/entities/saved_drawing_entity.dart';
import 'package:lueur/features/draw/presentation/cubit/draw_cubit.dart';
import 'package:lueur/features/draw/presentation/cubit/draw_state.dart';
import 'package:lueur/features/draw/presentation/cubit/saved_drawings_cubit.dart';
import 'package:lueur/features/draw/presentation/widgets/draw_painter.dart';

class FreeDrawScreen extends StatelessWidget {
  final String emoji;
  final String thoughts;

  const FreeDrawScreen({
    super.key,
    required this.emoji,
    this.thoughts = '',
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<DrawCubit>()),
        BlocProvider(create: (_) => sl<SavedDrawingsCubit>()),
      ],
      child: _FreeDrawView(emoji: emoji, thoughts: thoughts),
    );
  }
}

class _FreeDrawView extends StatelessWidget {
  static const List<Color> _palette = [
    AppColors.lavender,
    AppColors.darkMintTeal,
    AppColors.breathingGradientPeach,
    AppColors.darkSunsetPeach,
    AppColors.lightOnBackground,
  ];

  final String emoji;
  final String thoughts;

  const _FreeDrawView({required this.emoji, required this.thoughts});

  void _saveDrawing(BuildContext context) {
    final paths = context.read<DrawCubit>().state.paths;
    if (paths.isEmpty) return;

    final entities = paths
        .map(
          (p) => SavedDrawingPathEntity(
            colorArgb: p.color.toARGB32(),
            points: p.points.map((pt) => (pt.dx, pt.dy)).toList(),
          ),
        )
        .toList();

    context.read<SavedDrawingsCubit>().saveCurrent(entities);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.drawSavedSnack),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _goToTalkToLuna(BuildContext context) {
    context.push(
      AppRoutes.chat,
      extra: {
        'userId': sl<FirebaseAuth>().currentUser?.uid ?? '',
        'emoji': emoji,
        'thoughts': thoughts,
        'aiResponse': '',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            SizedBox(height: AppSpacing.spaceMd),
            Expanded(child: _buildCanvas(context)),
            SizedBox(height: AppSpacing.spaceLg),
            _buildPalette(context),
            SizedBox(height: AppSpacing.spaceLg),
            _buildTalkToLunaLink(context),
            SizedBox(height: AppSpacing.spaceMd),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final extra = context.extra;

    return Padding(
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
            AppStrings.drawTopBarTitle,
            style: ThemeTextStyles.bodyMedium(context).copyWith(
              color: extra.secondaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: () => _saveDrawing(context),
            icon: Icon(
              Icons.save_alt_rounded,
              color: extra.primaryColor,
              size: 20,
            ),
          ),
          TextButton(
            onPressed: () => context.read<DrawCubit>().clear(),
            child: Text(
              AppStrings.drawClearButton,
              style: ThemeTextStyles.bodyMedium(context).copyWith(
                color: extra.secondaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas(BuildContext context) {
    final extra = context.extra;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontalPaddingLg,
      ),
      child: BlocBuilder<DrawCubit, DrawState>(
        builder: (context, state) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: extra.cardBackgroundColor,
                border: Border.all(
                  color: extra.borderColor ?? AppColors.cardBorder,
                ),
              ),
              child: GestureDetector(
                onPanStart: (details) =>
                    context.read<DrawCubit>().startStroke(details.localPosition),
                onPanUpdate: (details) =>
                    context.read<DrawCubit>().extendStroke(details.localPosition),
                child: CustomPaint(
                  size: Size.infinite,
                  painter: DrawPainter(paths: state.paths),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPalette(BuildContext context) {
    final extra = context.extra;

    return BlocBuilder<DrawCubit, DrawState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final color in _palette)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: GestureDetector(
                  onTap: () => context.read<DrawCubit>().selectColor(color),
                  child: Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      border: Border.all(
                        color: state.currentColor == color
                            ? extra.primaryTextColor!
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildTalkToLunaLink(BuildContext context) {
    final secondaryText = context.extra.secondaryTextColor;

    return TextButton(
      onPressed: () => _goToTalkToLuna(context),
      style: TextButton.styleFrom(foregroundColor: secondaryText),
      child: Text(
        AppStrings.drawTalkToLunaLink,
        style: ThemeTextStyles.bodySmall(context).copyWith(
          color: secondaryText,
        ),
      ),
    );
  }
}
