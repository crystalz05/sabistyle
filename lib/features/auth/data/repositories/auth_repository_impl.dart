import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../sources/auth_remote_data_source.dart';

/// Implements [AuthRepository] by delegating to [AuthRemoteDatasource].
/// In MVP this is a thin pass-through. The separation pays off when you
/// add caching, offline support, or swap the backend.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._datasource);

  final AuthRemoteDatasource _datasource;

  @override
  Stream<AppUser?> get authStateChanges => _datasource.authStateChanges;

  @override
  Stream<AuthChangeEvent> get rawAuthEvents => _datasource.rawAuthEvents;

  @override
  AppUser? get currentUser => _datasource.currentUser;

  @override
  Future<AppUser> signUp({
    required String fullName,
    required String email,
    required String password,
  }) =>
      _datasource.signUp(
        fullName: fullName,
        email: email,
        password: password,
      );

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) =>
      _datasource.signIn(email: email, password: password);

  @override
  Future<void> signOut() => _datasource.signOut();

  @override
  Future<void> resetPassword({required String email}) =>
      _datasource.resetPassword(email: email);

  @override
  Future<void> updatePassword({required String newPassword}) =>
      _datasource.updatePassword(newPassword: newPassword);
}