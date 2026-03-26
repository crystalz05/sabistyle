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
import 'features/home/presentation/bloc/review_bloc.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/home/presentation/widgets/main_navigation_shell.dart';
import 'features/market/presentation/pages/market_page.dart';
import 'features/market/presentation/pages/product_listing_page.dart';
import 'features/market/presentation/pages/product_detail_page.dart';
import 'features/market/presentation/pages/search_page.dart';
import 'features/home/presentation/bloc/product_bloc.dart';
import 'features/home/presentation/bloc/search_bloc.dart';
import 'features/orders/presentation/pages/orders_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/wishlist/presentation/pages/wishlist_page.dart';
import 'features/cart/presentation/pages/cart_page.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/checkout/presentation/pages/address_page.dart';
import 'features/checkout/presentation/pages/checkout_page.dart';
import 'features/checkout/presentation/pages/payment_page.dart';
import 'features/checkout/presentation/pages/order_confirmation_page.dart';
import 'features/checkout/presentation/bloc/address_bloc.dart';
import 'features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/checkout/domain/entities/order_item.dart';
import 'features/cart/domain/entities/cart_item.dart';

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
  static const market = '/home/market';
  static const productListing = '/home/market/:categoryId';
  static const productDetail = '/home/market/product/:productId';
  static const search = '/home/market/search';
  static const homeSearch = '/home/search';
  static const wishlist = '/home/wishlist';
  static const cart = '/home/cart';
  static const checkout = '/home/cart/checkout';
  static const payment = '/home/cart/checkout/payment';
  static const orderConfirmation = '/home/cart/checkout/confirmation';
  static const orders = '/home/orders';
  static const profile = '/home/profile';
  static const addresses = '/home/profile/addresses';
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
      final hasSeenOnboarding =
          GetIt.I<SharedPreferences>().getBool('has_seen_onboarding') ?? false;

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
      if (isOnSplash &&
          fromLocation != null &&
          authState is! PasswordResetReady) {
        return Uri.decodeComponent(fromLocation);
      }

      // If the app caught a deep link or recovery event, go straight to the reset page
      // and do not process other authenticated/unauthenticated rules.
      if (authState is PasswordResetReady) {
        return isOnResetPassword ? null : AppRoutes.resetPassword;
      }

      // Authenticated user trying to access auth screens → send home.
      // (We don't block access to /reset-password because they need it to update their passed after deep linking)
      if (isAuthenticated &&
          (isOnSplash ||
              isOnLogin ||
              isOnSignup ||
              isOnOnboarding ||
              isOnForgotPassword)) {
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
      if (!isAuthenticated &&
          !isOnSplash &&
          !isOnLogin &&
          !isOnSignup &&
          !isOnOnboarding &&
          !isOnForgotPassword &&
          !isOnResetPassword) {
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
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationShell(navigationShell: navigationShell);
        },
        branches: [
           StatefulShellBranch(
             routes: [
               GoRoute(
                 path: AppRoutes.home,
                 builder: (context, state) => const HomePage(),
                 routes: [
                   GoRoute(
                     path: 'search',
                     builder: (context, state) => BlocProvider(
                       create: (_) => GetIt.I<SearchBloc>(),
                       child: const SearchPage(),
                     ),
                   ),
                 ],
               ),
             ],
           ),
           StatefulShellBranch(
             routes: [
                GoRoute(
                  path: AppRoutes.market,
                  builder: (context, state) => BlocProvider(
                    create: (context) => GetIt.I<ProductBloc>(),
                    child: const MarketPage(),
                  ),
                  routes: [
                    GoRoute(
                      path: 'search',
                      builder: (context, state) => BlocProvider(
                        create: (_) => GetIt.I<SearchBloc>(),
                        child: const SearchPage(),
                      ),
                    ),
                    GoRoute(
                      path: ':categoryId',
                      builder: (context, state) {
                        final categoryId = state.pathParameters['categoryId']!;
                        final categoryName =
                            state.uri.queryParameters['name'] ?? 'Products';
                        return BlocProvider(
                          create: (_) => GetIt.I<ProductBloc>(),
                          child: ProductListingPage(
                            categoryId: categoryId,
                            categoryName: categoryName,
                          ),
                        );
                      },
                    ),
                  ],
                ),
             ],
           ),
           StatefulShellBranch(
             routes: [
               GoRoute(
                 path: AppRoutes.wishlist,
                 builder: (context, state) => const WishlistPage(),
               ),
             ],
           ),
           StatefulShellBranch(
             routes: [
               GoRoute(
                 path: AppRoutes.orders,
                 builder: (context, state) => const OrdersPage(),
               ),
             ],
           ),
           StatefulShellBranch(
             routes: [
               GoRoute(
                 path: AppRoutes.profile,
                 builder: (context, state) => const ProfilePage(),
               ),
             ],
           ),
         ],
       ),
       GoRoute(
         path: AppRoutes.addresses,
         builder: (context, state) {
           final isSelecting = state.uri.queryParameters['selecting'] == 'true';
           return BlocProvider.value(
             value: GetIt.I<AddressBloc>(),
             child: AddressPage(isSelecting: isSelecting),
           );
         },
       ),
       GoRoute(
         path: AppRoutes.cart,
         builder: (context, state) => const CartPage(),
         routes: [
           ShellRoute(
             builder: (context, state, child) {
               return MultiBlocProvider(
                 providers: [
                   BlocProvider.value(value: GetIt.I<CartBloc>()),
                   BlocProvider(
                     create: (_) => GetIt.I<AddressBloc>(),
                   ),
                   BlocProvider(
                     create: (_) => GetIt.I<CheckoutBloc>(),
                   ),
                 ],
                 child: child,
               );
             },
             routes: [
               GoRoute(
                 path: 'checkout',
                 builder: (context, state) {
                   final extra = state.extra as Map<String, dynamic>;
                   return CheckoutPage(
                     cartItems: extra['cartItems'] as List<CartItem>,
                     subtotal: extra['total'] as double,
                     initialPromoCode: extra['promoCode'] as String?,
                   );
                 },
                 routes: [
                   GoRoute(
                     path: 'payment',
                     builder: (context, state) {
                       final extra = state.extra as Map<String, dynamic>;
                       return PaymentPage(
                         addressId: extra['addressId'] as String,
                         items: extra['items'] as List<OrderItem>,
                         totalAmount: extra['totalAmount'] as double,
                         discountAmount: extra['discountAmount'] as double,
                         promoCodeId: extra['promoCodeId'] as String?,
                       );
                     },
                   ),
                   GoRoute(
                     path: 'confirmation',
                     builder: (context, state) {
                       final orderId = state.extra as String;
                       return OrderConfirmationPage(orderId: orderId);
                     },
                   ),
                 ],
               ),
             ],
           ),
         ],
       ),
       GoRoute(
         path: AppRoutes.productDetail,
         builder: (context, state) {
           final productId = state.pathParameters['productId']!;
           return MultiBlocProvider(
             providers: [
               BlocProvider(
                 create: (_) => GetIt.I<ProductBloc>(),
               ),
               BlocProvider(
                 create: (_) => GetIt.I<ReviewBloc>(),
               ),
             ],
             child: ProductDetailPage(productId: productId),
           );
         },
       ),
    ],

    // Fallback for unrecognised routes.
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
  );
}
