import '../entities/address.dart';

abstract class AddressRepository {
  Future<List<Address>> fetchAddresses();
  Future<Address> addAddress(Address address);
  Future<void> updateAddress(Address address);
  Future<void> deleteAddress(String addressId);
  Future<void> setDefault(String addressId);
}
