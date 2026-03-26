import '../../../../core/error/error_mapper.dart';
import '../../domain/entities/wishlist_item.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../sources/wishlist_remote_data_source.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistRemoteDataSource _remoteDataSource;

  WishlistRepositoryImpl({required WishlistRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<List<WishlistItem>> fetchWishlist() async {
    try {
      return await _remoteDataSource.fetchWishlist();
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }

  @override
  Future<void> addToWishlist(String productId) async {
    try {
      await _remoteDataSource.addToWishlist(productId);
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }

  @override
  Future<void> removeFromWishlist(String wishlistId) async {
    try {
      await _remoteDataSource.removeFromWishlist(wishlistId);
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }

  @override
  Future<Set<String>> getWishlistedProductIds() async {
    try {
      return await _remoteDataSource.getWishlistedProductIds();
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }
}
