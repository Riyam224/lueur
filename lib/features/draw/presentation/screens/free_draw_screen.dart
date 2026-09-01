import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/injection/injection.dart';
import 'package:lueur/core/journal/journal_refresh_signal.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_state.dart';
import 'package:lueur/features/draw/domain/entities/saved_drawing_entity.dart';
import 'package:lueur/features/draw/presentation/cubit/draw_cubit.dart';
import 'package:lueur/features/draw/presentation/cubit/saved_drawings_cubit.dart';
import 'package:lueur/features/draw/presentation/cubit/saved_drawings_state.dart';
import 'package:lueur/features/draw/presentation/widgets/draw_canvas.dart';
import 'package:lueur/features/draw/presentation/widgets/draw_palette.dart';
import 'package:lueur/features/draw/presentation/widgets/draw_talk_to_luna_link.dart';
import 'package:lueur/features/draw/presentation/widgets/draw_top_bar.dart';
import 'package:lueur/features/home/domain/usecases/log_activity_usecase.dart';
import 'package:lueur/l10n/app_localizations.dart';

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
    unawaited(
      sl<LogActivityUseCase>()(
        entryType: 'drawing',
        payload: {'thumbnail_url': ''},
      ).then(
        (result) => result.fold(
          (failure) {
            if (kDebugMode) {
              Logger().w(
                'FreeDrawScreen: failed to log activity — ${failure.message}',
              );
            }
          },
          (_) => sl<JournalRefreshSignal>().bump(),
        ),
      ),
    );
  }

  void _goToTalkToLuna(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : '';
    context.push(
      AppRoutes.chat,
      extra: {
        'userId': userId,
        'emoji': emoji,
        'thoughts': thoughts,
        'aiResponse': '',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SavedDrawingsCubit, SavedDrawingsState>(
      listenWhen: (previous, current) =>
          current is SavedDrawingsError || current is SavedDrawingsLoaded,
      listener: (context, state) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              state is SavedDrawingsError
                  ? l10n.drawSaveErrorSnack
                  : l10n.drawSavedSnack,
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              DrawTopBar(
                onBack: () => context.pop(),
                onSave: () => _saveDrawing(context),
              ),
              SizedBox(height: AppSpacing.spaceMd),
              const Expanded(child: DrawCanvas()),
              SizedBox(height: AppSpacing.spaceLg),
              const DrawPalette(),
              SizedBox(height: AppSpacing.spaceLg),
              DrawTalkToLunaLink(onTap: () => _goToTalkToLuna(context)),
              SizedBox(height: AppSpacing.spaceMd),
            ],
          ),
        ),
      ),
    );
  }
}
