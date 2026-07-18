import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:lueur_app/core/preferences/onboarding_prefs.dart';
import 'package:lueur_app/core/routing/app_routes.dart';
import 'package:lueur_app/core/styling/app_assets.dart';
import 'package:lueur_app/core/styling/app_colors.dart';
import 'package:lueur_app/core/styling/app_text_styles.dart';
import 'package:lueur_app/core/styling/theme_extensions.dart';
import 'package:lueur_app/core/utils/app_strings.dart';
import 'package:lueur_app/features/splash/presentation/constants/splash_constants.dart';
import 'package:lueur_app/features/splash/presentation/widgets/splash_blob.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
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

    context.go(AppRoutes.loginScreen);
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: size.height * SplashConstants.topSpacerFraction,
                ),
                Text(
                  AppStrings.appName,
                  style: AppTextStyles.displayLarge(context)
                      .copyWith(fontSize: SplashConstants.titleFontSize.sp),
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
                Lottie.asset(
                  AppAssets.lottiePlant,
                  width: size.width * SplashConstants.lottieWidthFraction,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
