import '../../../auth/domain/entities/app_user.dart';

abstract class ProfileRepository {
  Future<AppUser> fetchProfile();
  Future<AppUser> updateProfile({required String fullName, String? phone});
  Future<AppUser> uploadAvatar(String filePath);
}
