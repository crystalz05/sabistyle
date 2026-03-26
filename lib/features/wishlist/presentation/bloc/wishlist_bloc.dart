import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/wishlist_item.dart';
import '../../domain/repositories/wishlist_repository.dart';

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
  const RemoveFromWishlist(this.wishlistId);
  @override
  List<Object?> get props => [wishlistId];
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
    required this.items,
    required this.wishlistedProductIds,
  });

  @override
  List<Object?> get props => [items, wishlistedProductIds];
}

class WishlistIdsLoaded extends WishlistState {
  final Set<String> wishlistedProductIds;
  const WishlistIdsLoaded(this.wishlistedProductIds);
  @override
  List<Object?> get props => [wishlistedProductIds];
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
    on<LoadWishlistedIds>(_onLoadWishlistedIds);
  }

  Future<void> _onFetchWishlist(
    FetchWishlist event,
    Emitter<WishlistState> emit,
  ) async {
    emit(WishlistLoading());
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
    try {
      await _repository.addToWishlist(event.productId);
      // Refresh the full list so the new item appears.
      add(FetchWishlist());
    } catch (e) {
      emit(WishlistError(e.toString()));
    }
  }

  Future<void> _onRemoveFromWishlist(
    RemoveFromWishlist event,
    Emitter<WishlistState> emit,
  ) async {
    // Optimistic removal — update state immediately, then sync.
    if (state is WishlistLoaded) {
      final current = state as WishlistLoaded;
      final updatedItems = current.items
          .where((i) => i.wishlistId != event.wishlistId)
          .toList();
      final updatedIds = updatedItems.map((e) => e.product.id).toSet();
      emit(
        WishlistLoaded(items: updatedItems, wishlistedProductIds: updatedIds),
      );
    }
    try {
      await _repository.removeFromWishlist(event.wishlistId);
    } catch (e) {
      emit(WishlistError(e.toString()));
    }
  }

  Future<void> _onLoadWishlistedIds(
    LoadWishlistedIds event,
    Emitter<WishlistState> emit,
  ) async {
    try {
      final ids = await _repository.getWishlistedProductIds();
      emit(WishlistIdsLoaded(ids));
    } catch (_) {
      // Silent fail — wishlist ids are a UX nicety, not critical.
    }
  }
}
