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
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/core/theme/calm_mode_colors.dart';
import 'package:lueur/features/draw/presentation/cubit/draw_cubit.dart';
import 'package:lueur/features/draw/presentation/cubit/draw_state.dart';
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
    return BlocProvider(
      create: (_) => sl<DrawCubit>(),
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: CalmModeColors.navyGradient,
          ),
        ),
        child: SafeArea(
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
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontalPaddingMd,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: CalmModeColors.ink,
              size: 20,
            ),
          ),
          Text(
            'free draw',
            style: ThemeTextStyles.bodyMedium(context).copyWith(
              color: CalmModeColors.mutedInk,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextButton(
            onPressed: () => context.read<DrawCubit>().clear(),
            child: Text(
              'clear',
              style: ThemeTextStyles.bodyMedium(context).copyWith(
                color: CalmModeColors.mutedInk,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas(BuildContext context) {
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
                color: Colors.white.withValues(alpha: 0.04),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
                            ? CalmModeColors.ink
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
    return TextButton(
      onPressed: () => _goToTalkToLuna(context),
      style: TextButton.styleFrom(foregroundColor: CalmModeColors.mutedInk),
      child: Text(
        'feel like talking to luna now?',
        style: ThemeTextStyles.bodySmall(context).copyWith(
          color: CalmModeColors.mutedInk,
        ),
      ),
    );
  }
}
