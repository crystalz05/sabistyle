import 'package:equatable/equatable.dart';

class OrderItem extends Equatable {
  final String productId;
  final int quantity;
  final String size;
  final String color;
  final double unitPrice;

  const OrderItem({
    required this.productId,
    required this.quantity,
    required this.size,
    required this.color,
    required this.unitPrice,
  });

  double get subtotal => unitPrice * quantity;

  @override
  List<Object?> get props => [productId, quantity, size, color, unitPrice];
}
