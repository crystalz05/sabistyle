import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app_router.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../domain/entities/address.dart';
import '../../domain/entities/order_item.dart';
import '../bloc/address_bloc.dart';
import '../bloc/checkout_bloc.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final double subtotal;
  final String? initialPromoCode;
  final double? initialDiscountAmount;

  const CheckoutPage({
    super.key,
    required this.cartItems,
    required this.subtotal,
    this.initialPromoCode,
    this.initialDiscountAmount,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  Address? _selectedAddress;
  double _discountAmount = 0.0;
  String? _appliedPromo;
  String? _promoCodeId;
  final _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Pre-fetch addresses so the user can just select one
    context.read<AddressBloc>().add(FetchAddresses());

    if (widget.initialPromoCode != null &&
        widget.initialPromoCode!.isNotEmpty) {
      _appliedPromo = widget.initialPromoCode;
      _discountAmount = widget.initialDiscountAmount ?? 0.0;
      // We don't have the ID from the cart yet unless we pass it, 
      // so we might still want to re-validate once to get the ID for the order.
      context.read<CheckoutBloc>().add(
            ApplyPromoCode(widget.initialPromoCode!, widget.subtotal),
          );
    }
  }

  double get _total => widget.subtotal - _discountAmount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('Checkout', style: textTheme.titleMedium),
        centerTitle: true,
      ),
      body: BlocListener<CheckoutBloc, CheckoutState>(
        listener: (context, state) {
          if (state is PromoApplied) {
            setState(() {
              _appliedPromo = state.promoCode.code;
              _discountAmount = state.promoCode.calculateDiscount(widget.subtotal);
              _promoCodeId = state.promoCode.id;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Promo code applied! Saved ₦${_discountAmount.toStringAsFixed(0)}',
                ),
              ),
            );
          } else if (state is PromoInvalid) {
            setState(() {
              _appliedPromo = null;
              _discountAmount = 0.0;
              _promoCodeId = null;
            });
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Delivery Address ──────────────────────────────────────────
              Text('Delivery Address', style: textTheme.titleMedium),
              const SizedBox(height: 12),
              _buildAddressSection(context, colorScheme, textTheme),

              const SizedBox(height: 32),

              // ── Order Summary ─────────────────────────────────────────────
              Text('Order Summary', style: textTheme.titleMedium),
              const SizedBox(height: 12),
              ...widget.cartItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                          image: item.product.images.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(
                                    item.product.images.first,
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${item.size} · ${item.color}  x${item.quantity}',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₦${item.subtotal.toStringAsFixed(0)}',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 32),

              // ── Promo Code ───────────────────────────────────────────────
              Text('Promo Code', style: textTheme.titleMedium),
              const SizedBox(height: 12),
              if (_appliedPromo != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.local_offer_outlined,
                          size: 18, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _appliedPromo!,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _appliedPromo = null;
                            _discountAmount = 0.0;
                            _promoCodeId = null;
                            _promoController.clear();
                          });
                        },
                        icon: const Icon(Icons.close, size: 18),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                )
              else
                TextField(
                  controller: _promoController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Enter promo code',
                    suffixIcon: TextButton(
                      onPressed: () {
                        if (_promoController.text.trim().isNotEmpty) {
                          context.read<CheckoutBloc>().add(
                                ApplyPromoCode(
                                  _promoController.text.trim(),
                                  widget.subtotal,
                                ),
                              );
                        }
                      },
                      child: Text('Apply', style: textTheme.labelMedium),
                    ),
                  ),
                ),

              const Divider(height: 32),

              // ── Price Breakdown ───────────────────────────────────────────
              _RowItem(
                label: 'Subtotal',
                value: '₦${widget.subtotal.toStringAsFixed(0)}',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              _RowItem(
                label: 'Delivery Fee',
                value: '₦0',
                style: textTheme.bodyMedium,
              ),
              if (_discountAmount > 0) ...[
                const SizedBox(height: 8),
                _RowItem(
                  label: 'Discount ($_appliedPromo)',
                  value: '- ₦${_discountAmount.toStringAsFixed(0)}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              const Divider(height: 32),
              _RowItem(
                label: 'Total',
                value: '₦${_total.toStringAsFixed(0)}',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),

              const SizedBox(height: 48),

              // ── Continue Button ───────────────────────────────────────────
              ElevatedButton(
                onPressed: _selectedAddress == null
                    ? null
                    : () {
                        // Map cart items to order items
                        final orderItems = widget.cartItems
                            .map(
                              (c) => OrderItem(
                                productId: c.productId,
                                quantity: c.quantity,
                                size: c.size,
                                color: c.color,
                                unitPrice: c.product.price,
                              ),
                            )
                            .toList();

                        context.push(
                          '/home/cart/checkout/payment',
                          extra: {
                            'addressId': _selectedAddress!.id,
                            'items': orderItems,
                            'totalAmount': _total,
                            'discountAmount': _discountAmount,
                            'promoCodeId': _promoCodeId,
                          },
                        );
                      },
                child: const Text('Proceed to Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressSection(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return BlocConsumer<AddressBloc, AddressState>(
      listener: (context, state) {
        if (state is AddressesLoaded &&
            state.addresses.isNotEmpty &&
            _selectedAddress == null) {
          setState(() {
            _selectedAddress = state.addresses.any((a) => a.isDefault)
                ? state.addresses.firstWhere((a) => a.isDefault)
                : state.addresses.first;
          });
        }
      },
      builder: (context, state) {
        if (state is AddressLoading) return const CircularProgressIndicator();

        if (state is AddressesLoaded) {
          if (state.addresses.isEmpty) {
            return _buildAddressBox(
              context,
              colorScheme,
              textTheme,
              title: 'No address added',
              subtitle: 'Tap to add a new address',
              icon: Icons.add_location_alt_outlined,
            );
          }

          if (_selectedAddress != null) {
            return _buildAddressBox(
              context,
              colorScheme,
              textTheme,
              title: _selectedAddress!.fullName,
              subtitle: _selectedAddress!.displayAddress,
              icon: Icons.location_on,
            );
          }
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAddressBox(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () async {
        final selected = await context.push<Address>(
          '${AppRoutes.addresses}?selecting=true',
        );
        if (selected != null) {
          setState(() => _selectedAddress = selected);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? style;

  const _RowItem({required this.label, required this.value, this.style});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}
