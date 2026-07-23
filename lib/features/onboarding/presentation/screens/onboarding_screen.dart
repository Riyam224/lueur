import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/preferences/onboarding_prefs.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/features/onboarding/presentation/constants/onboarding_constants.dart';
import 'package:lueur/features/onboarding/presentation/widgets/onboarding_nav_button.dart';
import 'package:lueur/features/onboarding/presentation/widgets/onboarding_page_view.dart';
import 'package:lueur/features/onboarding/presentation/widgets/onboarding_skip_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isLastPage =>
      _currentPage == OnboardingConstants.pages.length - 1;

  Future<void> _finishOnboarding() async {
    await OnboardingPrefs.markSeen();
    if (!mounted) return;
    context.go(AppRoutes.loginScreen);
  }

  void _onNextPressed() {
    if (_isLastPage) {
      _finishOnboarding();
      return;
    }
    _pageController.nextPage(
      duration: OnboardingConstants.pageTransitionDuration,
      curve: OnboardingConstants.pageTransitionCurve,
    );
  }

  void _onBackPressed() {
    if (_currentPage == 0) return;
    _pageController.previousPage(
      duration: OnboardingConstants.pageTransitionDuration,
      curve: OnboardingConstants.pageTransitionCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentData = OnboardingConstants.pages[_currentPage];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: OnboardingConstants.pages.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                return OnboardingPageView(
                  data: OnboardingConstants.pages[index],
                  index: index,
                  pageController: _pageController,
                );
              },
            ),
            Positioned(
              left: OnboardingConstants.navRowHorizontalPadding,
              right: OnboardingConstants.navRowHorizontalPadding,
              bottom: OnboardingConstants.navRowBottomPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      OnboardingNavButton(
                        onPressed: _onBackPressed,
                        icon: Icons.arrow_back_rounded,
                        color: currentData.circleColor.withValues(alpha: 0.5),
                        enabled: _currentPage > 0,
                      ),
                      const SizedBox(width: OnboardingConstants.navArrowGap),
                      OnboardingNavButton(
                        onPressed: _onNextPressed,
                        icon: _isLastPage
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded,
                        color: currentData.circleColor,
                      ),
                    ],
                  ),
                  if (!_isLastPage)
                    OnboardingSkipButton(onPressed: _finishOnboarding)
                  else
                    const SizedBox(width: OnboardingConstants.navArrowButtonSize),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
