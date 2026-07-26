import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:lueur/core/preferences/onboarding_prefs.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_assets.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/app_text_styles.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/utils/app_strings.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:lueur/features/auth/presentation/cubit/auth_state.dart';
import 'package:lueur/features/splash/presentation/constants/splash_constants.dart';
import 'package:lueur/features/splash/presentation/widgets/splash_blob.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _scale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
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

    return Scaffold(
      body: Stack(
        children: [
          // ── Blobs ──────────────────────────────────────────────────────
          SplashBlob.aligned(
            size: size.width * SplashConstants.blobTopLeftSizeFraction,
            alignment: Alignment.topLeft,
            color: AppColors.lavender,
            opacity: SplashConstants.blobTopLeftOpacity,
          ),

          SplashBlob.aligned(
            size: size.width * SplashConstants.blobTopRightSizeFraction,
            alignment: Alignment.topRight,
            color: AppColors.accent,
            opacity: SplashConstants.blobTopRightOpacity,
          ),

          SplashBlob.aligned(
            size: size.width * SplashConstants.blobBottomLeftSizeFraction,
            alignment: Alignment.bottomLeft,
            color: AppColors.primaryContainer,
            opacity: SplashConstants.blobBottomLeftOpacity,
          ),

          SplashBlob.aligned(
            size: size.width * SplashConstants.blobBottomRightSizeFraction,
            alignment: Alignment.bottomRight,
            color: AppColors.softLavender,
            opacity: SplashConstants.blobBottomRightOpacity,
          ),

          // small accent blobs
          SplashBlob.positioned(
            size: size.width * SplashConstants.blobAccentTopSizeFraction,
            dx: size.width * SplashConstants.blobAccentTopDxFraction,
            dy: size.height * SplashConstants.blobAccentTopDyFraction,
            color: AppColors.accent,
            opacity: SplashConstants.blobAccentTopOpacity,
          ),

          SplashBlob.positioned(
            size: size.width * SplashConstants.blobAccentBottomSizeFraction,
            dx: size.width * SplashConstants.blobAccentBottomDxFraction,
            dy: size.height * SplashConstants.blobAccentBottomDyFraction,
            color: AppColors.primaryContainer,
            opacity: SplashConstants.blobAccentBottomOpacity,
          ),

          // ── Content ────────────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: size.height * SplashConstants.topSpacerFraction,
                    ),
                    Text(
                      AppStrings.appName,
                      style: AppTextStyles.displayLarge(context).copyWith(
                        fontSize: SplashConstants.titleFontSize.sp,
                      ),
                    ),
                    SizedBox(
                      height: size.height *
                          SplashConstants.titleToTaglineSpacingFraction,
                    ),
                    Text(
                      AppStrings.appTagline,
                      style: AppTextStyles.labelSmall(context).copyWith(
                        color: context.extra.secondaryTextColor,
                      ),
                    ),
                    SizedBox(
                      height: size.height *
                          SplashConstants.taglineToLottieSpacingFraction,
                    ),
                    Container(
                      width: size.width * SplashConstants.lottieWidthFraction *
                          1.15,
                      height: size.width * SplashConstants.lottieWidthFraction *
                          1.15,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.pastelBlush,
                      ),
                      alignment: Alignment.center,
                      child: Lottie.asset(
                        AppAssets.lottiePlant,
                        width:
                            size.width * SplashConstants.lottieWidthFraction,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
