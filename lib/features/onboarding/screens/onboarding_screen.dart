import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../theme/app_theme.dart';
import '../models/onboarding_page.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_page_widget.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    ref.read(onboardingProvider.notifier).setCurrentPage(page);
  }

  void _nextPage() {
    if (_currentPage < onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    await ref.read(onboardingProvider.notifier).completeOnboarding();
    if (mounted) {
      // Navigation will be handled by main.dart
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final isLastPage = _currentPage == onboardingPages.length - 1;
    final isFirstPage = _currentPage == 0;

    return Scaffold(
      body: Stack(
        children: [
          // PageView with onboarding pages
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: onboardingPages.length,
            itemBuilder: (context, index) {
              return OnboardingPageWidget(
                pageData: onboardingPages[index],
              );
            },
          ),

          // Bottom navigation section
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: isSmallScreen ? 24 : 40,
                right: isSmallScreen ? 24 : 40,
                bottom: isSmallScreen ? 32 : 40,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button (visible on pages 2 and 3)
                  if (!isFirstPage)
                    GestureDetector(
                      onTap: _previousPage,
                      child: Container(
                        width: isSmallScreen ? 50 : 60,
                        height: isSmallScreen ? 50 : 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: AppTheme.primaryOrange,
                          size: isSmallScreen ? 24 : 28,
                        ),
                      ),
                    )
                  else
                    SizedBox(width: isSmallScreen ? 50 : 60),

                  // Page indicator dots
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: onboardingPages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: Colors.white,
                      dotColor: Colors.white.withOpacity(0.4),
                      dotHeight: isSmallScreen ? 8 : 10,
                      dotWidth: isSmallScreen ? 8 : 10,
                      expansionFactor: 3,
                      spacing: isSmallScreen ? 6 : 8,
                    ),
                  ),

                  // Next/Get Started button
                  GestureDetector(
                    onTap: isLastPage ? _completeOnboarding : _nextPage,
                    child: isLastPage
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 24 : 32,
                                  vertical: isSmallScreen ? 14 : 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'Get started',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 16 : 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            width: isSmallScreen ? 50 : 60,
                            height: isSmallScreen ? 50 : 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.arrow_forward,
                              color: AppTheme.primaryOrange,
                              size: isSmallScreen ? 24 : 28,
                            ),
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

