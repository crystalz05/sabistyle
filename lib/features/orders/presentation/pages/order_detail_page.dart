import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/order.dart';
import '../bloc/order_bloc.dart';
import '../pages/orders_page.dart' show StatusBadge;
import '../../../../features/widgets/app_snackbar.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(FetchOrderDetail(widget.orderId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderCancelled) {
            AppSnackBar.showSuccess(context, message: 'Order cancelled successfully.');
          } else if (state is OrderError) {
            AppSnackBar.showError(context, message: state.message);
          }
        },
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is OrderDetailLoaded) {
            return _buildDetail(context, state.order);
          }
          if (state is OrderError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text('Failed to load order', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.read<OrderBloc>().add(FetchOrderDetail(widget.orderId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDetail(BuildContext context, Order order) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Order Header ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id.substring(0, 8).toUpperCase()}',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(order.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: order.status),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Status Timeline ───────────────────────────────────────────────
          Text('Order Status', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _StatusTimeline(status: order.status),

          const SizedBox(height: 28),

          // ── Items ─────────────────────────────────────────────────────────
          Text('Items Ordered', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...order.items.map((item) => _OrderItemRow(item: item)),

          const Divider(height: 32),

          // ── Price Breakdown ───────────────────────────────────────────────
          _PriceRow(label: 'Subtotal', value: '₦${(order.totalAmount + order.discountAmount).toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          if (order.discountAmount > 0) ...[
            _PriceRow(
              label: 'Discount',
              value: '- ₦${order.discountAmount.toStringAsFixed(0)}',
              valueColor: colorScheme.primary,
            ),
            const SizedBox(height: 8),
          ],
          _PriceRow(
            label: 'Total',
            value: '₦${order.totalAmount.toStringAsFixed(0)}',
            isBold: true,
          ),

          const SizedBox(height: 8),
          Text(
            'Ref: ${order.paystackRef}',
            style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),

          // ── Cancel Button ──────────────────────────────────────────────────
          if (order.canBeCancelled) ...[
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmCancel(context, order.id),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel Order'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(color: colorScheme.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context, String orderId) {
    final colorScheme = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: colorScheme.error),
            const SizedBox(width: 12),
            Text('Cancel Order?', style: TextStyle(color: colorScheme.error),),
          ],
        ),
        content: const Text(
          'Are you sure you want to cancel this order?',
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: Text(
              'No, Keep It',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ctx.pop();
              context.read<OrderBloc>().add(CancelOrder(orderId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// ── Status Timeline Widget ──────────────────────────────────────────────────────

class _StatusTimeline extends StatelessWidget {
  final String status;
  const _StatusTimeline({required this.status});

  static const _steps = ['pending', 'processing', 'shipped', 'delivered'];
  static const _labels = ['Order Placed', 'Processing', 'Shipped', 'Delivered'];
  static const _icons = [
    Icons.check_circle_outline_rounded,
    Icons.autorenew_rounded,
    Icons.local_shipping_outlined,
    Icons.home_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    if (status == 'cancelled') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.error.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.cancel_rounded, color: colorScheme.error, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'This order has been cancelled.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final currentIndex = _steps.indexOf(status);

    return Column(
      children: List.generate(_steps.length, (index) {
        final isDone = index <= currentIndex;
        final isActive = index == currentIndex;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                    border: isActive
                        ? Border.all(color: colorScheme.primary, width: 3)
                        : null,
                  ),
                  child: Icon(
                    _icons[index],
                    size: 18,
                    color: isDone ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                  ),
                ),
                if (index < _steps.length - 1)
                  Container(
                    width: 2,
                    height: 32,
                    color: index < currentIndex
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _labels[index],
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isDone ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ── Item Row ───────────────────────────────────────────────────────────────────

class _OrderItemRow extends StatelessWidget {
  final OrderProductItem item;
  const _OrderItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: colorScheme.surfaceContainerHighest,
            ),
            clipBehavior: Clip.antiAlias,
            child: item.imageUrl != null
                ? CachedNetworkImage(imageUrl: item.imageUrl!, fit: BoxFit.cover)
                : Icon(Icons.image_not_supported_rounded, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.size} · ${item.color} · x${item.quantity}',
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Text(
            '₦${item.subtotal.toStringAsFixed(0)}',
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ── Price Row ──────────────────────────────────────────────────────────────────

class _PriceRow extends StatelessWidget {
  final String label, value;
  final bool isBold;
  final Color? valueColor;

  const _PriceRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final style = isBold
        ? Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyMedium;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style?.copyWith(color: valueColor)),
      ],
    );
  }
}
