import 'package:equatable/equatable.dart';

/// Domain entity — no Supabase types leak past the data layer.
class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.avatarUrl,
  });

  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? avatarUrl;

  AppUser copyWith({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) =>
      AppUser(
        id: id,
        email: email,
        fullName: fullName ?? this.fullName,
        phone: phone ?? this.phone,
        avatarUrl: avatarUrl ?? this.avatarUrl,
      );

  @override
  List<Object?> get props => [id, email, fullName, phone, avatarUrl];
}