import '../../../../core/error/error_mapper.dart';
import '../../domain/entities/address.dart';
import '../../domain/repositories/address_repository.dart';
import '../models/address_model.dart';
import '../sources/address_remote_data_source.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource _remoteDataSource;

  AddressRepositoryImpl({required AddressRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<List<Address>> fetchAddresses() async {
    try {
      return await _remoteDataSource.fetchAddresses();
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }

  @override
  Future<Address> addAddress(Address address) async {
    try {
      final model = AddressModel(
        id: '',
        userId: address.userId,
        fullName: address.fullName,
        phone: address.phone,
        street: address.street,
        city: address.city,
        state: address.state,
        isDefault: address.isDefault,
      );
      return await _remoteDataSource.addAddress(model);
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }

  @override
  Future<void> updateAddress(Address address) async {
    try {
      final model = AddressModel(
        id: address.id,
        userId: address.userId,
        fullName: address.fullName,
        phone: address.phone,
        street: address.street,
        city: address.city,
        state: address.state,
        isDefault: address.isDefault,
      );
      await _remoteDataSource.updateAddress(model);
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    try {
      await _remoteDataSource.deleteAddress(addressId);
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }

  @override
  Future<void> setDefault(String addressId) async {
    try {
      await _remoteDataSource.setDefault(addressId);
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }
}
