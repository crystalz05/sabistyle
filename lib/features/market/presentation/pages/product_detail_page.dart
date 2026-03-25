import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:sabistyle/features/home/presentation/bloc/product_bloc.dart';
import 'package:sabistyle/features/home/presentation/bloc/review_bloc.dart';
import 'package:sabistyle/features/home/domain/entities/review.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(FetchProductDetail(widget.productId));
    context.read<ReviewBloc>().add(FetchReviews(widget.productId));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFEEF2EC),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductDetailLoaded) {
            final product = state.product;
            return Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    // ── Hero Image Header ──────────────────────────────────
                    SliverAppBar(
                      expandedHeight: size.height * 0.42,
                      automaticallyImplyLeading: false,
                      backgroundColor: const Color(0xFFD9E5D4),
                      elevation: 0,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Subtle radial glow behind product
                            Center(
                              child: Container(
                                width: 220,
                                height: 220,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.45),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(48, 72, 48, 28),
                                child: Hero(
                                  tag: 'product_${product.id}',
                                  child: product.images.isNotEmpty
                                      ? CachedNetworkImage(
                                    imageUrl: product.images.first,
                                    fit: BoxFit.contain,
                                  )
                                      : const Icon(
                                    Icons.image_not_supported,
                                    size: 80,
                                    color: Color(0xFFA0B09A),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Content Card ───────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Transform.translate(
                        offset: const Offset(0, -28),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(36),
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(22, 32, 22, 140),
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
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF111111),
                                            height: 1.2,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          '${product.stockQty} Units Available',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF9E9E9E),
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
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF111111),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  _QuantitySelector(
                                    quantity: _quantity,
                                    onIncrement: () =>
                                        setState(() => _quantity++),
                                    onDecrement: () {
                                      if (_quantity > 1) {
                                        setState(() => _quantity--);
                                      }
                                    },
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // ── Description ────────────────────────────
                              const Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111111),
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
                      ),
                    ),
                  ],
                ),

                // ── Floating Nav Buttons ───────────────────────────────────
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _CircleIconButton(
                          icon: Icons.arrow_back,
                          onTap: () => context.pop(),
                        ),
                        _CircleIconButton(
                          icon: Icons.favorite_border_rounded,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Add to Cart CTA ────────────────────────────────────────
                Positioned(
                  bottom: 24,
                  left: 22,
                  right: 22,
                  child: _AddToCartButton(quantity: _quantity),
                ),
              ],
            );
          } else if (state is ProductError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF111111), size: 20),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;

  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFFFD600), size: 16),
          const SizedBox(width: 5),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
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
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyBtn(
            icon: Icons.remove,
            onTap: onDecrement,
            color: quantity > 1 ? const Color(0xFF111111) : Colors.grey[400]!,
          ),
          const SizedBox(width: 2),
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              quantity.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 2),
          _QtyBtn(
            icon: Icons.add,
            onTap: onIncrement,
            color: const Color(0xFF111111),
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
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: Text(
            widget.text,
            maxLines: _maxLines,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF757575),
              height: 1.6,
            ),
          ),
          secondChild: Text(
            widget.text,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF757575),
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
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primary,
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

  const _AddToCartButton({required this.quantity});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
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
              'Add $quantity to Cart',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
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
    final primary = Theme.of(context).colorScheme.primary;

    return BlocBuilder<ReviewBloc, ReviewState>(
      builder: (context, state) {
        final reviews =
        state is ReviewsLoaded ? state.reviews : <Review>[];
        final isLoading = state is ReviewLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Text(
                      'Reviews',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (reviews.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${reviews.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: primary,
                          ),
                        ),
                      ),
                  ],
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Write a review',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
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
                  style: const TextStyle(color: Colors.red, fontSize: 13),
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
                            color: Colors.grey[300]),
                        const SizedBox(height: 8),
                        Text(
                          'No reviews yet. Be the first!',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
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
                  separatorBuilder: (_, __) => const Divider(
                    height: 24,
                    color: Color(0xFFF0F0F0),
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
                    color: const Color(0xFFF0F0F0),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    (review.userName ?? 'A')[0].toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Color(0xFF555555),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  review.userName ?? 'Anonymous',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF111111),
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
                      ? const Color(0xFFFFD600)
                      : const Color(0xFFE5E5E5),
                );
              }),
            ),
          ],
        ),
        if (review.comment != null) ...[
          const SizedBox(height: 8),
          Text(
            review.comment!,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF757575),
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}