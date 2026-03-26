import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../domain/entities/order_item.dart';
import '../bloc/checkout_bloc.dart';

class PaymentPage extends StatefulWidget {
  final String addressId;
  final List<OrderItem> items;
  final double totalAmount;
  final double discountAmount;
  final String? promoCodeId;

  const PaymentPage({
    super.key,
    required this.addressId,
    required this.items,
    required this.totalAmount,
    required this.discountAmount,
    this.promoCodeId,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isProcessing = false;

  void _simulateMockPayment() async {
    setState(() => _isProcessing = true);

    // Simulate network delay for Paystack UI
    await Future.delayed(const Duration(seconds: 2));

    // Generate a fake Paystack reference
    final ref = 'sq_${DateTime.now().millisecondsSinceEpoch}';

    if (!mounted) return;

    // Dispatch the real order creation event to Supabase
    context.read<CheckoutBloc>().add(
      PlaceOrder(
        addressId: widget.addressId,
        items: widget.items,
        totalAmount: widget.totalAmount,
        discountAmount: widget.discountAmount,
        promoCodeId: widget.promoCodeId,
        paystackRef: ref,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BlocListener<CheckoutBloc, CheckoutState>(
      listener: (context, state) {
        if (state is OrderPlacedSuccess) {
          // 1. Clear the cart
          context.read<CartBloc>().add(ClearCart());

          // 2. Navigate to confirmation page
          context.go('/home/cart/checkout/confirmation', extra: state.orderId);
        } else if (state is CheckoutError) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment failed: ${state.message}'),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Payment')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.credit_card_outlined,
                    size: 64,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Pay ₦${widget.totalAmount.toStringAsFixed(0)}',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Clicking the button below simulates a successful Paystack transaction and creates the order in the database.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _simulateMockPayment,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Simulate Successful Payment'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
