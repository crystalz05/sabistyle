import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

class FetchCart extends CartEvent {}

class AddToCart extends CartEvent {
  final String productId;
  final int quantity;
  final String size;
  final String color;

  const AddToCart({
    required this.productId,
    required this.quantity,
    required this.size,
    required this.color,
  });

  @override
  List<Object?> get props => [productId, quantity, size, color];
}

class UpdateCartItemQuantity extends CartEvent {
  final String cartItemId;
  final int quantity;

  const UpdateCartItemQuantity(this.cartItemId, this.quantity);

  @override
  List<Object?> get props => [cartItemId, quantity];
}

class RemoveFromCart extends CartEvent {
  final String cartItemId;
  const RemoveFromCart(this.cartItemId);
  @override
  List<Object?> get props => [cartItemId];
}

class ClearCart extends CartEvent {}

// ── States ────────────────────────────────────────────────────────────────────

abstract class CartState extends Equatable {
  const CartState();
  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItem> items;
  final String? promoCode;
  final double discountAmount;

  const CartLoaded({
    required this.items,
    this.promoCode,
    this.discountAmount = 0,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);

  double get total => subtotal - discountAmount;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  CartLoaded copyWith({
    List<CartItem>? items,
    String? promoCode,
    double? discountAmount,
  }) {
    return CartLoaded(
      items: items ?? this.items,
      promoCode: promoCode ?? this.promoCode,
      discountAmount: discountAmount ?? this.discountAmount,
    );
  }

  @override
  List<Object?> get props => [items, promoCode, discountAmount];
}

class CartError extends CartState {
  final String message;
  const CartError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Bloc ──────────────────────────────────────────────────────────────────────

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _repository;

  CartBloc({required CartRepository repository})
    : _repository = repository,
      super(CartInitial()) {
    on<FetchCart>(_onFetchCart);
    on<AddToCart>(_onAddToCart);
    on<UpdateCartItemQuantity>(_onUpdateQuantity);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<ClearCart>(_onClearCart);
  }

  Future<void> _onFetchCart(FetchCart event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final items = await _repository.fetchCart();
      emit(CartLoaded(items: items));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onAddToCart(AddToCart event, Emitter<CartState> emit) async {
    try {
      await _repository.addItem(
        productId: event.productId,
        quantity: event.quantity,
        size: event.size,
        color: event.color,
      );
      add(FetchCart()); // Refresh to get server-confirmed state
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onUpdateQuantity(
    UpdateCartItemQuantity event,
    Emitter<CartState> emit,
  ) async {
    // Optimistic update
    if (state is CartLoaded) {
      final current = state as CartLoaded;
      final updated = current.items.map((item) {
        return item.id == event.cartItemId
            ? item.copyWith(quantity: event.quantity)
            : item;
      }).toList();
      emit(current.copyWith(items: updated));
    }
    try {
      await _repository.updateQuantity(event.cartItemId, event.quantity);
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onRemoveFromCart(
    RemoveFromCart event,
    Emitter<CartState> emit,
  ) async {
    // Optimistic removal
    if (state is CartLoaded) {
      final current = state as CartLoaded;
      final updated = current.items
          .where((i) => i.id != event.cartItemId)
          .toList();
      emit(current.copyWith(items: updated));
    }
    try {
      await _repository.removeItem(event.cartItemId);
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    try {
      await _repository.clearCart();
      emit(const CartLoaded(items: []));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }
}
