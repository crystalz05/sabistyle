import '../entities/cart_item.dart';
import '../entities/promo_code.dart';

abstract class CartRepository {
  Future<List<CartItem>> fetchCart();
  Future<void> addItem({
    required String productId,
    required int quantity,
    required String size,
    required String color,
  });
  Future<void> updateQuantity(String cartItemId, int quantity);
  Future<void> removeItem(String cartItemId);
  Future<void> clearCart();
  Future<PromoCode?> validatePromoCode(String code);
  Future<int> getCartCount();
}
