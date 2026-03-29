import 'package:flutter/material.dart';
import 'package:sabistyle/core/constants/app_assets.dart';

/// Pure loading screen shown on cold start while the auth state resolves.
///
/// All routing decisions are made in GoRouter's redirect callback — this
/// page only dispatches [AppStarted] once to kick off the auth check and
/// then renders a branded loading UI.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App icon / logo
              SizedBox(
                width: 120,
                height: 120,
                child: Image.asset(
                  Theme.of(context).brightness == Brightness.dark
                      ? AppAssets.lightThemeIcon
                      : AppAssets.darkThemeIcon,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.black 
                      : null,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'SabiStyle',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fashion for every occasion',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.8),
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 64),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                strokeWidth: 2.5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
