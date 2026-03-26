import 'package:equatable/equatable.dart';

enum DiscountType { percentage, fixed }

class PromoCode extends Equatable {
  final String id;
  final String code;
  final DiscountType discountType;
  final double discountValue;

  const PromoCode({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
  });

  double calculateDiscount(double subtotal) {
    if (discountType == DiscountType.percentage) {
      return subtotal * (discountValue / 100);
    } else {
      return discountValue;
    }
  }

  @override
  List<Object?> get props => [id, code, discountType, discountValue];
}
