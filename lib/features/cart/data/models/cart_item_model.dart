import '../../../home/data/models/product_model.dart';
import '../../domain/entities/cart_item.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required super.id,
    required super.productId,
    required super.product,
    required super.quantity,
    required super.size,
    required super.color,
    super.createdAt,
  });

  /// Parses a row from cart_items joined with products.
  /// Expected JSON shape:
  /// {
  ///   "id": "...", "product_id": "...", "quantity": 1, "size": "M",
  ///   "color": "Black", "created_at": "...",
  ///   "products": { "id": ..., "name": ..., "price": ..., ... }
  /// }
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final productJson = json['products'] as Map<String, dynamic>;
    final product = ProductModel.fromJson(productJson);

    return CartItemModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      product: product,
      quantity: json['quantity'] as int,
      size: json['size'] as String,
      color: json['color'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}
