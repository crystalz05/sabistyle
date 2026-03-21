import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/app_user.dart';

/// Only class allowed to import supabase_flutter in the auth feature.
/// Everything is translated into domain types or [AppException] before
/// leaving this class.
class AuthRemoteDatasource {
  AuthRemoteDatasource(this._client);

  final SupabaseClient _client;

  // ------------------------------------------------------------------ //
  // Auth state stream
  // ------------------------------------------------------------------ //

  /// Re-emits every time Supabase fires an auth event.
  /// Maps to [AppUser] when signed in, null when signed out.
  Stream<AppUser?> get authStateChanges {
    return _client.auth.onAuthStateChange.asyncMap((event) async {
      final session = event.session;
      if (session == null) return null;
      return _fetchAppUser(session.user.id, session.user.email ?? '');
    });
  }

  // ------------------------------------------------------------------ //
  // Current user (sync)
  // ------------------------------------------------------------------ //

  AppUser? get currentUser {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    // We only have auth metadata here — profile comes from the DB later.
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] as String? ?? '',
    );
  }

  // ------------------------------------------------------------------ //
  // Sign up
  // ------------------------------------------------------------------ //

  Future<AppUser> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName}, // stored in auth.users.raw_user_meta_data
        // also picked up by the DB trigger
      );

      final user = response.user;
      if (user == null) {
        // Supabase returns user == null when email confirmation is required
        // and "Confirm email" is on. Treat as success — user must verify first.
        throw const AppException(
          'Account created! Please check your email to verify your account.',
          code: 'email_confirmation_required',
        );
      }

      return AppUser(
        id: user.id,
        email: user.email ?? email,
        fullName: fullName,
      );
    } on AppException {
      rethrow;
    } on AuthException catch (e) {
      throw AppException(_mapAuthError(e.message), code: e.statusCode);
    } catch (e) {
      throw AppException('Sign up failed. Please try again.');
    }
  }

  // ------------------------------------------------------------------ //
  // Sign in
  // ------------------------------------------------------------------ //

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) throw const AppException('Sign in failed.');

      return _fetchAppUser(user.id, user.email ?? email);
    } on AppException {
      rethrow;
    } on AuthException catch (e) {
      throw AppException(_mapAuthError(e.message), code: e.statusCode);
    } catch (e) {
      throw AppException('Sign in failed. Please try again.');
    }
  }

  // ------------------------------------------------------------------ //
  // Sign out
  // ------------------------------------------------------------------ //

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw AppException(e.message, code: e.statusCode);
    } catch (e) {
      throw AppException('Sign out failed.');
    }
  }

  // ------------------------------------------------------------------ //
  // Reset password
  // ------------------------------------------------------------------ //

  Future<void> resetPassword({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AppException(_mapAuthError(e.message), code: e.statusCode);
    } catch (e) {
      throw AppException('Could not send reset email. Please try again.');
    }
  }

  // ------------------------------------------------------------------ //
  // Private helpers
  // ------------------------------------------------------------------ //

  /// Fetches the extended profile from public.users and merges it
  /// with the auth data so the domain entity is fully populated.
  Future<AppUser> _fetchAppUser(String userId, String email) async {
    try {
      final data = await _client
          .from('users')
          .select('full_name, phone, avatar_url')
          .eq('id', userId)
          .maybeSingle();

      return AppUser(
        id: userId,
        email: email,
        fullName: data?['full_name'] as String? ?? '',
        phone: data?['phone'] as String?,
        avatarUrl: data?['avatar_url'] as String?,
      );
    } catch (_) {
      // Profile fetch failed but auth succeeded — return minimal user
      // rather than failing the whole login.
      return AppUser(id: userId, email: email, fullName: '');
    }
  }

  /// Maps Supabase auth error strings to user-friendly messages.
  String _mapAuthError(String raw) {
    final msg = raw.toLowerCase();
    if (msg.contains('invalid login credentials')) {
      return 'Incorrect email or password.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Please verify your email before signing in.';
    }
    if (msg.contains('user already registered')) {
      return 'An account with this email already exists.';
    }
    if (msg.contains('password should be at least')) {
      return 'Password must be at least 6 characters.';
    }
    if (msg.contains('rate limit')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    return raw; // fallback to raw Supabase message
  }
}