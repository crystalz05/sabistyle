import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object> get props => [];
}

class SubscribeToNotifications extends NotificationEvent {}

class MarkAsRead extends NotificationEvent {
  final String id;

  const MarkAsRead(this.id);

  @override
  List<Object> get props => [id];
}

class MarkAllAsRead extends NotificationEvent {}
