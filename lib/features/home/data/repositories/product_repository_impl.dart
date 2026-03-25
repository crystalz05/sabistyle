import '../../../../core/error/error_mapper.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../sources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl({required ProductRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    try {
      return await _remoteDataSource.getProductsByCategory(categoryId);
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }

  @override
  Future<Product> getProductById(String productId) async {
    try {
      return await _remoteDataSource.getProductById(productId);
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    try {
      return await _remoteDataSource.searchProducts(query);
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }
}
