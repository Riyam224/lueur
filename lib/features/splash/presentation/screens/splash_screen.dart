import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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

/// The in-app splash — Luna's illustration centered on a solid background,
/// with the app name and tagline beneath, fading in once. Native splash can
/// only show a flat background + a single static image, so this simple
/// scene (same Luna asset, same background) is what takes over the instant
/// Flutter renders its first frame — no visual jump between the two.
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
    await Future.delayed(SplashConstants.navigationDelay);
    if (!mounted) return;
    final seen = await OnboardingPrefs.hasSeen();
    if (!mounted) return;

    if (!seen) {
      context.go(AppRoutes.onBoarding);
      return;
    }

    // Force-refreshes the Firebase ID token so a locally persisted session
    // that has expired or been revoked server-side is caught here, before
    // Home makes its first authenticated API call.
    final authCubit = context.read<AuthCubit>();
    await authCubit.checkSession();
    if (!mounted) return;

    context.go(
      authCubit.state is AuthAuthenticated
          ? AppRoutes.home
          : AppRoutes.loginScreen,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Same brand hue in both themes, just the contrast-safe variant for
    // each background: a deep shade on the light cream backdrop, and the
    // bright pastel itself (which already pops) on the dark plum backdrop.
    final titleColor =
        isDark ? AppColors.lavenderLilac : AppColors.primaryButtonFill;
    final taglineColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.creamBackground;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Painted first, then fully covered by the opaque background
          // below — never visible, but still rasterized so the GPU
          // compiles onboarding's shader pipelines now instead of during
          // the first onboarding swipe.
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
