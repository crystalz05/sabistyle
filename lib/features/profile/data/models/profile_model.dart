import '../../../auth/domain/entities/app_user.dart';

/// Data-layer model for the `public.users` table.
class ProfileModel extends AppUser {
  const ProfileModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.phone,
    super.avatarUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'phone': phone,
        'avatar_url': avatarUrl,
      };
}
