import '../../../../core/error/error_mapper.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/promo_code.dart';
import '../../domain/repositories/cart_repository.dart';
import '../sources/cart_remote_data_source.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource _remoteDataSource;

  CartRepositoryImpl({required CartRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<List<CartItem>> fetchCart() async {
    try {
      return await _remoteDataSource.fetchCart();
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }

  @override
  Future<void> addItem({
    required String productId,
    required int quantity,
    required String size,
    required String color,
  }) async {
    try {
      await _remoteDataSource.addItem(
        productId: productId,
        quantity: quantity,
        size: size,
        color: color,
      );
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }

  @override
  Future<void> updateQuantity(String cartItemId, int quantity) async {
    try {
      await _remoteDataSource.updateQuantity(cartItemId, quantity);
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }

  @override
  Future<void> removeItem(String cartItemId) async {
    try {
      await _remoteDataSource.removeItem(cartItemId);
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await _remoteDataSource.clearCart();
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }

  @override
  Future<PromoCode?> validatePromoCode(String code) async {
    try {
      return await _remoteDataSource.validatePromoCode(code);
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }

  @override
  Future<int> getCartCount() async {
    try {
      return await _remoteDataSource.getCartCount();
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }
}
