import '../../../cart/domain/entities/promo_code.dart';
import '../entities/order_item.dart';

abstract class CheckoutRepository {
  /// Validates a promo code and returns [PromoCode]. Returns null if invalid.
  Future<PromoCode?> validatePromoCode(String code, double orderTotal);

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
