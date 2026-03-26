import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/wishlist_item.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../../../home/domain/entities/product.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class WishlistEvent extends Equatable {
  const WishlistEvent();
  @override
  List<Object?> get props => [];
}

class FetchWishlist extends WishlistEvent {}

class AddToWishlist extends WishlistEvent {
  final String productId;
  const AddToWishlist(this.productId);
  @override
  List<Object?> get props => [productId];
}

class RemoveFromWishlist extends WishlistEvent {
  final String wishlistId;
  final String? productId;
  const RemoveFromWishlist(this.wishlistId, {this.productId});
  @override
  List<Object?> get props => [wishlistId, productId];
}

class ToggleWishlist extends WishlistEvent {
  final Product product;
  const ToggleWishlist(this.product);
  @override
  List<Object?> get props => [product];
}

class LoadWishlistedIds extends WishlistEvent {}

// ── States ────────────────────────────────────────────────────────────────────

abstract class WishlistState extends Equatable {
  const WishlistState();
  @override
  List<Object?> get props => [];
}

class WishlistInitial extends WishlistState {}

class WishlistLoading extends WishlistState {}

class WishlistLoaded extends WishlistState {
  final List<WishlistItem> items;

  /// Product IDs currently in the wishlist — used for quick look-up in cards.
  final Set<String> wishlistedProductIds;

  const WishlistLoaded({
    this.items = const [],
    this.wishlistedProductIds = const {},
  });

  WishlistLoaded copyWith({
    List<WishlistItem>? items,
    Set<String>? wishlistedProductIds,
  }) {
    return WishlistLoaded(
      items: items ?? this.items,
      wishlistedProductIds: wishlistedProductIds ?? this.wishlistedProductIds,
    );
  }

  @override
  List<Object?> get props => [items, wishlistedProductIds];
}

class WishlistError extends WishlistState {
  final String message;
  const WishlistError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Bloc ──────────────────────────────────────────────────────────────────────

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final WishlistRepository _repository;

  WishlistBloc({required WishlistRepository repository})
    : _repository = repository,
      super(WishlistInitial()) {
    on<FetchWishlist>(_onFetchWishlist);
    on<AddToWishlist>(_onAddToWishlist);
    on<RemoveFromWishlist>(_onRemoveFromWishlist);
    on<ToggleWishlist>(_onToggleWishlist);
    on<LoadWishlistedIds>(_onLoadWishlistedIds);
  }

  Future<void> _onFetchWishlist(
    FetchWishlist event,
    Emitter<WishlistState> emit,
  ) async {
    // Only show loading if we have no data yet
    if (state is! WishlistLoaded || (state as WishlistLoaded).items.isEmpty) {
      emit(WishlistLoading());
    }
    try {
      final items = await _repository.fetchWishlist();
      final ids = items.map((e) => e.product.id).toSet();
      emit(WishlistLoaded(items: items, wishlistedProductIds: ids));
    } catch (e) {
      emit(WishlistError(e.toString()));
    }
  }

  Future<void> _onAddToWishlist(
    AddToWishlist event,
    Emitter<WishlistState> emit,
  ) async {
    final previousState = state;
    if (state is WishlistLoaded) {
      final current = state as WishlistLoaded;
      final updatedIds = Set<String>.from(current.wishlistedProductIds)
        ..add(event.productId);
      emit(current.copyWith(wishlistedProductIds: updatedIds));
    } else {
      emit(WishlistLoaded(wishlistedProductIds: {event.productId}));
    }

    try {
      await _repository.addToWishlist(event.productId);
      final items = await _repository.fetchWishlist();
      final ids = items.map((e) => e.product.id).toSet();
      emit(WishlistLoaded(items: items, wishlistedProductIds: ids));
    } catch (e) {
      emit(WishlistError(e.toString()));
      emit(previousState);
    }
  }

  Future<void> _onRemoveFromWishlist(
    RemoveFromWishlist event,
    Emitter<WishlistState> emit,
  ) async {
    final previousState = state;
    if (state is WishlistLoaded) {
      final current = state as WishlistLoaded;
      final updatedItems = current.items.where((i) {
        if (event.productId != null) {
          return i.product.id != event.productId;
        }
        return i.wishlistId != event.wishlistId;
      }).toList();
      final updatedIds = updatedItems.map((e) => e.product.id).toSet();
      if (updatedIds.length == current.wishlistedProductIds.length && event.productId != null) {
         updatedIds.remove(event.productId);
      }
      emit(current.copyWith(items: updatedItems, wishlistedProductIds: updatedIds));
    }

    try {
      if (event.wishlistId.isNotEmpty) {
        await _repository.removeFromWishlist(event.wishlistId);
      } else if (event.productId != null) {
        final items = await _repository.fetchWishlist();
        final item = items.firstWhere((i) => i.product.id == event.productId);
        await _repository.removeFromWishlist(item.wishlistId);
      }
    } catch (e) {
      emit(WishlistError(e.toString()));
      emit(previousState);
    }
  }

  Future<void> _onToggleWishlist(
    ToggleWishlist event,
    Emitter<WishlistState> emit,
  ) async {
    final productId = event.product.id;
    Set<String> currentIds = {};
    if (state is WishlistLoaded) {
      currentIds = (state as WishlistLoaded).wishlistedProductIds;
    }

    if (currentIds.contains(productId)) {
      String? wishlistId;
      if (state is WishlistLoaded) {
        final items = (state as WishlistLoaded).items;
        try {
          wishlistId = items.firstWhere((i) => i.product.id == productId).wishlistId;
        } catch (_) {}
      }
      add(RemoveFromWishlist(wishlistId ?? '', productId: productId));
    } else {
      add(AddToWishlist(productId));
    }
  }

  Future<void> _onLoadWishlistedIds(
    LoadWishlistedIds event,
    Emitter<WishlistState> emit,
  ) async {
    try {
      final ids = await _repository.getWishlistedProductIds();
      if (state is WishlistLoaded) {
        emit((state as WishlistLoaded).copyWith(wishlistedProductIds: ids));
      } else {
        emit(WishlistLoaded(wishlistedProductIds: ids));
      }
    } catch (_) {}
  }
}
