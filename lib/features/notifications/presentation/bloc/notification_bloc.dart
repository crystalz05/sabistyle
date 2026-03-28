import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _repository;
  StreamSubscription<List<NotificationEntity>>? _subscription;

  NotificationBloc({required NotificationRepository repository})
      : _repository = repository,
        super(NotificationInitial()) {
    on<SubscribeToNotifications>(_onSubscribe);
    on<MarkAsRead>(_onMarkAsRead);
    on<MarkAllAsRead>(_onMarkAllAsRead);
  }

  Future<void> _onSubscribe(
    SubscribeToNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    await _subscription?.cancel();
    
    await emit.forEach<List<NotificationEntity>>(
      _repository.streamNotifications(),
      onData: (notifications) => NotificationsLoaded(notifications),
      onError: (error, _) => NotificationError(error.toString()),
    );
  }

  Future<void> _onMarkAsRead(
    MarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _repository.markAsRead(event.id);
    } catch (e) {
      // Background operation; we don't necessarily update state directly as
      // the stream subscription will push the updated row anyway.
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _repository.markAllAsRead();
    } catch (e) {
      // Ignored
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
