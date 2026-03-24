import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    super.description,
    required super.price,
    super.categoryId,
    required super.images,
    required super.sizes,
    required super.colors,
    required super.stockQty,
    required super.isFeatured,
    required super.isActive,
    super.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      categoryId: json['category_id'] as String?,
      images: List<String>.from(json['images'] ?? []),
      sizes: List<String>.from(json['sizes'] ?? []),
      colors: List<String>.from(json['colors'] ?? []),
      stockQty: json['stock_qty'] as int? ?? 0,
      isFeatured: json['is_featured'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category_id': categoryId,
      'images': images,
      'sizes': sizes,
      'colors': colors,
      'stock_qty': stockQty,
      'is_featured': isFeatured,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
