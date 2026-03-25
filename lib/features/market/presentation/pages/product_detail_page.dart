import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:sabistyle/features/home/presentation/bloc/product_bloc.dart';
import 'package:sabistyle/features/home/presentation/bloc/review_bloc.dart';
import 'package:sabistyle/features/home/domain/entities/review.dart';

import '../../../home/domain/entities/product.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;
  String? _selectedSize;
  String? _selectedColor;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(FetchProductDetail(widget.productId));
    context.read<ReviewBloc>().add(FetchReviews(widget.productId));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Details',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface.withValues(alpha: 0.5),
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.favorite_border_rounded, color: colorScheme.onSurface),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductDetailLoaded) {
            final product = state.product;
            
            // Set defaults if not yet selected but available
            if (_selectedSize == null && product.sizes.isNotEmpty) {
              _selectedSize = product.sizes.first;
            }
            if (_selectedColor == null && product.colors.isNotEmpty) {
              _selectedColor = product.colors.first;
            }

            return Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      // ── Image Header ──────────────────────────────────────
                      Container(
                        width: double.infinity,
                        height: size.height * 0.38,
                        color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                        child: Stack(
                          children: [
                            // Subtle radial glow behind product
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(0),
                                child: Hero(
                                  tag: 'product_${product.id}',
                                  child: product.images.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: product.images.first,
                                          fit: BoxFit.contain,
                                        )
                                      : Icon(
                                          Icons.image_not_supported,
                                          size: 80,
                                          color: colorScheme.onSecondaryContainer.withValues(alpha: 0.4),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Content ───────────────────────────────────────────
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(32),
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(22, 28, 22, 140),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Name + Rating ──────────────────────────
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          height: 1.2,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        '${product.stockQty} Units Available',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _RatingBadge(rating: product.avgRating),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // ── Price + Quantity ───────────────────────
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '₦${product.price.toStringAsFixed(0)}',
                                  style: textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: colorScheme.primary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                _QuantitySelector(
                                  quantity: _quantity,
                                  onIncrement: () {
                                    if (_quantity < product.stockQty){
                                      setState(() => _quantity++);
                                    }
                                  },
                                  onDecrement: () {
                                    if (_quantity > 1) {
                                      setState(() => _quantity--);
                                    }
                                  },
                                ),
                              ],
                            ),
                            // ── Size & Color Selection ──────────────────
                            if (product.sizes.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              Text(
                                'Size/color',
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: product.sizes.map((size) {
                                  final isSelected = _selectedSize == size;
                                  return GestureDetector(
                                    onTap: () => setState(() => _selectedSize = size),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isSelected ? colorScheme.primary : colorScheme.surface,
                                        border: Border.all(
                                          color: isSelected 
                                              ? colorScheme.primary 
                                              : colorScheme.outlineVariant,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        size,
                                        style: textTheme.labelMedium?.copyWith(
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                          color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],

                            if (product.colors.isNotEmpty) ...[
                              Divider(),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: product.colors.map((colorName) {
                                  final isSelected = _selectedColor == colorName;
                                  return GestureDetector(
                                    onTap: () => setState(() => _selectedColor = colorName),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isSelected ? colorScheme.primaryContainer : colorScheme.surface,
                                        border: Border.all(
                                          color: isSelected 
                                              ? colorScheme.primary 
                                              : colorScheme.outlineVariant,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _getColorFromName(colorName),
                                              border: Border.all(color: Colors.black12),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            colorName,
                                            style: textTheme.labelMedium?.copyWith(
                                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                              color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],

                            const SizedBox(height: 24),

                            // ── Description ────────────────────────────
                            Text(
                              'Description',
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _ExpandableDescription(
                              text: product.description ??
                                  'No description available.',
                            ),

                            const SizedBox(height: 28),

                            // ── Reviews ────────────────────────────────
                            const _ReviewSection(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Add to Cart CTA ────────────────────────────────────────
                Positioned(
                  bottom: 24,
                  left: 22,
                  right: 22,
                  child: _AddToCartButton(
                    quantity: _quantity,
                    selectedSize: _selectedSize,
                    selectedColor: _selectedColor,
                    product: product,
                  ),
                ),
              ],
            );
          } else if (state is ProductError) {
            return Center(child: Text(state.message, style: TextStyle(color: colorScheme.error)));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers & Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

Color _getColorFromName(String colorName) {
  final name = colorName.toLowerCase().trim();
  switch (name) {
    case 'red': return Colors.red;
    case 'blue': return Colors.blue;
    case 'green': return Colors.green;
    case 'yellow': return Colors.yellow;
    case 'black': return Colors.black;
    case 'white': return Colors.white;
    case 'grey':
    case 'gray': return Colors.grey;
    case 'brown': return Colors.brown;
    case 'orange': return Colors.orange;
    case 'purple': return Colors.purple;
    case 'pink': return Colors.pink;
    case 'navy': return const Color(0xFF000080);
    case 'gold': return const Color(0xFFFFD700);
    case 'silver': return const Color(0xFFC0C0C0);
    default:
      final hash = name.hashCode;
      return Color((hash & 0xFFFFFF) | 0xFF000000);
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;

  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
          const SizedBox(width: 5),
          Text(
            rating.toStringAsFixed(1),
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.onInverseSurface,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QuantitySelector({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyBtn(
            icon: Icons.remove,
            onTap: onDecrement,
            color: quantity > 1 ? colorScheme.onSurface : colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(width: 2),
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              quantity.toString(),
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 2),
          _QtyBtn(
            icon: Icons.add,
            onTap: onIncrement,
            color: colorScheme.onSurface,
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _QtyBtn({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

class _ExpandableDescription extends StatefulWidget {
  final String text;

  const _ExpandableDescription({required this.text});

  @override
  State<_ExpandableDescription> createState() =>
      _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool _expanded = false;
  static const int _maxLines = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: Text(
            widget.text,
            maxLines: _maxLines,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          secondChild: Text(
            widget.text,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
        if (widget.text.length > 120)
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _expanded ? 'Show less' : 'Read More...',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AddToCartButton extends StatelessWidget {
  final int quantity;
  final String? selectedSize;
  final String? selectedColor;
  final Product product;

  const _AddToCartButton({
    required this.quantity,
    this.selectedSize,
    this.selectedColor,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final bool hasSizes = product.sizes.isNotEmpty;
    final bool hasColors = product.colors.isNotEmpty;

    final bool isValid = (!hasSizes || selectedSize != null) && 
                         (!hasColors || selectedColor != null);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isValid ? () {
          // TODO: Dispatch add to cart event
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added $quantity to cart!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } : () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select required options (Size/Color)'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isValid ? colorScheme.primary : colorScheme.surfaceContainerHighest,
          foregroundColor: isValid ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 20),
            const SizedBox(width: 10),
            Text(
              isValid ? 'Add $quantity to Cart' : 'Select Options',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: isValid ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Review Section
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewSection extends StatelessWidget {
  const _ReviewSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BlocBuilder<ReviewBloc, ReviewState>(
      builder: (context, state) {
        final reviews =
        state is ReviewsLoaded ? state.reviews : <Review>[];
        final isLoading = state is ReviewLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            const Divider(),
            SizedBox(height: 8,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      'Reviews',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (reviews.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${reviews.length}',
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Body ─────────────────────────────────────────────────────
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (state is ReviewError)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  state.message,
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
                ),
              )
            else if (reviews.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.rate_review_outlined,
                            size: 36,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                        const SizedBox(height: 8),
                        Text(
                          'No reviews yet. Be the first!',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviews.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 24,
                    color: colorScheme.surfaceContainerHighest,
                  ),
                  itemBuilder: (_, index) =>
                      _ReviewCard(review: reviews[index]),
                ),
          ],
        );
      },
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // Avatar initials circle
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    (review.userName?.isNotEmpty == true ? review.userName! : 'A')[0].toUpperCase(),
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  review.userName ?? 'Anonymous',
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            // Star row
            Row(
              children: List.generate(5, (i) {
                return Icon(
                  Icons.star_rounded,
                  size: 13,
                  color: i < review.rating
                      ? Colors.amber
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                );
              }),
            ),
          ],
        ),
        if (review.comment != null) ...[
          const SizedBox(height: 8),
          Text(
            review.comment!,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}