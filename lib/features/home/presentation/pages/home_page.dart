import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../injection_container.dart';
import 'package:sabistyle/widgets/cart_badge_icon.dart';
import 'package:sabistyle/features/widgets/app_error_widget.dart';
import 'package:sabistyle/features/widgets/app_shimmer.dart';
import 'package:sabistyle/features/widgets/product_card.dart';
import 'package:sabistyle/features/home/domain/entities/product.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../notifications/presentation/bloc/notification_bloc.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../../../../features/notifications/presentation/bloc/notification_event.dart';
import '../../../../features/notifications/presentation/bloc/notification_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeBloc _homeBloc;
  final PageController _bannerController = PageController();

  @override
  void initState() {
    super.initState();
    _homeBloc = sl<HomeBloc>()..add(FetchHomeData());
    context.read<NotificationBloc>().add(SubscribeToNotifications());
  }

  @override
  void dispose() {
    _homeBloc.close();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _homeBloc,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading || state is HomeInitial) {
              return _buildLoadingState(context);
            } else if (state is HomeError) {
              return _buildErrorState(context, state.message);
            } else if (state is HomeLoaded) {
              return _buildLoadedState(context, state);
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      surfaceTintColor: Theme.of(context).colorScheme.surface,
      title: Text(
        'SabiStyle',
        style: theme.textTheme.titleLarge,
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search_rounded, color: theme.colorScheme.onSurface),
          onPressed: () => context.push('/home/search'),
        ),
        BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            final unreadCount = state is NotificationsLoaded ? state.unreadCount : 0;
            return IconButton(
              icon: Badge(
                isLabelVisible: unreadCount > 0,
                label: Text(unreadCount.toString()),
                child: Icon(Icons.notifications_outlined, color: theme.colorScheme.onSurface),
              ),
              onPressed: () => context.push('/home/notifications'),
            );
          },
        ),
        const CartBadgeIcon(),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return AppErrorWidget(
      message: message,
      onRetry: () => context.read<HomeBloc>().add(FetchHomeData()),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Banner Skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppShimmer(width: double.infinity, height: 180, borderRadius: 16),
          ),
          const SizedBox(height: 24),
          // Categories Skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppShimmer.textLine(context, width: 120, height: 20),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 90,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Column(
                    children: [
                      const AppShimmer(width: 60, height: 60, borderRadius: 30),
                      const SizedBox(height: 8),
                      AppShimmer.textLine(context, width: 50, height: 12),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          // Featured Products Skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppShimmer.textLine(context, width: 150, height: 20),
                AppShimmer.textLine(context, width: 60, height: 16),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return const AppShimmer(width: double.infinity, height: double.infinity, borderRadius: 16);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, HomeLoaded state) {
    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      onRefresh: () async {
        context.read<HomeBloc>().add(FetchHomeData());
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildHeroBanner(context),
            const SizedBox(height: 24),
            _buildCategories(context, state),
            const SizedBox(height: 32),
            _buildSectionHeader(context, 'Featured Products', () {
              context.push('/home/market/featured?name=Featured%20Products');
            }),
            const SizedBox(height: 16),
            _buildProductGrid(context, state.featuredProducts),
            const SizedBox(height: 32),
            _buildSectionHeader(context, 'New Arrivals', () {
              context.push('/home/market/new-arrivals?name=New%20Arrivals');
            }),
            const SizedBox(height: 16),
            _buildProductGrid(context, state.newArrivals),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    final banners = [
      'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?q=80&w=800&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?q=80&w=800&auto=format&fit=crop',
    ];

    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _bannerController,
        itemCount: banners.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(banners[index]),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.2),
                  BlendMode.darken,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Super Sale',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Up to 50% Off\nSelected Items',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategories(BuildContext context, HomeLoaded state) {
    if (state.categories.isEmpty) return const SizedBox();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Categories',
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 90,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: state.categories.length,
            itemBuilder: (context, index) {
              final cat = state.categories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Column(
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.zero,
                      child: cat.iconUrl != null && cat.iconUrl!.isNotEmpty
                          ? Image.network(
                              cat.iconUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.category, color: theme.colorScheme.secondary);
                              },
                            )
                          : Icon(Icons.category, color: theme.colorScheme.secondary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat.name,
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onSeeAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text('See all', style: Theme.of(context).textTheme.labelMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, List<Product> products) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text('No products available.',
            style: TextStyle(color: Colors.grey)),
      );
    }

    // Randomize and take 6
    final List<Product> displayProducts = List.from(products)..shuffle();
    final itemsToShow = displayProducts.take(6).toList();

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: itemsToShow.length,
      itemBuilder: (context, index) {
        final product = itemsToShow[index];
        return ProductCard(
          product: product,
          onTap: () => context.push('/home/market/product/${product.id}'),
        );
      },
    );
  }
}
