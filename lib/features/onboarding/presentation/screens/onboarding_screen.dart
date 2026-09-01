import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:doctorly/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:doctorly/utils/design_tokens.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isCompleting = false;

  static const _pages = <_OnboardingPageData>[
    _OnboardingPageData(
      icon: Icons.health_and_safety,
      title: 'Your health,\nsimplified',
      subtitle: 'Find trusted specialists, book appointments, and manage your care — all in one place.',
      gradient: [DesignTokens.primaryLight, Colors.white],
    ),
    _OnboardingPageData(
      icon: Icons.medical_services,
      title: 'Expert care,\non demand',
      subtitle: 'Browse verified doctors by specialty, read reviews, and pick the one who fits your needs.',
      gradient: [DesignTokens.primaryLight, Colors.white],
    ),
    _OnboardingPageData(
      icon: Icons.location_on,
      title: 'Care near you',
      subtitle: 'Discover top-rated doctors around you and get directions, ratings, and availability in seconds.',
      gradient: [DesignTokens.primaryLight, Colors.white],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeAndNavigate();
    }
  }

  Future<void> _completeAndNavigate() async {
    if (_isCompleting) return;
    setState(() => _isCompleting = true);
    await ref.read(onboardingProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: DesignTokens.scaffoldBackground,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: DesignTokens.xs,
              right: DesignTokens.xs,
              child: TextButton(
                onPressed: _completeAndNavigate,
                style: TextButton.styleFrom(
                  foregroundColor: DesignTokens.textSecondary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.md,
                    vertical: 10,
                  ),
                ),
                child: Text(
                  'Skip',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      return _OnboardingPage(page: _pages[index]);
                    },
                  ),
                ),
                _PageIndicators(count: _pages.length, current: _currentPage),
                const SizedBox(height: DesignTokens.xl),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.xl,
                    vertical: DesignTokens.md,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignTokens.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: Text(isLast ? 'Get Started' : 'Next'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.page});
  final _OnboardingPageData page;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.xl, vertical: DesignTokens.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: page.gradient,
                ),
                boxShadow: [
                  BoxShadow(
                    color: DesignTokens.primary.withValues(alpha: 0.10),
                    blurRadius: 40,
                    spreadRadius: 0,
                    offset: const Offset(0, 16),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.6),
                    blurRadius: 0,
                    spreadRadius: 1,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Center(
                child: Icon(page.icon, size: 64, color: DesignTokens.primary),
              ),
            ),
            const SizedBox(height: DesignTokens.lg),
            Text(
              page.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: DesignTokens.textPrimary,
                height: 1.15,
              ),
            ),
            const SizedBox(height: DesignTokens.sm),
            Text(
              page.subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: DesignTokens.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageIndicators extends StatelessWidget {
  const _PageIndicators({required this.count, required this.current});
  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? DesignTokens.primary : DesignTokens.divider,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
}
