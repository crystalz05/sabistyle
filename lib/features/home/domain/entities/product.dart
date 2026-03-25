import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String? categoryId;
  final List<String> images;
  final List<String> sizes;
  final List<String> colors;
  final int stockQty;
  final double avgRating;
  final int reviewCount;
  final bool isFeatured;
  final bool isActive;
  final DateTime? createdAt;

  const Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.categoryId,
    required this.images,
    required this.sizes,
    required this.colors,
    required this.stockQty,
    this.avgRating = 0.0,
    this.reviewCount = 0,
    required this.isFeatured,
    required this.isActive,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        categoryId,
        images,
        sizes,
        colors,
        stockQty,
        avgRating,
        reviewCount,
        isFeatured,
        isActive,
        createdAt,
      ];
}
