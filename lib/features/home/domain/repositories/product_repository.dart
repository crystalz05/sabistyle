
import '../entities/product.dart';

enum SortByPrice { none, asc, desc }

abstract class ProductRepository {
  /// Fetches products belonging to a specific category
  Future<List<Product>> getProductsByCategory(
    String categoryId, {
    double? minPrice,
    double? maxPrice,
    SortByPrice sortByPrice = SortByPrice.none,
  });

  /// Fetches a single product by its ID
  Future<Product> getProductById(String productId);

  /// Searches for products by name or description
  Future<List<Product>> searchProducts(
    String query, {
    double? minPrice,
    double? maxPrice,
    SortByPrice sortByPrice = SortByPrice.none,
  });

  /// Fetches featured products
  Future<List<Product>> getFeaturedProducts({
    double? minPrice,
    double? maxPrice,
    SortByPrice sortByPrice = SortByPrice.none,
  });

  /// Fetches new arrival products
  Future<List<Product>> getNewArrivals({
    double? minPrice,
    double? maxPrice,
    SortByPrice sortByPrice = SortByPrice.none,
  });

  /// Search history methods
  Future<List<String>> getSearchHistory();
  Future<void> saveSearchQuery(String query);
}
