import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/preferences/auth_prefs.dart';
import 'package:lueur/core/preferences/onboarding_prefs.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_assets.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/app_text_styles.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_state.dart';
import 'package:lueur/features/splash/presentation/constants/splash_constants.dart';
import 'package:lueur/features/splash/presentation/widgets/splash_shader_warmup.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// In-app splash shown right after the native splash (same asset/background)
/// so there's no visual jump — native splash can only show a static image.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: SplashConstants.fadeInDuration,
    );
    _fade = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
    _navigate();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    final authCubit = context.read<AuthCubit>();

    // Run the minimum splash hold concurrently with the session-check work
    // so total wait is max(delay, work), not delay + work.
    final results = await Future.wait([
      Future.delayed(SplashConstants.navigationDelay),
      OnboardingPrefs.hasSeen(),
    ]);
    if (!mounted) return;

    final seen = results[1] as bool;
    if (!seen) {
      context.go(AppRoutes.onBoarding);
      return;
    }

    // Force-refreshes the Firebase ID token so an expired/revoked session
    // is caught here, before Home's first authenticated API call.
    await authCubit.checkSession();
    if (!mounted) return;

    if (authCubit.state is AuthAuthenticated) {
      context.go(AppRoutes.home);
      return;
    }

    // No prior successful sign-in means a first-ever install — land on
    // Register instead of Login since there's no account to log into yet.
    final hasEverAuthenticated = await AuthPrefs.hasEverAuthenticated();
    if (!mounted) return;
    context.go(
      hasEverAuthenticated ? AppRoutes.loginScreen : AppRoutes.registerScreen,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Same brand hue in both themes, just the contrast-safe variant per
    // background — a deep shade on light cream, the bright pastel on dark plum.
    final titleColor =
        isDark ? AppColors.lavenderLilac : AppColors.primaryButtonFill;
    final taglineColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Painted first, then fully covered below — never visible, but
          // still rasterized so the GPU compiles onboarding's shaders now, not during the first swipe.
          const Positioned.fill(child: SplashShaderWarmup()),
          Positioned.fill(child: ColoredBox(color: backgroundColor)),
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    AppAssets.lunaCharacter,
                    width: size.width * SplashConstants.lunaSizeFraction,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: SplashConstants.lunaToTitleGap),
                  Text(
                    AppLocalizations.of(context)!.appName,
                    style: AppTextStyles.headlineLarge(context).copyWith(
                      fontSize: SplashConstants.titleFontSize,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: SplashConstants.titleToTaglineGap),
                  Text(
                    AppLocalizations.of(context)!.appTagline,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      fontSize: SplashConstants.taglineFontSize,
                      fontWeight: FontWeight.w500,
                      color: taglineColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
