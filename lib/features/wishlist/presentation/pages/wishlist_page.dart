import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../widgets/app_error_widget.dart';
import '../../../widgets/product_card.dart';
import '../bloc/wishlist_bloc.dart';

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
      appBar: AppBar(title: Text('My Wishlist', style: textTheme.titleMedium)),
      body: BlocBuilder<WishlistBloc, WishlistState>(
        builder: (context, state) {
          if (state is WishlistLoading || state is WishlistInitial) {
            return const Center(child: CircularProgressIndicator());
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
                    onFavoriteTap: () => context
                        .read<WishlistBloc>()
                        .add(RemoveFromWishlist(item.wishlistId)),
                    onAddToCart: () {
                      if (product.sizes.isEmpty && product.colors.isEmpty) {
                        context.read<CartBloc>().add(
                              AddToCart(
                                productId: product.id,
                                quantity: 1,
                                size: '',
                                color: '',
                              ),
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added ${product.name} to cart!'),
                            behavior: SnackBarBehavior.floating,
                            action: SnackBarAction(
                              label: 'VIEW CART',
                              onPressed: () => context.push('/home/cart'),
                            ),
                          ),
                        );
                      } else {
                        context.push('/home/market/product/${product.id}');
                      }
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_outline_rounded,
                size: 52,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your wishlist is empty',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Items you love will appear here.\nStart exploring!',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () => context.go('/home/market'),
              child: const Text('Browse Products'),
            ),
          ],
        ),
      ),
    );
  }
}
