import '../../../../core/error/error_mapper.dart';
import '../../../cart/domain/entities/promo_code.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../sources/checkout_remote_data_source.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutRemoteDataSource _remoteDataSource;

  CheckoutRepositoryImpl({required CheckoutRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<PromoCode?> validatePromoCode(String code, double orderTotal) async {
    try {
      return await _remoteDataSource.validatePromoCode(code, orderTotal);
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }

  @override
  Future<String> placeOrder({
    required String addressId,
    required List<OrderItem> items,
    required double totalAmount,
    required double discountAmount,
    String? promoCodeId,
    required String paystackRef,
  }) async {
    try {
      return await _remoteDataSource.placeOrder(
        addressId: addressId,
        items: items,
        totalAmount: totalAmount,
        discountAmount: discountAmount,
        promoCodeId: promoCodeId,
        paystackRef: paystackRef,
      );
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }
}
