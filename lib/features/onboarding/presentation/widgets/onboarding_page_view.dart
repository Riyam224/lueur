import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lueur/core/styling/app_assets.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/features/onboarding/presentation/constants/onboarding_constants.dart';
import 'package:lueur/features/onboarding/presentation/models/onboarding_page_data.dart';

/// A single onboarding card: a big circle + Luna behind a theme badge,
/// then a headline/subtitle. Listens to [pageController] so it can scale,
/// fade and slide itself based on how far it is from the current page —
/// the "sliding back and forth" animation for the whole flow.
class OnboardingPageView extends StatelessWidget {
  final OnboardingPageData data;
  final int index;
  final PageController pageController;

  const OnboardingPageView({
    super.key,
    required this.data,
    required this.index,
    required this.pageController,
  });

  double _pageDelta() {
    if (!pageController.hasClients || !pageController.position.haveDimensions) {
      return 0;
    }
    final page = pageController.page ?? pageController.initialPage.toDouble();
    return (page - index).clamp(-1.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, child) {
        final delta = _pageDelta();
        final distance = delta.abs();
        final scale = 1 - OnboardingConstants.parallaxScaleFalloff * distance;
        final opacity =
            (1 - OnboardingConstants.parallaxOpacityFalloff * distance)
                .clamp(0.0, 1.0);

        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Padding(
              padding: const EdgeInsets.only(
                top: OnboardingConstants.navRowBottomPadding,
              ),
              child: _OnboardingCard(
                data: data,
                textSlide: delta * OnboardingConstants.parallaxTextSlide,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  final OnboardingPageData data;
  final double textSlide;

  const _OnboardingCard({required this.data, required this.textSlide});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final circleSize =
            constraints.maxWidth * OnboardingConstants.circleSizeFraction;
        final lunaSize =
            constraints.maxWidth * OnboardingConstants.lunaSizeFraction;

        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth *
                OnboardingConstants.cardHorizontalMarginFraction,
          ),
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            color: data.cardColor,
            borderRadius:
                BorderRadius.circular(OnboardingConstants.cardBorderRadius),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: constraints.maxHeight *
                        OnboardingConstants.circleTopFraction +
                    circleSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: constraints.maxHeight *
                          OnboardingConstants.circleTopFraction,
                      child: Container(
                        width: circleSize,
                        height: circleSize,
                        decoration: BoxDecoration(
                          color: data.circleColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      top: constraints.maxHeight *
                          OnboardingConstants.circleTopFraction,
                      child: SizedBox(
                        width: circleSize,
                        height: circleSize,
                        child: Center(
                          child: Image.asset(
                            AppAssets.lunaCharacter,
                            width: lunaSize,
                            height: lunaSize,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: constraints.maxHeight *
                              OnboardingConstants.circleTopFraction +
                          circleSize * 0.08,
                      right: constraints.maxWidth * 0.14,
                      child: _ThemeBadge(icon: data.badgeIcon, color: data.circleColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: OnboardingConstants.circleToHeadline),
              Transform.translate(
                offset: Offset(textSlide, 0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal:
                        OnboardingConstants.pageTextHorizontalPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: GoogleFonts.nunito(
                          fontSize: OnboardingConstants.pageTitleFontSize,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onboardingHeadline,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(
                        height: OnboardingConstants.headlineToSubtitle,
                      ),
                      Text(
                        data.subtitle,
                        style: GoogleFonts.dmSans(
                          fontSize: OnboardingConstants.pageSubtitleFontSize,
                          fontWeight: FontWeight.w400,
                          color: AppColors.onboardingSubtitle,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ThemeBadge extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _ThemeBadge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: OnboardingConstants.badgeSize,
      height: OnboardingConstants.badgeSize,
      decoration: const BoxDecoration(
        color: AppColors.whiteTextColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: OnboardingConstants.badgeSize * 0.5),
    );
  }
}
