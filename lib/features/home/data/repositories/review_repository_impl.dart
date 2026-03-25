import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../sources/review_remote_data_source.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource _remoteDataSource;

  ReviewRepositoryImpl({required ReviewRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<Review>> getProductReviews(String productId) async {
    try {
      return await _remoteDataSource.getProductReviews(productId);
    } catch (e) {
      rethrow;
    }
  }
}
