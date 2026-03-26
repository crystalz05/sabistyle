import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/product.dart';

class CartItem extends Equatable {
  final String id;
  final String productId;
  final Product product;
  final int quantity;
  final String size;
  final String color;
  final DateTime? createdAt;

  const CartItem({
    required this.id,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.size,
    required this.color,
    this.createdAt,
  });

  double get subtotal => product.price * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      productId: productId,
      product: product,
      quantity: quantity ?? this.quantity,
      size: size,
      color: color,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    productId,
    product,
    quantity,
    size,
    color,
    createdAt,
  ];
}
