import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../sources/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _dataSource;

  NotificationRepositoryImpl(this._dataSource);

  @override
  Stream<List<NotificationEntity>> streamNotifications() {
    return _dataSource.streamNotifications();
  }

  @override
  Future<void> markAsRead(String id) {
    return _dataSource.markAsRead(id);
  }

  @override
  Future<void> markAllAsRead() {
    return _dataSource.markAllAsRead();
  }
}
