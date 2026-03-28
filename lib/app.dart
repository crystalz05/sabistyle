import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'injection_container.dart';
import 'core/network/network_bloc.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/wishlist/presentation/bloc/wishlist_bloc.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';

class MyApp extends StatefulWidget {
  final Uri? initialUri;
  const MyApp({super.key, this.initialUri});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Instantiate AuthBloc once and share it with both the BlocProvider
  // (so the widget tree can access it) and the router (so the redirect
  // guard can read the current state without a BuildContext).
  late final AuthBloc _authBloc;
  late final GoRouter _router;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>();
    _authBloc.add(AppStarted(initialUri: widget.initialUri));
    _router = createRouter(_authBloc);
    _listenForIncomingLinks();
  }

  // Handles warm starts — app was backgrounded when the link was tapped
  void _listenForIncomingLinks() {
    _linkSubscription = AppLinks().uriLinkStream.listen(
      (uri) {
        debugPrint('[MyApp] Incoming deep link (warm): $uri');
        _authBloc.add(DeepLinkReceived(uri));
      },
      onError: (e) {
        debugPrint('[MyApp] Deep link error: $e');
      },
    );
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<NetworkBloc>(
          create: (_) => sl<NetworkBloc>()..add(NetworkCheckRequested()),
        ),
        BlocProvider<WishlistBloc>(
          create: (context) => sl<WishlistBloc>()..add(LoadWishlistedIds()),
        ),
        BlocProvider<CartBloc>(
          create: (context) => sl<CartBloc>()..add(FetchCart()),
        ),
        BlocProvider<NotificationBloc>(
          create: (context) => sl<NotificationBloc>(),
        ),
        BlocProvider<ProfileBloc>(
          create: (context) => sl<ProfileBloc>()..add(FetchProfile()),
        ),
      ],
      child: MaterialApp.router(
        title: 'SabiStyle',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: _router,
      ),
    );
  }
}
