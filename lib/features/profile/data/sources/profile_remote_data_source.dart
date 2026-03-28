import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
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

  // @override
  // Future<ProfileModel> uploadAvatar(String filePath) async {
  //   try {
  //     final file = File(filePath);
  //     final ext = filePath.split('.').last.toLowerCase();
  //     final fileName = '$_userId/avatar.$ext';
  //
  //     debugPrint('[uploadAvatar] Start. UserId: $_userId');
  //     debugPrint('[uploadAvatar] fileName: $fileName');
  //     debugPrint('[uploadAvatar] file path: $filePath');
  //     debugPrint('[uploadAvatar] file exists: ${file.existsSync()}');
  //
  //     debugPrint('[uploadAvatar] Attempting to upload to Supabase storage...');
  //
  //     await _testBucket();
  //
  //     await _client.storage
  //         .from('avatars')
  //         .upload(fileName, file, fileOptions: const FileOptions(upsert: true));
  //     debugPrint('[uploadAvatar] Upload completed successfully.');
  //
  //
  //     debugPrint('[uploadAvatar] Fetching public URL...');
  //     final publicUrl =
  //         _client.storage.from('avatars').getPublicUrl(fileName);
  //     debugPrint('[uploadAvatar] Public URL: $publicUrl');
  //
  //     debugPrint('[uploadAvatar] Updating users table with new avatar URL...');
  //     await _client
  //         .from('users')
  //         .update({'avatar_url': publicUrl}).eq('id', _userId);
  //     debugPrint('[uploadAvatar] Database update successful.');
  //
  //     return fetchProfile();
  //   } on StorageException catch (e) {
  //     debugPrint('[uploadAvatar] StorageException caught!');
  //     debugPrint('  Message: ${e.message}');
  //     debugPrint('  Status code: ${e.statusCode}');
  //     debugPrint('  Error detail: ${e.error}');
  //     throw AppException('Storage error uploading avatar: ${e.message} (Code: ${e.statusCode})');
  //   } catch (e) {
  //     debugPrint('[uploadAvatar] General Exception: $e');
  //     throw AppException('Failed to upload avatar: $e');
  //   }
  // }

  @override
  Future<ProfileModel> uploadAvatar(String filePath) async {
    try {
      final file = File(filePath);
      final ext = filePath.split('.').last.toLowerCase();
      final fileName = '$_userId/avatar.$ext';
      final bytes = await file.readAsBytes();

      final accessToken = _client.auth.currentSession?.accessToken;

      final uploadUrl =
          '${AppConfig.supabaseUrl}/storage/v1/object/avatars/$fileName';

      final dio = Dio();
      await dio.put(
        uploadUrl,
        data: bytes,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'apikey': AppConfig.supabaseAnonKey,
            'Content-Type': 'image/$ext',
            'x-upsert': 'true',
          },
        ),
      );

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final publicUrl = '${AppConfig.supabaseUrl}/storage/v1/object/public/avatars/$fileName?t=$timestamp';

      await _client
          .from('users')
          .update({'avatar_url': publicUrl}).eq('id', _userId);

      return fetchProfile();
    } on DioException catch (e) {
      debugPrint('[uploadAvatar] DioException: ${e.response?.data}');
      throw AppException('Upload failed: ${e.response?.data}');
    } catch (e) {
      debugPrint('[uploadAvatar] Exception: $e');
      throw AppException('Failed to upload avatar: $e');
    }
  }
}
