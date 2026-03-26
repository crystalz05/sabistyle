import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_item_model.dart';
import '../models/promo_code_model.dart';

abstract class CartRemoteDataSource {
  Future<List<CartItemModel>> fetchCart();
  Future<void> addItem({
    required String productId,
    required int quantity,
    required String size,
    required String color,
  });
  Future<void> updateQuantity(String cartItemId, int quantity);
  Future<void> removeItem(String cartItemId);
  Future<void> clearCart();
  Future<PromoCodeModel?> validatePromoCode(String code);
  Future<int> getCartCount();
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final SupabaseClient _client;

  CartRemoteDataSourceImpl({required SupabaseClient client}) : _client = client;

  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<List<CartItemModel>> fetchCart() async {
    final response = await _client
        .from('cart_items')
        .select('*, products(*)')
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => CartItemModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addItem({
    required String productId,
    required int quantity,
    required String size,
    required String color,
  }) async {
    // Upsert respects the unique(user_id, product_id, size, color) constraint.
    // If the row already exists, increment quantity instead of duplicating.
    final existing = await _client
        .from('cart_items')
        .select('id, quantity')
        .eq('user_id', _userId)
        .eq('product_id', productId)
        .eq('size', size)
        .eq('color', color)
        .maybeSingle();

    if (existing != null) {
      final newQty = (existing['quantity'] as int) + quantity;
      await _client
          .from('cart_items')
          .update({'quantity': newQty})
          .eq('id', existing['id'] as String);
    } else {
      await _client.from('cart_items').insert({
        'user_id': _userId,
        'product_id': productId,
        'quantity': quantity,
        'size': size,
        'color': color,
      });
    }
  }

  @override
  Future<void> updateQuantity(String cartItemId, int quantity) async {
    await _client
        .from('cart_items')
        .update({'quantity': quantity})
        .eq('id', cartItemId);
  }

  @override
  Future<void> removeItem(String cartItemId) async {
    await _client.from('cart_items').delete().eq('id', cartItemId);
  }

  @override
  Future<void> clearCart() async {
    await _client.from('cart_items').delete().eq('user_id', _userId);
  }

  @override
  Future<PromoCodeModel?> validatePromoCode(String code) async {
    final response = await _client
        .from('promo_codes')
        .select()
        .eq('code', code.toUpperCase())
        .maybeSingle();

    if (response == null) return null;

    // Check expiry
    final expiresAt = response['expires_at'];
    if (expiresAt != null) {
      final expiry = DateTime.parse(expiresAt as String);
      if (expiry.isBefore(DateTime.now())) return null;
    }

    // Check usage limit
    final maxUses = response['max_uses'] as int?;
    final usedCount = response['used_count'] as int? ?? 0;
    if (maxUses != null && usedCount >= maxUses) return null;

    return PromoCodeModel.fromJson(response);
  }

  @override
  Future<int> getCartCount() async {
    final response = await _client
        .from('cart_items')
        .select('quantity')
        .eq('user_id', _userId);

    return (response as List).fold<int>(
      0,
      (sum, row) => sum + (row['quantity'] as int),
    );
  }
}
