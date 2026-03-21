import '../../domain/entities/app_user.dart';

/// Data-layer model that extends the domain [AppUser] entity.
/// Handles serialisation from Supabase JSON responses.
class UserModel extends AppUser {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.phone,
    super.avatarUrl,
  });

  /// Deserialises a row returned by `public.users` joined with auth metadata.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
    };
  }
}
