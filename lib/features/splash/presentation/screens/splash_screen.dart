import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lueur/core/preferences/onboarding_prefs.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_text_styles.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/utils/app_strings.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_state.dart';
import 'package:lueur/features/splash/presentation/constants/splash_constants.dart';
import 'package:lueur/features/splash/presentation/widgets/splash_blob.dart';
import 'package:lueur/features/splash/presentation/widgets/splash_plant_scene.dart';

/// The in-app splash — a warm, static "Luna and her plant" scene that fades
/// in right after the native splash hands off. Native splash can only show
/// a flat background + a single static image, so the full composition
/// (typography hierarchy, blobs, staggered fade) lives here instead.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _logoFade;
  late final Animation<double> _sceneFade;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: SplashConstants.entranceDuration,
    );
    _logoFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(
        0.0,
        SplashConstants.logoFadeEnd,
        curve: Curves.easeOut,
      ),
    );
    _sceneFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(
        SplashConstants.sceneFadeStart,
        1.0,
        curve: Curves.easeOut,
      ),
    );
    _entranceController.forward();
    _navigate();
  }

  @override
  void dispose() {
    _entranceController.dispose();
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
    final extra = context.extra;

    return Scaffold(
      body: Stack(
        children: [
          // ── Blobs ──────────────────────────────────────────────────────
          SplashBlob(
            size: size.width * SplashConstants.blobOneSizeFraction,
            alignment: Alignment.topLeft,
            color: extra.blobColorOne!,
            opacity: SplashConstants.blobOneOpacity,
          ),
          SplashBlob(
            size: size.width * SplashConstants.blobTwoSizeFraction,
            alignment: Alignment.topRight,
            color: extra.blobColorTwo!,
            opacity: SplashConstants.blobTwoOpacity,
          ),
          SplashBlob(
            size: size.width * SplashConstants.blobThreeSizeFraction,
            alignment: Alignment.bottomRight,
            color: extra.blobColorThree!,
            opacity: SplashConstants.blobThreeOpacity,
          ),

          // ── Content ────────────────────────────────────────────────────
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: size.height * SplashConstants.topSpacerFraction),
                FadeTransition(
                  opacity: _logoFade,
                  child: Column(
                    children: [
                      Text(
                        AppStrings.appName,
                        style: AppTextStyles.displayLarge(context).copyWith(
                          fontSize: SplashConstants.titleFontSize.sp,
                          color: extra.primaryTextColor,
                        ),
                      ),
                      SizedBox(
                        height: size.height *
                            SplashConstants.titleToTaglineSpacingFraction,
                      ),
                      Text(
                        AppStrings.appTagline,
                        style: GoogleFonts.dmSans(
                          fontSize: SplashConstants.taglineFontSize.sp,
                          letterSpacing: SplashConstants.taglineLetterSpacing,
                          color: extra.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height:
                      size.height * SplashConstants.taglineToSceneSpacingFraction,
                ),
                FadeTransition(
                  opacity: _sceneFade,
                  child: Column(
                    children: [
                      SplashPlantScene(
                        potHeight:
                            size.width * SplashConstants.potHeightFraction,
                      ),
                      SizedBox(
                        height: size.height *
                            SplashConstants.sceneToCaptionSpacingFraction,
                      ),
                      Text(
                        AppStrings.appSplashCaption,
                        style: GoogleFonts.dmSans(
                          fontSize: SplashConstants.captionFontSize.sp,
                          color: extra.secondaryTextColor!.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
