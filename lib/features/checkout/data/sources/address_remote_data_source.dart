import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/address_model.dart';

abstract class AddressRemoteDataSource {
  Future<List<AddressModel>> fetchAddresses();
  Future<AddressModel> addAddress(AddressModel address);
  Future<void> updateAddress(AddressModel address);
  Future<void> deleteAddress(String addressId);
  Future<void> setDefault(String addressId);
}

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final SupabaseClient _client;

  AddressRemoteDataSourceImpl({required SupabaseClient client})
    : _client = client;

  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<List<AddressModel>> fetchAddresses() async {
    final response = await _client
        .from('addresses')
        .select()
        .eq('user_id', _userId)
        .order('is_default', ascending: false);

    return (response as List)
        .map((json) => AddressModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AddressModel> addAddress(AddressModel address) async {
    final response = await _client
        .from('addresses')
        .insert(address.toJson())
        .select()
        .single();

    return AddressModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> updateAddress(AddressModel address) async {
    await _client
        .from('addresses')
        .update({
          'full_name': address.fullName,
          'phone': address.phone,
          'street': address.street,
          'city': address.city,
          'state': address.state,
        })
        .eq('id', address.id);
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    await _client.from('addresses').delete().eq('id', addressId);
  }

  @override
  Future<void> setDefault(String addressId) async {
    // Clear all defaults first, then set the chosen one.
    await _client
        .from('addresses')
        .update({'is_default': false})
        .eq('user_id', _userId);

    await _client
        .from('addresses')
        .update({'is_default': true})
        .eq('id', addressId);
  }
}
