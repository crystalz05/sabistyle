import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sabistyle/features/home/presentation/bloc/product_bloc.dart';
import 'package:sabistyle/features/widgets/app_empty_state.dart';
import 'package:sabistyle/features/widgets/app_error_widget.dart';
import 'package:sabistyle/features/widgets/product_card.dart';
import 'package:sabistyle/features/wishlist/presentation/bloc/wishlist_bloc.dart';

class ProductListingPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const ProductListingPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<ProductListingPage> createState() => _ProductListingPageState();
}

class _ProductListingPageState extends State<ProductListingPage> {
  @override
  void initState() {
    super.initState();
    // Load wishlist IDs so heart icons show the correct filled/unfilled state
    context.read<WishlistBloc>().add(LoadWishlistedIds());

    if (widget.categoryId == 'featured') {
      context.read<ProductBloc>().add(FetchFeaturedProducts());
    } else if (widget.categoryId == 'new-arrivals') {
      context.read<ProductBloc>().add(FetchNewArrivals());
    } else {
      context.read<ProductBloc>().add(FetchProductsByCategory(widget.categoryId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductsLoaded) {
            if (state.products.isEmpty) {
              return const AppEmptyState(
                icon: Icons.inventory_2_rounded,
                title: 'No products',
                message: 'No products found in this category.',
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: state.products.length,
              itemBuilder: (context, index) {
                final product = state.products[index];
                return ProductCard(
                  product: product,
                  onTap: () =>
                      context.push('/home/market/product/${product.id}'),
                  onFavoriteTap: () {
                    final wishlistState =
                        context.read<WishlistBloc>().state;
                    Set<String> ids = {};
                    if (wishlistState is WishlistLoaded) {
                      ids = wishlistState.wishlistedProductIds;
                    }
                    if (wishlistState is WishlistIdsLoaded) {
                      ids = wishlistState.wishlistedProductIds;
                    }

                    if (ids.contains(product.id)) {
                      if (wishlistState is WishlistLoaded) {
                        final item = wishlistState.items
                            .where((i) => i.product.id == product.id)
                            .firstOrNull;
                        if (item != null) {
                          context
                              .read<WishlistBloc>()
                              .add(RemoveFromWishlist(item.wishlistId));
                          return;
                        }
                      }
                    }
                    context
                        .read<WishlistBloc>()
                        .add(AddToWishlist(product.id));
                  },
                );
              },
            );
          } else if (state is ProductError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () {
                if (widget.categoryId == 'featured') {
                  context.read<ProductBloc>().add(FetchFeaturedProducts());
                } else if (widget.categoryId == 'new-arrivals') {
                  context.read<ProductBloc>().add(FetchNewArrivals());
                } else {
                  context
                      .read<ProductBloc>()
                      .add(FetchProductsByCategory(widget.categoryId));
                }
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
