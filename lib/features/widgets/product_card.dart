import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../home/domain/entities/product.dart';
import '../wishlist/presentation/bloc/wishlist_bloc.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  /// Called when the user taps the heart icon.
  final VoidCallback? onFavoriteTap;
  /// When provided, a compact "Add to Cart" button is shown at the bottom.
  final VoidCallback? onAddToCart;
  final double? width;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onFavoriteTap,
    this.onAddToCart,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ─────────────────────────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: product.images.isNotEmpty
                        ? Image.network(
                            product.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, err, stack) =>
                                _ImagePlaceholder(
                              colorScheme: colorScheme,
                            ),
                          )
                        : _ImagePlaceholder(colorScheme: colorScheme),
                  ),
                ),
                // Favorite button
                if (onFavoriteTap != null)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: _FavoriteButton(
                      productId: product.id,
                      onTap: onFavoriteTap!,
                    ),
                  ),
              ],
            ),

            // ── Details ───────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₦${product.price.toStringAsFixed(0)}',
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    // Optional Add to Cart button
                    if (onAddToCart != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: SizedBox(
                          width: double.infinity,
                          height: 30,
                          child: ElevatedButton(
                            onPressed: onAddToCart,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              elevation: 0,
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_shopping_cart_rounded,
                                  size: 12,
                                  color: colorScheme.onPrimary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Add to Cart',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Heart button that reads wishlist state to show filled/unfilled icon.
class _FavoriteButton extends StatelessWidget {
  final String productId;
  final VoidCallback onTap;

  const _FavoriteButton({required this.productId, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<WishlistBloc, WishlistState>(
      buildWhen: (prev, curr) =>
          curr is WishlistLoaded || curr is WishlistIdsLoaded,
      builder: (context, state) {
        Set<String> ids = {};
        if (state is WishlistLoaded) ids = state.wishlistedProductIds;
        if (state is WishlistIdsLoaded) ids = state.wishlistedProductIds;

        final isFav = ids.contains(productId);

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: 16,
              color: isFav ? colorScheme.error : colorScheme.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ImagePlaceholder extends StatelessWidget {
  final ColorScheme colorScheme;
  const _ImagePlaceholder({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
