import '../../domain/entities/promo_code.dart';

class PromoCodeModel extends PromoCode {
  const PromoCodeModel({
    required super.id,
    required super.code,
    required super.discountType,
    required super.discountValue,
  });

  factory PromoCodeModel.fromJson(Map<String, dynamic> json) {
    return PromoCodeModel(
      id: json['id'] as String,
      code: json['code'] as String,
      discountType: json['discount_type'] == 'percentage'
          ? DiscountType.percentage
          : DiscountType.fixed,
      discountValue: (json['discount_value'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'discount_type': discountType == DiscountType.percentage ? 'percentage' : 'fixed',
      'discount_value': discountValue,
    };
  }
}
