class OrderProductItem {
  final String productId;
  final String name;
  final String? imageUrl;
  final String size;
  final String color;
  final int quantity;
  final double unitPrice;

  const OrderProductItem({
    required this.productId,
    required this.name,
    this.imageUrl,
    required this.size,
    required this.color,
    required this.quantity,
    required this.unitPrice,
  });

  double get subtotal => unitPrice * quantity;
}

class Order {
  final String id;
  final String status;
  final double totalAmount;
  final double discountAmount;
  final String paystackRef;
  final String addressId;
  final String? promoCodeId;
  final DateTime createdAt;
  final List<OrderProductItem> items;

  const Order({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.discountAmount,
    required this.paystackRef,
    required this.addressId,
    this.promoCodeId,
    required this.createdAt,
    this.items = const [],
  });

  bool get isPending => status == 'pending';
  bool get canBeCancelled => status == 'pending';
}
