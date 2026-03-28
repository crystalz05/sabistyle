import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../features/widgets/app_error_widget.dart';
import '../../../../features/widgets/app_empty_state.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              final hasUnread =
                  state is NotificationsLoaded && state.unreadCount > 0;
              if (!hasUnread) return const SizedBox.shrink();

              return TextButton(
                onPressed: () =>
                    context.read<NotificationBloc>().add(MarkAllAsRead()),
                child: const Text('Mark all read'),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading || state is NotificationInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<NotificationBloc>().add(SubscribeToNotifications()),
            );
          }

          if (state is NotificationsLoaded) {
            final notifications = state.notifications;

            if (notifications.isEmpty) {
              return const AppEmptyState(
                icon: Icons.notifications_off_outlined,
                title: 'No notifications',
                message: 'You have no notifications yet.',
              );
            }

            return ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final isUnread = !notification.isRead;

                IconData icon;
                Color iconColor;

                switch (notification.type) {
                  case 'order_update':
                    icon = Icons.local_shipping_outlined;
                    iconColor = theme.colorScheme.primary;
                    break;
                  case 'promo':
                    icon = Icons.local_offer_outlined;
                    iconColor = Colors.orange;
                    break;
                  case 'restock':
                    icon = Icons.inventory_2_outlined;
                    iconColor = Colors.green;
                    break;
                  default:
                    icon = Icons.notifications_outlined;
                    iconColor = theme.colorScheme.secondary;
                }

                return Material(
                  color: isUnread
                      ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                      : Colors.transparent,
                  child: InkWell(
                    onTap: isUnread
                        ? () {
                            context
                                .read<NotificationBloc>()
                                .add(MarkAsRead(notification.id));
                          }
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUnread
                                  ? theme.colorScheme.surface
                                  : theme.colorScheme.surfaceContainerHighest,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: iconColor, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notification.title,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: isUnread
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (isUnread)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        margin:
                                            const EdgeInsets.only(left: 8),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  notification.body,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isUnread
                                        ? theme.colorScheme.onSurface
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  timeago.format(notification.createdAt),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
