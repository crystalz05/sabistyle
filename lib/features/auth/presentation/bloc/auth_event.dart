import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when the app starts — subscribes to auth state changes.
class AppStarted extends AuthEvent {
  final Uri? initialUri;

  const AppStarted({this.initialUri});

  @override
  List<Object?> get props => [initialUri];
}

/// Dispatched when the app receives a deep link while already running (warm start).
class DeepLinkReceived extends AuthEvent {
  final Uri uri;
  
  const DeepLinkReceived(this.uri);

  @override
  List<Object?> get props => [uri];
}

/// Dispatched when the user submits the login form.
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Dispatched when the user submits the sign-up form.
class SignUpRequested extends AuthEvent {
  final String fullName;
  final String email;
  final String password;

  const SignUpRequested({
    required this.fullName,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [fullName, email, password];
}

/// Dispatched when the user taps "Log out".
class LogoutRequested extends AuthEvent {}

/// Dispatched when the user requests a password reset link.
class ResetPasswordRequested extends AuthEvent {
  final String email;

  const ResetPasswordRequested(this.email);

  @override
  List<Object?> get props => [email];
}

/// Dispatched when the user submits a new password after clicking the reset link.
class UpdatePasswordRequested extends AuthEvent {
  final String newPassword;

  const UpdatePasswordRequested(this.newPassword);

  @override
  List<Object?> get props => [newPassword];
}

/// Dispatched when the user taps "Delete Account".
class DeleteAccountRequested extends AuthEvent {}
