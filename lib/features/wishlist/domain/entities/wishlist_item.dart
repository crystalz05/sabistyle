import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/product.dart';

class WishlistItem extends Equatable {
  final String wishlistId;
  final Product product;
  final DateTime? createdAt;

  const WishlistItem({
    required this.wishlistId,
    required this.product,
    this.createdAt,
  });

  @override
  List<Object?> get props => [wishlistId, product, createdAt];
}
