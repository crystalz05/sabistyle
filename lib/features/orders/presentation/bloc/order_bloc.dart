import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';

// ── Events ─────────────────────────────────────────────────────────────────────

abstract class OrderEvent extends Equatable {
  const OrderEvent();
  @override
  List<Object?> get props => [];
}

class FetchOrders extends OrderEvent {}

class FetchOrderDetail extends OrderEvent {
  final String orderId;
  const FetchOrderDetail(this.orderId);
  @override
  List<Object?> get props => [orderId];
}

class CancelOrder extends OrderEvent {
  final String orderId;
  const CancelOrder(this.orderId);
  @override
  List<Object?> get props => [orderId];
}

// ── States ─────────────────────────────────────────────────────────────────────

abstract class OrderState extends Equatable {
  const OrderState();
  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrdersLoaded extends OrderState {
  final List<Order> orders;
  const OrdersLoaded(this.orders);
  @override
  List<Object?> get props => [orders];
}

class OrderDetailLoaded extends OrderState {
  final Order order;
  const OrderDetailLoaded(this.order);
  @override
  List<Object?> get props => [order];
}

class OrderCancelled extends OrderState {}

class OrderError extends OrderState {
  final String message;
  const OrderError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Bloc ───────────────────────────────────────────────────────────────────────

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _repository;

  OrderBloc({required OrderRepository repository})
      : _repository = repository,
        super(OrderInitial()) {
    on<FetchOrders>(_onFetchOrders);
    on<FetchOrderDetail>(_onFetchOrderDetail);
    on<CancelOrder>(_onCancelOrder);
  }

  Future<void> _onFetchOrders(
    FetchOrders event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      final orders = await _repository.fetchOrders();
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onFetchOrderDetail(
    FetchOrderDetail event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      final order = await _repository.fetchOrderDetail(event.orderId);
      emit(OrderDetailLoaded(order));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onCancelOrder(
    CancelOrder event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      await _repository.cancelOrder(event.orderId);
      emit(OrderCancelled());
      // Re-fetch detail to update UI
      final order = await _repository.fetchOrderDetail(event.orderId);
      emit(OrderDetailLoaded(order));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }
}
