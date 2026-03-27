import '../../../../core/error/error_mapper.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../sources/product_remote_data_source.dart';
import '../sources/search_history_local_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;
  final SearchHistoryLocalDataSource _historyLocalDataSource;

  ProductRepositoryImpl({
    required ProductRemoteDataSource remoteDataSource,
    required SearchHistoryLocalDataSource historyLocalDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _historyLocalDataSource = historyLocalDataSource;

  @override
  Future<List<Product>> getProductsByCategory(
    String categoryId, {
    double? minPrice,
    double? maxPrice,
    SortByPrice sortByPrice = SortByPrice.none,
  }) async {
    try {
      return await _remoteDataSource.getProductsByCategory(
        categoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortByPrice: sortByPrice,
      );
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
  Future<List<Product>> searchProducts(
    String query, {
    double? minPrice,
    double? maxPrice,
    SortByPrice sortByPrice = SortByPrice.none,
  }) async {
    try {
      return await _remoteDataSource.searchProducts(
        query,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortByPrice: sortByPrice,
      );
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }

  @override
  Future<List<Product>> getFeaturedProducts({
    double? minPrice,
    double? maxPrice,
    SortByPrice sortByPrice = SortByPrice.none,
  }) async {
    try {
      return await _remoteDataSource.getFeaturedProducts(
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortByPrice: sortByPrice,
      );
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }

  @override
  Future<List<Product>> getNewArrivals({
    double? minPrice,
    double? maxPrice,
    SortByPrice sortByPrice = SortByPrice.none,
  }) async {
    try {
      return await _remoteDataSource.getNewArrivals(
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortByPrice: sortByPrice,
      );
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }

  @override
  Future<List<String>> getSearchHistory() async {
    return _historyLocalDataSource.getSearchHistory();
  }

  @override
  Future<void> saveSearchQuery(String query) async {
    await _historyLocalDataSource.saveSearchQuery(query);
  }
}
