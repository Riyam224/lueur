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

class Lueur extends StatelessWidget {
  const Lueur({required this.initialization, super.key});

  /// Hive/SharedPreferences/DI setup kicked off after runApp(). Nothing
  /// resolving via `sl<T>()` may build until this completes; [build] gates the real app on it.
  final Future<void> initialization;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _AppStartupErrorScreen(error: snapshot.error!);
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
  const _AppStartupErrorScreen({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Something went wrong while starting the app.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
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
