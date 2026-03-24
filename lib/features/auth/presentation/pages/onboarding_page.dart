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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (idx) => setState(() => _currentPage = idx),
              children: [
                _buildSlide(
                  context: context,
                  hook: 'Your Style. Proudly Nigerian.',
                  sub: 'Discover fashion from local designers and vendors — delivered to your door.',
                  icon: Icons.checkroom_rounded,
                ),
                _buildSlide(
                  context: context,
                  hook: 'Shop. Pay. Receive. Simple.',
                  sub: 'Browse hundreds of styles, pay securely with Paystack, and track your delivery in real time.',
                  icon: Icons.local_shipping_rounded,
                ),
                _buildSlide(
                  context: context,
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
                  foregroundColor: theme.colorScheme.primary,
                ),
                child: Text('Skip', style: theme.textTheme.labelLarge),
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
                    children: List.generate(3, (index) => _buildDot(context, index)),
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

  Widget _buildSlide({
    required BuildContext context,
    required String hook, 
    required String sub, 
    required IconData icon, 
    bool isLast = false
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 280,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.secondary, theme.colorScheme.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Center(
              child: Icon(icon, size: 100, color: theme.colorScheme.onPrimary),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            hook,
            style: theme.textTheme.displayLarge?.copyWith(
              height: 1.2,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            sub,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 80), // Space for bottom controls
        ],
      ),
    );
  }

  Widget _buildDot(BuildContext context, int index) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? theme.colorScheme.primary : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
