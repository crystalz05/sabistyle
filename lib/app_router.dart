import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';

import 'core/router/router_refresh_listenable.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/onboarding_page.dart';
import 'features/auth/presentation/pages/reset_password_page.dart';
import 'features/auth/presentation/pages/signup_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/pages/verify_email_page.dart';
import 'features/home/presentation/pages/home_page.dart';

// ─────────────────────────────────────────────────────────────
// Route name constants — use these for named navigation so
// path strings are never duplicated across the codebase.
// ─────────────────────────────────────────────────────────────
abstract final class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const signup = '/signup';
  static const login = '/login';
  static const verifyEmail = '/verify-email';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const home = '/home';
}

/// Creates a [GoRouter] instance wired to [AuthBloc].
///
/// The router's `redirect` is the single source of truth for
/// navigation guards. Pages never call `context.go()` based on
/// auth state — the router takes care of it automatically whenever
/// [AuthBloc] emits a new state.
GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,

    // Re-run redirect every time AuthBloc emits a new state.
    refreshListenable: RouterRefreshListenable(authBloc.stream),

    redirect: (BuildContext context, GoRouterState state) {
      final authState = authBloc.state;
      final location = state.matchedLocation;
      final hasSeenOnboarding = GetIt.I<SharedPreferences>().getBool('has_seen_onboarding') ?? false;

      final isAuthenticated = authState is Authenticated;
      final isOnSplash = location == AppRoutes.splash;
      final isOnLogin = location == AppRoutes.login;
      final isOnSignup = location == AppRoutes.signup;
      final isOnOnboarding = location == AppRoutes.onboarding;
      final isOnForgotPassword = location == AppRoutes.forgotPassword;
      final isOnResetPassword = location == AppRoutes.resetPassword;

      final fromLocation = state.uri.queryParameters['from'];

      // Still initializing — stay on splash, regardless of target.
      // Save the intended location as a query parameter so we don't lose deep links!
      if (authState is AuthInitial) {
        if (!isOnSplash) {
          final target = Uri.encodeComponent(state.uri.toString());
          return '${AppRoutes.splash}?from=$target';
        }
        return null;
      }

      // If loading or awaiting verification, do not forcibly redirect.
      if (authState is AuthLoading || authState is AwaitingVerification) {
        return null;
      }

      // We just finished initializing (Authenticated or Unauthenticated) and we
      // are on the Splash screen with a saved deep-link target. Restore it!
      if (isOnSplash && fromLocation != null && authState is! PasswordResetReady) {
        return Uri.decodeComponent(fromLocation);
      }

      // If the app caught a deep link or recovery event, go straight to the reset page
      // and do not process other authenticated/unauthenticated rules.
      if (authState is PasswordResetReady) {
        return isOnResetPassword ? null : AppRoutes.resetPassword;
      }

      // Authenticated user trying to access auth screens → send home.
      // (We don't block access to /reset-password because they need it to update their passed after deep linking)
      if (isAuthenticated && (isOnSplash || isOnLogin || isOnSignup || isOnOnboarding || isOnForgotPassword)) {
        return AppRoutes.home;
      }

      // Navigation guards for Unauthenticated users:
      
      // 1. Leaving Splash -> route based on whether they've seen onboarding
      if (!isAuthenticated && isOnSplash) {
        return hasSeenOnboarding ? AppRoutes.login : AppRoutes.onboarding;
      }

      // 2. Unauthenticated user trying to access login/signup, but hasn't seen onboarding
      if (!isAuthenticated && (isOnLogin || isOnSignup) && !hasSeenOnboarding) {
        return AppRoutes.onboarding;
      }

      // 3. Unauthenticated user trying to access onboarding, but already saw it
      if (!isAuthenticated && isOnOnboarding && hasSeenOnboarding) {
        return AppRoutes.login;
      }

      // 4. Unauthenticated user trying to access a protected route
      if (!isAuthenticated && !isOnSplash && !isOnLogin && !isOnSignup && !isOnOnboarding && !isOnForgotPassword && !isOnResetPassword) {
        return AppRoutes.login;
      }

      // No redirect needed.
      return null;
    },

    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.verifyEmail,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return VerifyEmailPage(email: email);
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => const ResetPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
    ],

    // Fallback for unrecognised routes.
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}
