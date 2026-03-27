import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sabistyle/features/home/presentation/bloc/product_bloc.dart';
import 'package:sabistyle/features/widgets/app_empty_state.dart';
import 'package:sabistyle/features/widgets/app_error_widget.dart';
import 'package:sabistyle/features/widgets/product_card.dart';
import 'package:sabistyle/features/wishlist/presentation/bloc/wishlist_bloc.dart';
import 'package:sabistyle/features/home/domain/repositories/product_repository.dart';
import 'package:sabistyle/features/widgets/filter_sort_bottom_sheet.dart';

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
  double? _minPrice;
  double? _maxPrice;
  SortByPrice _sortBy = SortByPrice.none;

  @override
  void initState() {
    super.initState();
    // Load wishlist IDs so heart icons show the correct filled/unfilled state
    context.read<WishlistBloc>().add(LoadWishlistedIds());
    _fetchProducts();
  }

  void _fetchProducts() {
    final bloc = context.read<ProductBloc>();
    if (widget.categoryId == 'featured') {
      bloc.add(FetchFeaturedProducts(
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        sortByPrice: _sortBy,
      ));
    } else if (widget.categoryId == 'new-arrivals') {
      bloc.add(FetchNewArrivals(
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        sortByPrice: _sortBy,
      ));
    } else {
      bloc.add(FetchProductsByCategory(
        widget.categoryId,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        sortByPrice: _sortBy,
      ));
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterSortBottomSheet(
        initialMinPrice: _minPrice,
        initialMaxPrice: _maxPrice,
        initialSortBy: _sortBy,
        onApply: (min, max, sort) {
          setState(() {
            _minPrice = min;
            _maxPrice = max;
            _sortBy = sort;
          });
          _fetchProducts();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        title: Text(
          widget.categoryName,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showFilterBottomSheet,
            icon: Icon(
              (_minPrice != null || _maxPrice != null || _sortBy != SortByPrice.none)
                  ? Icons.filter_alt_rounded
                  : Icons.filter_alt_outlined,
              color: (_minPrice != null || _maxPrice != null || _sortBy != SortByPrice.none)
                  ? theme.colorScheme.primary
                  : null,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductsLoaded) {
            if (state.products.isEmpty) {
              return AppEmptyState(
                icon: Icons.inventory_2_rounded,
                title: 'No products',
                message: (_minPrice != null || _maxPrice != null)
                    ? 'No products found within this price range.'
                    : 'No products found in this category.',
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
                    context.read<WishlistBloc>().add(ToggleWishlist(product));
                  },
                );
              },
            );
          } else if (state is ProductError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: _fetchProducts,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
