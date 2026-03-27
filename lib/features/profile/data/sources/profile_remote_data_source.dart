import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/app_exception.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> fetchProfile();
  Future<ProfileModel> updateProfile({required String fullName, String? phone});
  Future<ProfileModel> uploadAvatar(String filePath);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient _client;

  ProfileRemoteDataSourceImpl({required SupabaseClient client})
      : _client = client;

  String get _userId => _client.auth.currentUser!.id;
  String get _email => _client.auth.currentUser?.email ?? '';

  @override
  Future<ProfileModel> fetchProfile() async {
    try {
      final data = await _client
          .from('users')
          .select('id, full_name, phone, avatar_url')
          .eq('id', _userId)
          .single();

      return ProfileModel.fromJson({...data, 'id': _userId, 'email': _email});
    } catch (e) {
      throw AppException('Failed to fetch profile: $e');
    }
  }

  @override
  Future<ProfileModel> updateProfile({
    required String fullName,
    String? phone,
  }) async {
    try {
      await _client.from('users').update({
        'full_name': fullName,
        'phone': (phone == null || phone.isEmpty) ? null : phone,
      }).eq('id', _userId);

      return fetchProfile();
    } catch (e) {
      throw AppException('Failed to update profile: $e');
    }
  }

  @override
  Future<ProfileModel> uploadAvatar(String filePath) async {
    try {
      final file = File(filePath);
      final ext = filePath.split('.').last.toLowerCase();
      final fileName = '$_userId/avatar.$ext';

      await _client.storage
          .from('avatars')
          .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

      final publicUrl =
          _client.storage.from('avatars').getPublicUrl(fileName);

      await _client
          .from('users')
          .update({'avatar_url': publicUrl}).eq('id', _userId);

      return fetchProfile();
    } catch (e) {
      throw AppException('Failed to upload avatar: $e');
    }
  }
}
