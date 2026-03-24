import '../../../../core/error/error_mapper.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/home_repository.dart';
import '../sources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;

  HomeRepositoryImpl({required HomeRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<Category>> getCategories() async {
    try {
      return await _remoteDataSource.getCategories();
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }

  @override
  Future<List<Product>> getFeaturedProducts() async {
    try {
      return await _remoteDataSource.getFeaturedProducts();
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }

  @override
  Future<List<Product>> getNewArrivals({int limit = 10}) async {
    try {
      return await _remoteDataSource.getNewArrivals(limit: limit);
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }
}
