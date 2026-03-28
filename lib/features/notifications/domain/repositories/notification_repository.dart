import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Stream<List<NotificationEntity>> streamNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}
