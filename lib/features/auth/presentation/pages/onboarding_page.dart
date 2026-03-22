import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';

import '../../../../../app_router.dart';
import '../../../widgets/app_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _finishOnboarding() async {
    final prefs = GetIt.instance<SharedPreferences>();
    await prefs.setBool('has_seen_onboarding', true);
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (idx) => setState(() => _currentPage = idx),
              children: [
                _buildSlide(
                  hook: 'Your Style. Proudly Nigerian.',
                  sub: 'Discover fashion from local designers and vendors — delivered to your door.',
                  icon: Icons.checkroom_rounded,
                ),
                _buildSlide(
                  hook: 'Shop. Pay. Receive. Simple.',
                  sub: 'Browse hundreds of styles, pay securely with Paystack, and track your delivery in real time.',
                  icon: Icons.local_shipping_rounded,
                ),
                _buildSlide(
                  hook: 'Find Your Fit Today',
                  sub: 'New arrivals daily. Free returns on your first order.',
                  icon: Icons.star_rounded,
                  isLast: true,
                ),
              ],
            ),
            Positioned(
              top: 16,
              right: 16,
              child: TextButton(
                onPressed: _finishOnboarding,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6200EE),
                ),
                child: const Text('Skip', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            Positioned(
              bottom: 32,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) => _buildDot(index)),
                  ),
                  const SizedBox(height: 32),
                  if (_currentPage == 2)
                    AppButton(
                      text: 'Get Started',
                      onPressed: _finishOnboarding,
                    )
                  else
                    AppButton(
                      text: 'Next',
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      },
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSlide({required String hook, required String sub, required IconData icon, bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 280,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF6200EE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6200EE).withAlpha(60),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Center(
              child: Icon(icon, size: 100, color: Colors.white),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            hook,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E), height: 1.2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            sub,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 80), // Space for bottom controls
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? const Color(0xFF6200EE) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
