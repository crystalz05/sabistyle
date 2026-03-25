
import '../entities/product.dart';

abstract class ProductRepository {
  /// Fetches products belonging to a specific category
  Future<List<Product>> getProductsByCategory(String categoryId);

  /// Fetches a single product by its ID
  Future<Product> getProductById(String productId);

  /// Searches for products by name or description
  Future<List<Product>> searchProducts(String query);
}
