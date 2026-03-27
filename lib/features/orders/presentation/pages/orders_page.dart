import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../domain/entities/order.dart';
import '../bloc/order_bloc.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(FetchOrders());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is OrderError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text('Failed to load orders', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.read<OrderBloc>().add(FetchOrders()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is OrdersLoaded) {
            if (state.orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 80, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                    const SizedBox(height: 24),
                    Text('No orders yet', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      'Your completed orders will appear here.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('Start Shopping'),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async => context.read<OrderBloc>().add(FetchOrders()),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _OrderCard(order: state.orders[index]),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => context.push('/home/orders/${order.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${order.id.substring(0, 8).toUpperCase()}',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(order.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            if (order.items.isNotEmpty)
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: order.items.length > 4 ? 4 : order.items.length,
                  itemBuilder: (context, index) {
                    final item = order.items[index];
                    return Container(
                      width: 48,
                      height: 48,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: colorScheme.surfaceContainerHighest,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: item.imageUrl != null
                          ? CachedNetworkImage(imageUrl: item.imageUrl!, fit: BoxFit.cover)
                          : Icon(Icons.image_not_supported_rounded, color: colorScheme.onSurfaceVariant, size: 20),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.items.length} item${order.items.length == 1 ? '' : 's'}',
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                Text(
                  '₦${order.totalAmount.toStringAsFixed(0)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bgColor, label) = switch (status) {
      'pending' => (const Color(0xFFB45309), const Color(0xFFFEF3C7), 'Pending'),
      'processing' => (const Color(0xFF1D4ED8), const Color(0xFFDBEAFE), 'Processing'),
      'shipped' => (const Color(0xFF7C3AED), const Color(0xFFEDE9FE), 'Shipped'),
      'delivered' => (const Color(0xFF15803D), const Color(0xFFDCFCE7), 'Delivered'),
      'cancelled' => (const Color(0xFFDC2626), const Color(0xFFFEE2E2), 'Cancelled'),
      _ => (Colors.grey.shade700, Colors.grey.shade100, status),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
