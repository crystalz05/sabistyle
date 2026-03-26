import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../cart/data/models/promo_code_model.dart';
import '../../domain/entities/order_item.dart';

abstract class CheckoutRemoteDataSource {
  Future<PromoCodeModel?> validatePromoCode(String code, double orderTotal);
  Future<String> placeOrder({
    required String addressId,
    required List<OrderItem> items,
    required double totalAmount,
    required double discountAmount,
    String? promoCodeId,
    required String paystackRef,
  });
}

class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  final SupabaseClient _client;

  CheckoutRemoteDataSourceImpl({required SupabaseClient client})
    : _client = client;

  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<PromoCodeModel?> validatePromoCode(String code, double orderTotal) async {
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
  Future<String> placeOrder({
    required String addressId,
    required List<OrderItem> items,
    required double totalAmount,
    required double discountAmount,
    String? promoCodeId,
    required String paystackRef,
  }) async {
    // 1. Insert order record
    final orderResponse = await _client
        .from('orders')
        .insert({
          'user_id': _userId,
          'status': 'processing',
          'total_amount': totalAmount,
          'discount_amount': discountAmount,
          'address_id': addressId,
          'promo_code_id': promoCodeId,
          'paystack_ref': paystackRef,
        })
        .select('id')
        .single();

    final orderId = orderResponse['id'] as String;

    // 2. Insert order items
    final orderItems = items
        .map(
          (item) => {
            'order_id': orderId,
            'product_id': item.productId,
            'quantity': item.quantity,
            'size': item.size,
            'color': item.color,
            'unit_price': item.unitPrice,
          },
        )
        .toList();

    await _client.from('order_items').insert(orderItems);

    return orderId;
  }
}
