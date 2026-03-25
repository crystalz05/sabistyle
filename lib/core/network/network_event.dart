part of 'network_bloc.dart';

abstract class NetworkEvent {}
class NetworkCheckRequested extends NetworkEvent {}
class NetworkStatusChanged extends NetworkEvent {
  final bool hasConnection;
  NetworkStatusChanged(this.hasConnection);
}
