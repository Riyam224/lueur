import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/preferences/onboarding_prefs.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_state.dart';
import 'package:lueur/features/splash/presentation/constants/splash_constants.dart';
import 'package:lueur/features/splash/presentation/widgets/luna_face.dart';

/// The in-app splash — a calm, minimal moment: just Luna's eyes and a
/// closed smile on a solid color, fading in. Native splash can only show
/// a flat background + a single static image, so this simple scene is
/// the first real Flutter frame the user sees.
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

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lavenderLilac,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: LunaFace(eyeSize: size.width * SplashConstants.eyeSizeFraction),
        ),
      ),
    );
  }
}
