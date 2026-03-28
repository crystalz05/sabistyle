import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/error/error_mapper.dart';
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
      final authEvent = event.event;

      // Handle password recovery differently so it's not processed as a normal sign-in
      if (authEvent == AuthChangeEvent.passwordRecovery) {
        debugPrint('[Datasource] Explicitly ignoring passwordRecovery event');
        return null;
      }

      if (session == null || session.user.emailConfirmedAt == null) {
        return null;
      }
      try {
        return await _fetchAppUser(session.user.id, session.user.email ?? '');
      } on AppException {
        // Profile row missing — session was already revoked inside _fetchAppUser.
        return null;
      } catch (_) {
        return null;
      }
    });
  }

  /// Raw stream of Supabase auth events (useful for capturing background deep links).
  Stream<AuthChangeEvent> get rawAuthEvents {
    return _client.auth.onAuthStateChange.map((event) => event.event);
  }

  // ------------------------------------------------------------------ //
  // Current user (sync)
  // ------------------------------------------------------------------ //

  AppUser? get currentUser {
    final user = _client.auth.currentUser;
    if (user == null || user.emailConfirmedAt == null) return null;
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
      if (user == null || user.emailConfirmedAt == null) {
        // Supabase stores the user ID even when email confirmation is pending.
        // Send a welcome in-app notification so it appears once they verify.
        if (user != null) {
          _insertNotification(
            userId: user.id,
            title: '🎉 Welcome to SabiStyle!',
            body: 'Check your email to verify your account.',
            type: 'auth',
          );
        }
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
    } catch (e) {
      throw ErrorMapper.fromError(e);
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
      
      if (user.emailConfirmedAt == null) {
        await _client.auth.signOut();
        throw const AppException('Please check your inbox and verify your email to continue.');
      }

      return await _fetchAppUser(user.id, user.email ?? email);
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }

  // ------------------------------------------------------------------ //
  // Sign out
  // ------------------------------------------------------------------ //

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }

  // ------------------------------------------------------------------ //
  // Delete account
  // ------------------------------------------------------------------ //

  Future<void> deleteAccount() async {
    try {
      await _client.rpc('delete_user');
      await _client.auth.signOut();
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }

  // ------------------------------------------------------------------ //
  // Reset password
  // ------------------------------------------------------------------ //

  Future<void> resetPassword({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'sabistyle://reset-password',
      );
      // Best-effort: look up the user's ID from public.users so we can notify them.
      // If the user doesn't exist we simply skip the notification.
      final data = await _client
          .from('users')
          .select('id')
          .eq('email', email)
          .maybeSingle();
      if (data != null) {
        _insertNotification(
          userId: data['id'] as String,
          title: '🔐 Password Reset',
          body: 'A reset link has been sent to your email.',
          type: 'auth',
        );
      }
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }

  /// Updates the user's password.
  /// Must be called after the user has clicked the reset password link and
  /// their session is active.
  Future<void> updatePassword({required String newPassword}) async {
    try {
      final response = await _client.auth.updateUser(UserAttributes(password: newPassword));
      final user = response.user;
      if (user != null) {
        _insertNotification(
          userId: user.id,
          title: '✅ Password Updated',
          body: 'Your account password has been successfully changed.',
          type: 'auth',
        );
      }
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }

  // ------------------------------------------------------------------ //
  // Private helpers
  // ------------------------------------------------------------------ //

  /// Fetches the extended profile from public.users and merges it
  /// with the auth data so the domain entity is fully populated.
  ///
  /// Throws [AppException] (and signs out) when the profile row is missing
  /// entirely, so callers can differentiate between a deleted user and a
  /// transient network error.
  Future<AppUser> _fetchAppUser(String userId, String email) async {
    try {
      final data = await _client
          .from('users')
          .select('full_name, phone, avatar_url')
          .eq('id', userId)
          .maybeSingle();

      if (data == null) {
        // Profile row does not exist — the user was deleted from the DB.
        // Revoke the local session so they are treated as unauthenticated.
        await _client.auth.signOut();
        throw AppException(
          'Your account could not be found. Please sign in again.',
          code: 'profile_not_found',
        );
      }

      return AppUser(
        id: userId,
        email: email,
        fullName: data['full_name'] as String? ?? '',
        phone: data['phone'] as String?,
        avatarUrl: data['avatar_url'] as String?,
      );
    } on AppException {
      rethrow;
    } catch (_) {
      // Transient network error — return a minimal user so the session
      // is not invalidated on a flaky connection.
      return AppUser(id: userId, email: email, fullName: '');
    }
  }

  /// Fire-and-forget helper that inserts a notification row.
  /// Errors are intentionally swallowed so they never disrupt auth flows.
  void _insertNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
  }) {
    _client.from('notifications').insert({
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type,
      'is_read': false,
    }).then((_) {
      debugPrint('[AuthDatasource] Notification inserted: $title');
    }).catchError((e) {
      debugPrint('[AuthDatasource] _insertNotification failed: $e');
    });
  }
}