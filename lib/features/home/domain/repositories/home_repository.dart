import '../entities/category.dart';
import '../entities/product.dart';

abstract class HomeRepository {
  /// Fetches all categories ordered by display_order
  Future<List<Category>> getCategories();

  /// Fetches products marked as is_featured
  Future<List<Product>> getFeaturedProducts();

  /// Fetches the newest products (ordered by created_at DESC)
  Future<List<Product>> getNewArrivals({int limit = 10});
}
