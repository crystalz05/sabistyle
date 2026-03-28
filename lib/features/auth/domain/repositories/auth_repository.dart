import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../entities/app_user.dart';

/// Contract the data layer must fulfil.
/// The BLoC only ever talks to this — never to Supabase directly.
abstract class AuthRepository {
  /// Stream that emits the current user on auth state changes.
  /// Emits null when logged out.
  Stream<AppUser?> get authStateChanges;

  /// Raw stream of Supabase auth events (useful for capturing background deep links).
  Stream<AuthChangeEvent> get rawAuthEvents;

  /// Returns the currently signed-in user, or null if none.
  AppUser? get currentUser;

  /// Creates a new account and inserts a row into public.users.
  /// Throws [AppException] on failure.
  Future<AppUser> signUp({
    required String fullName,
    required String email,
    required String password,
  });

  /// Signs in with email + password.
  /// Throws [AppException] on failure.
  Future<AppUser> signIn({
    required String email,
    required String password,
  });

  /// Signs out the current user.
  Future<void> signOut();

  /// Sends a password-reset email via Supabase.
  Future<void> resetPassword({required String email});

  /// Updates the user's password using an active session (e.g. after reset link).
  Future<void> updatePassword({required String newPassword});

  /// Deletes the user account permanently.
  Future<void> deleteAccount();
}