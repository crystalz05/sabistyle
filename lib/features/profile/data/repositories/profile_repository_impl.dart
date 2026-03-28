import '../../../../core/error/app_exception.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/repositories/profile_repository.dart';
import '../sources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _dataSource;

  ProfileRepositoryImpl({required ProfileRemoteDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<AppUser> fetchProfile() async {
    try {
      return await _dataSource.fetchProfile();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to load profile. Please try again.');
    }
  }

  @override
  Future<AppUser> updateProfile({
    required String fullName,
    String? phone,
  }) async {
    try {
      return await _dataSource.updateProfile(fullName: fullName, phone: phone);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to update profile. Please try again.');
    }
  }

  @override
  Future<AppUser> uploadAvatar(String filePath) async {
    try {
      return await _dataSource.uploadAvatar(filePath);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to upload avatar. Please try again.');
    }
  }
}
