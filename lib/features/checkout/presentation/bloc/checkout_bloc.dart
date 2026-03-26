import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/order_item.dart';
import '../../domain/repositories/checkout_repository.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();
  @override
  List<Object?> get props => [];
}

class SetDeliveryAddress extends CheckoutEvent {
  final String addressId;
  const SetDeliveryAddress(this.addressId);
  @override
  List<Object?> get props => [addressId];
}

class ApplyPromoCode extends CheckoutEvent {
  final String code;
  final double orderTotal;
  const ApplyPromoCode(this.code, this.orderTotal);
  @override
  List<Object?> get props => [code, orderTotal];
}

class PlaceOrder extends CheckoutEvent {
  final String addressId;
  final List<OrderItem> items;
  final double totalAmount;
  final double discountAmount;
  final String? promoCodeId;
  final String paystackRef;

  const PlaceOrder({
    required this.addressId,
    required this.items,
    required this.totalAmount,
    required this.discountAmount,
    this.promoCodeId,
    required this.paystackRef,
  });

  @override
  List<Object?> get props => [
    addressId,
    items,
    totalAmount,
    discountAmount,
    promoCodeId,
    paystackRef,
  ];
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class CheckoutState extends Equatable {
  const CheckoutState();
  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoading extends CheckoutState {}

class PromoApplied extends CheckoutState {
  final String code;
  final double discountAmount;
  const PromoApplied(this.code, this.discountAmount);
  @override
  List<Object?> get props => [code, discountAmount];
}

class PromoInvalid extends CheckoutState {
  final String message;
  const PromoInvalid(this.message);
  @override
  List<Object?> get props => [message];
}

class OrderPlacedSuccess extends CheckoutState {
  final String orderId;
  const OrderPlacedSuccess(this.orderId);
  @override
  List<Object?> get props => [orderId];
}

class CheckoutError extends CheckoutState {
  final String message;
  const CheckoutError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Bloc ──────────────────────────────────────────────────────────────────────

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final CheckoutRepository _repository;

  CheckoutBloc({required CheckoutRepository repository})
    : _repository = repository,
      super(CheckoutInitial()) {
    on<ApplyPromoCode>(_onApplyPromoCode);
    on<PlaceOrder>(_onPlaceOrder);
  }

  Future<void> _onApplyPromoCode(
    ApplyPromoCode event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(CheckoutLoading());
    try {
      final discount = await _repository.validatePromoCode(
        event.code,
        event.orderTotal,
      );
      if (discount > 0) {
        emit(PromoApplied(event.code, discount));
      } else {
        emit(const PromoInvalid('Invalid or expired promo code'));
      }
    } catch (e) {
      emit(CheckoutError(e.toString()));
    }
  }

  Future<void> _onPlaceOrder(
    PlaceOrder event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(CheckoutLoading());
    try {
      final orderId = await _repository.placeOrder(
        addressId: event.addressId,
        items: event.items,
        totalAmount: event.totalAmount,
        discountAmount: event.discountAmount,
        promoCodeId: event.promoCodeId,
        paystackRef: event.paystackRef,
      );
      emit(OrderPlacedSuccess(orderId));
    } catch (e) {
      emit(CheckoutError(e.toString()));
    }
  }
}
