import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur_app/core/preferences/onboarding_prefs.dart';
import 'package:lueur_app/core/routing/app_routes.dart';
import 'package:lueur_app/features/onboarding/presentation/constants/onboarding_constants.dart';
import 'package:lueur_app/features/onboarding/presentation/widgets/onboarding_next_button.dart';
import 'package:lueur_app/features/onboarding/presentation/widgets/onboarding_page_indicator.dart';
import 'package:lueur_app/features/onboarding/presentation/widgets/onboarding_page_view.dart';
import 'package:lueur_app/features/onboarding/presentation/widgets/onboarding_skip_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: OnboardingConstants.pages.length,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    return OnboardingPageView(
                      data: OnboardingConstants.pages[index],
                    );
                  },
                ),
                if (!_isLastPage)
                  SafeArea(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: OnboardingConstants.skipButtonTopPadding,
                          right: OnboardingConstants.skipButtonRightPadding,
                        ),
                        child: OnboardingSkipButton(onPressed: _finishOnboarding),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: OnboardingConstants.subtitleToDots),
                OnboardingPageIndicator(
                  pageCount: OnboardingConstants.pages.length,
                  currentPage: _currentPage,
                ),
                const SizedBox(height: OnboardingConstants.dotsToButton),
                OnboardingNextButton(
                  onPressed: _onNextPressed,
                  isLastPage: _isLastPage,
                ),
                const SizedBox(height: OnboardingConstants.buttonToBottom),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
