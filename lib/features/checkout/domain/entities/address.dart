import 'package:equatable/equatable.dart';

class Address extends Equatable {
  final String id;
  final String userId;
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String state;
  final bool isDefault;

  const Address({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.state,
    this.isDefault = false,
  });

  String get displayAddress => '$street, $city, $state';

  @override
  List<Object?> get props => [
    id,
    userId,
    fullName,
    phone,
    street,
    city,
    state,
    isDefault,
  ];
}
