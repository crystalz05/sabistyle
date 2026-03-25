import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'network_info.dart';

part 'network_event.dart';
part 'network_state.dart';

class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  final NetworkInfo _networkInfo;
  StreamSubscription? _subscription;

  NetworkBloc(this._networkInfo) : super(NetworkInitial()) {
    on<NetworkCheckRequested>(_onCheckRequested);
    on<NetworkStatusChanged>(_onStatusChanged);

    // Start listening immediately
    _subscription = _networkInfo.onConnectivityChanged.listen((hasConnection) {
      add(NetworkStatusChanged(hasConnection));
    });
  }

  Future<void> _onCheckRequested(
    NetworkCheckRequested event,
    Emitter<NetworkState> emit,
  ) async {
    final hasConnection = await _networkInfo.hasConnection;
    emit(hasConnection ? NetworkConnected() : NetworkDisconnected());
  }

  void _onStatusChanged(
    NetworkStatusChanged event,
    Emitter<NetworkState> emit,
  ) {
    debugPrint('[NetworkBloc] Connection status: ${event.hasConnection}');
    emit(event.hasConnection ? NetworkConnected() : NetworkDisconnected());
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
