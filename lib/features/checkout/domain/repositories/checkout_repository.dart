import '../entities/order_item.dart';

abstract class CheckoutRepository {
  /// Validates a promo code and returns [discountAmount]. Returns 0 if invalid.
  Future<double> validatePromoCode(String code, double orderTotal);

  /// Creates an order in Supabase and returns the new order ID.
  Future<String> placeOrder({
    required String addressId,
    required List<OrderItem> items,
    required double totalAmount,
    required double discountAmount,
    String? promoCodeId,
    required String paystackRef,
  });
}
