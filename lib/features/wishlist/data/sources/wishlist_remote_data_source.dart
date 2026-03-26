import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wishlist_item_model.dart';

abstract class WishlistRemoteDataSource {
  Future<List<WishlistItemModel>> fetchWishlist();
  Future<void> addToWishlist(String productId);
  Future<void> removeFromWishlist(String wishlistId);
  Future<Set<String>> getWishlistedProductIds();
}

class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  final SupabaseClient _client;

  WishlistRemoteDataSourceImpl({required SupabaseClient client})
    : _client = client;

  @override
  Future<List<WishlistItemModel>> fetchWishlist() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('wishlists')
        .select('*, products!inner(*)')
        .eq('user_id', userId)
        .eq('products.is_active', true)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => WishlistItemModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addToWishlist(String productId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('wishlists').insert({
      'user_id': userId,
      'product_id': productId,
    });
  }

  @override
  Future<void> removeFromWishlist(String wishlistId) async {
    await _client.from('wishlists').delete().eq('id', wishlistId);
  }

  @override
  Future<Set<String>> getWishlistedProductIds() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return {};

    final response = await _client
        .from('wishlists')
        .select('product_id')
        .eq('user_id', userId);

    return (response as List).map((row) => row['product_id'] as String).toSet();
  }
}
