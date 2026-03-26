import '../../../home/data/models/product_model.dart';
import '../../domain/entities/wishlist_item.dart';

class WishlistItemModel extends WishlistItem {
  const WishlistItemModel({
    required super.wishlistId,
    required super.product,
    super.createdAt,
  });

  /// Parses the joined Supabase response:
  /// SELECT w.id as wishlist_id, w.created_at, p.id, p.name, p.price,
  ///        p.images, p.is_active FROM wishlists w JOIN products p ON ...
  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    final productJson = json['products'] as Map<String, dynamic>;
    final product = ProductModel.fromJson(productJson);

    return WishlistItemModel(
      wishlistId: json['id'] as String,
      product: product,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}
