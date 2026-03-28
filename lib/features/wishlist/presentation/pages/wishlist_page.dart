import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../widgets/cart_badge_icon.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../widgets/app_error_widget.dart';
import '../../../widgets/product_card.dart';
import '../bloc/wishlist_bloc.dart';
import '../../../../features/widgets/app_snackbar.dart';
import '../../../../features/widgets/app_empty_state.dart';
import '../../../../features/widgets/app_shimmer.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  @override
  void initState() {
    super.initState();
    context.read<WishlistBloc>().add(FetchWishlist());
    context.read<CartBloc>().add(FetchCart());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Wishlist', style: textTheme.titleMedium),
        actions: const [
          CartBadgeIcon(),
          SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<WishlistBloc, WishlistState>(
        builder: (context, state) {
          if (state is WishlistInitial) {
            return _buildSkeleton();
          }

          if (state is WishlistLoading && (state is! WishlistLoaded || (state as WishlistLoaded).items.isEmpty)) {
            return _buildSkeleton();
          }

          if (state is WishlistError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<WishlistBloc>().add(FetchWishlist()),
            );
          }

          if (state is WishlistLoaded) {
            if (state.items.isEmpty) {
              return _buildEmptyState(context, colorScheme, textTheme);
            }

            return RefreshIndicator(
              color: colorScheme.primary,
              onRefresh: () async {
                context.read<WishlistBloc>().add(FetchWishlist());
                await Future.delayed(const Duration(milliseconds: 800));
              },
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.62,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  final product = item.product;
                  return ProductCard(
                    product: product,
                    onTap: () =>
                        context.push('/home/market/product/${product.id}'),
                    onAddToCart: () {
                      final size =
                          product.sizes.isNotEmpty ? product.sizes.first : '';
                      final color =
                          product.colors.isNotEmpty ? product.colors.first : '';

                      context.read<CartBloc>().add(
                            AddToCart(
                              productId: product.id,
                              quantity: 1,
                              size: size,
                              color: color,
                            ),
                          );

                      AppSnackBar.showSuccess(
                        context,
                        message: 'Item added to cart',
                      );
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return AppEmptyState(
      icon: Icons.favorite_outline_rounded,
      title: 'Your wishlist is empty',
      message: 'Items you love will appear here.\nStart exploring!',
      actionButton: ElevatedButton(
        onPressed: () => context.go('/home/market'),
        child: const Text('Browse Products'),
      ),
    );
  }

  Widget _buildSkeleton() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => const AppShimmer(
        width: double.infinity,
        height: double.infinity,
        borderRadius: 16,
      ),
    );
  }
}
