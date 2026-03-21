import 'package:equatable/equatable.dart';
import '../../../../core/error/app_exception.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Signs in with email + password.
/// Returns [AppUser] on success, throws [AppException] on failure.
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<AppUser> call(LoginParams params) {
    return repository.signIn(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
