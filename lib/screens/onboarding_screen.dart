import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pages = <_OnboardingPageData>[
    _OnboardingPageData(
      icon: Icons.health_and_safety,
      title: 'Your health,\nsimplified',
      subtitle: 'Find trusted specialists, book appointments, and manage your care — all in one place.',
      gradient: [Color(0xFFE0F0FF), Color(0xFFFFFFFF)],
    ),
    _OnboardingPageData(
      icon: Icons.medical_services,
      title: 'Expert care,\non demand',
      subtitle: 'Browse verified doctors by specialty, read reviews, and pick the one who fits your needs.',
      gradient: [Color(0xFFE6F4F1), Color(0xFFFFFFFF)],
    ),
    _OnboardingPageData(
      icon: Icons.location_on,
      title: 'Care near you',
      subtitle: 'Discover top-rated doctors around you and get directions, ratings, and availability in seconds.',
      gradient: [Color(0xFFEDE9FE), Color(0xFFFFFFFF)],
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
      _goLogin();
    }
  }

  void _goLogin() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 8,
              right: 8,
              child: TextButton(
                onPressed: _goLogin,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                child: Text(
                  'Skip',
                  style: GoogleFonts.plusJakartaSans(
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
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A6EBD),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        textStyle: GoogleFonts.plusJakartaSans(
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: page.gradient,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0A6EBD).withValues(alpha: 0.10),
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
              child: Icon(page.icon, size: 80, color: const Color(0xFF0A6EBD)),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.grey[500],
              height: 1.5,
            ),
          ),
        ],
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
            color: isActive ? const Color(0xFF0A6EBD) : Colors.grey[300],
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
