import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/injection/injection.dart';
import 'package:lueur/core/routing/router_generation_config.dart';
import 'package:lueur/core/styling/app_assets.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/app_theme.dart';
import 'package:lueur/features/language/presentation/cubit/language_cubit.dart';
import 'package:lueur/features/theme/domain/entities/app_theme_mode.dart';
import 'package:lueur/features/theme/presentation/cubit/theme_cubit.dart';
import 'package:lueur/l10n/app_localizations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class Lueur extends StatelessWidget {
  const Lueur({required this.initializer, super.key});

  /// Kicks off Hive/SharedPreferences/DI setup after runApp(). Nothing
  /// resolving via `sl<T>()` may build until this completes; [build] gates the real app on it.
  /// Taking the function (not an already-started Future) lets the startup
  /// error screen retry by calling it again instead of forcing a restart.
  final Future<void> Function() initializer;

  @override
  Widget build(BuildContext context) {
    return _AppInitGate(initializer: initializer);
  }
}

class _AppInitGate extends StatefulWidget {
  const _AppInitGate({required this.initializer});

  final Future<void> Function() initializer;

  @override
  State<_AppInitGate> createState() => _AppInitGateState();
}

class _AppInitGateState extends State<_AppInitGate> {
  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _runInitializer();
  }

  void _retry() {
    setState(() {
      _initialization = _runInitializer();
    });
  }

  Future<void> _runInitializer() {
    final future = widget.initializer();
    unawaited(
      future.catchError((Object error, StackTrace stackTrace) {
        unawaited(Sentry.captureException(error, stackTrace: stackTrace));
      }),
    );
    return future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _AppStartupErrorScreen(
            error: snapshot.error!,
            onRetry: _retry,
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const _AppLoadingScreen();
        }
        return const _LueurApp();
      },
    );
  }
}

/// Shown while background init (Hive, DI, etc.) is still running. Must not
/// depend on AppLocalizations or any `sl<T>()` cubit — neither is ready yet.
class _AppLoadingScreen extends StatelessWidget {
  const _AppLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(AppAssets.lunaCharacter, width: 160, height: 160),
              const SizedBox(height: 24),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown if background init throws (e.g. Hive box corruption) — a blank
/// frozen loading spinner would otherwise look like a hang.
class _AppStartupErrorScreen extends StatelessWidget {
  const _AppStartupErrorScreen({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return Scaffold(
            backgroundColor: AppColors.lightBackground,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      AppAssets.lunaCharacter,
                      width: 120,
                      height: 120,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.startupErrorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.startupErrorSubtext,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: onRetry,
                      child: Text(l10n.startupErrorRetry),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LueurApp extends StatelessWidget {
  const _LueurApp();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<ThemeCubit>()),
        BlocProvider.value(value: sl<LanguageCubit>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BlocBuilder<ThemeCubit, ThemeModeOption>(
            builder: (context, themeModeOption) {
              return BlocBuilder<LanguageCubit, Locale>(
                builder: (context, locale) {
                  return MaterialApp.router(
                    debugShowCheckedModeBanner: false,
                    onGenerateTitle: (context) =>
                        AppLocalizations.of(context)!.appName,
                    theme: AppTheme.light,
                    darkTheme: AppTheme.dark,
                    themeMode: themeModeOption.toThemeMode(),
                    locale: locale,
                    localizationsDelegates: const [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: AppLocalizations.supportedLocales,
                    routerConfig: RouterGenerationConfig.goRouter,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
