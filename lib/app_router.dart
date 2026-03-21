import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/router/router_refresh_listenable.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/home/presentation/pages/home_page.dart';

// ─────────────────────────────────────────────────────────────
// Route name constants — use these for named navigation so
// path strings are never duplicated across the codebase.
// ─────────────────────────────────────────────────────────────
abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
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

      // Still loading — stay on splash, regardless of target.
      if (authState is AuthInitial || authState is AuthLoading) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final isAuthenticated = authState is Authenticated;
      final isOnSplash = location == AppRoutes.splash;
      final isOnLogin = location == AppRoutes.login;

      // Authenticated user trying to access splash or login → send home.
      if (isAuthenticated && (isOnSplash || isOnLogin)) {
        return AppRoutes.home;
      }

      // Unauthenticated user trying to access a protected route → login.
      if (!isAuthenticated && !isOnSplash && !isOnLogin) {
        return AppRoutes.login;
      }

      // Unauthenticated and auth state is resolved → leave splash, go login.
      if (!isAuthenticated && isOnSplash) {
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
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
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
