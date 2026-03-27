import '../../domain/entities/order.dart';

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.status,
    required super.totalAmount,
    required super.discountAmount,
    required super.paystackRef,
    required super.addressId,
    super.promoCodeId,
    required super.createdAt,
    super.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['order_items'] as List<dynamic>? ?? [];
    final items = rawItems.map((item) {
      final product = item['product'] as Map<String, dynamic>? ?? {};
      final images = product['images'] as List<dynamic>? ?? [];
      return OrderProductItem(
        productId: item['product_id'] as String,
        name: product['name'] as String? ?? 'Product',
        imageUrl: images.isNotEmpty ? images.first as String : null,
        size: item['size'] as String? ?? '',
        color: item['color'] as String? ?? '',
        quantity: (item['quantity'] as num).toInt(),
        unitPrice: (item['unit_price'] as num).toDouble(),
      );
    }).toList();

    return OrderModel(
      id: json['id'] as String,
      status: json['status'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      paystackRef: json['paystack_ref'] as String,
      addressId: json['address_id'] as String,
      promoCodeId: json['promo_code_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      items: items,
    );
  }
}
