import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../../../core/error/app_exception.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Minimum time the splash screen is visible, even if auth resolves faster.
const _kSplashMinDuration = Duration(seconds: 2);

/// Manages authentication state for the entire app.
///
/// Lifecycle:
///  1. [AppStarted] — subscribes to the auth stream from Supabase. The splash
///     screen dispatches this event; the BLoC then emits [Authenticated] or
///     [Unauthenticated] once Supabase resolves the session.
///  2. [LoginRequested] — signs in with email + password.
///  3. [SignUpRequested] — creates a new account (triggers the DB trigger that
///     inserts a row into `public.users`).
///  4. [LogoutRequested] — signs out.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;
  final LoginUseCase _loginUseCase;
  StreamSubscription<AppUser?>? _authSubscription;
  StreamSubscription<AuthChangeEvent>? _rawAuthSubscription;

  AuthBloc({
    required AuthRepository repository,
    required LoginUseCase loginUseCase,
  })  : _repository = repository,
        _loginUseCase = loginUseCase,
        super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<UpdatePasswordRequested>(_onUpdatePasswordRequested);
    on<DeepLinkReceived>(_onDeepLinkReceived);
  }

  // ------------------------------------------------------------------ //
  // Handlers
  // ------------------------------------------------------------------ //

  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // ── 1. Determine initial auth state from the Supabase stream ──────────
    // We use a Completer to capture only the *first* event from the stream
    // (the initial session check) without keeping the subscription alive.
    final sessionCompleter = Completer<AppUser?>();
    late StreamSubscription<AppUser?> sub;
    sub = _repository.authStateChanges.listen(
      (user) {
        if (!sessionCompleter.isCompleted) {
          sessionCompleter.complete(user);
          sub.cancel();
        }
      },
      onError: (Object error) {
        if (!sessionCompleter.isCompleted) {
          sessionCompleter.complete(null);
          sub.cancel();
        }
      },
    );

    // ── 2. Run auth check + minimum splash delay in parallel ────────────
    // The splash is always shown for at least [_kSplashMinDuration],
    // regardless of how quickly Supabase resolves the session.
    final results = await Future.wait<dynamic>([
      sessionCompleter.future,
      Future<void>.delayed(_kSplashMinDuration),
    ]);

    final initialUser = results[0] as AppUser?;

    // ── 3. Emit the resolved state ────────────────────────────────────────
    final initialUri = event.initialUri;
    // For sabistyle://reset-password, the host is reset-password (not the path)
    if (initialUri != null && initialUri.host == 'reset-password') {
      debugPrint('[AuthBloc] Caught initial deep link: $initialUri');
      emit(PasswordResetReady());
    } else if (initialUser != null) {
      emit(Authenticated(initialUser));
    } else {
      emit(Unauthenticated());
    }

    // ── 4. Listen for background deep links (warm start) ──────────────────
    _rawAuthSubscription?.cancel();
    _rawAuthSubscription = _repository.rawAuthEvents.listen((authEvent) {
      debugPrint('[AuthBloc] Raw auth event: $authEvent');
      if (authEvent == AuthChangeEvent.passwordRecovery) {
        debugPrint('[AuthBloc] Warm start passwordRecovery — emitting PasswordResetReady');
        emit(PasswordResetReady());
      }
    });

    // ── 5. Keep listening for subsequent auth changes (token refresh, etc.)
    await emit.onEach<AppUser?>(
      _repository.authStateChanges,
      onData: (user) {
        // Guard against overriding PasswordResetReady with normal auth events
        if (state is PasswordResetReady) return;

        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(Unauthenticated());
        }
      },
      onError: (error, stack) {
        if (state is PasswordResetReady) return;
        emit(Unauthenticated());
      },
    );
  }

  void _onDeepLinkReceived(
    DeepLinkReceived event,
    Emitter<AuthState> emit,
  ) {
    debugPrint('[AuthBloc] DeepLinkReceived: ${event.uri}');
    if (event.uri.host == 'reset-password') {
      emit(PasswordResetReady());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    final prevUser = state is Authenticated ? (state as Authenticated).user : null;
    emit(AuthLoading());
    try {
      final user = await _loginUseCase(
        LoginParams(email: event.email, password: event.password),
      );
      emit(Authenticated(user));
    } on AppException catch (e) {
      emit(AuthError(e.message));
      if (prevUser != null) emit(Authenticated(prevUser));
    } catch (_) {
      emit(const AuthError('Sign in failed. Please try again.'));
      if (prevUser != null) emit(Authenticated(prevUser));
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // signUp stores full_name in auth metadata, which the DB trigger picks
      // up to insert a row into public.users automatically.
      final user = await _repository.signUp(
        fullName: event.fullName,
        email: event.email,
        password: event.password,
      );
      emit(Authenticated(user));
    } on AppException catch (e) {
      if (e.code == 'email_confirmation_required') {
        // Not an error — user needs to verify their email first.
        emit(AwaitingVerification(event.email));
      } else {
        emit(AuthError(e.message));
      }
    } catch (_) {
      emit(const AuthError('Sign up failed. Please try again.'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    final prevUser = state is Authenticated ? (state as Authenticated).user : null;
    emit(AuthLoading());
    try {
      await _repository.signOut();
      emit(Unauthenticated());
    } on AppException catch (e) {
      emit(AuthError(e.message));
      if (prevUser != null) emit(Authenticated(prevUser));
    } catch (_) {
      emit(const AuthError('Sign out failed. Please try again.'));
      if (prevUser != null) emit(Authenticated(prevUser));
    }
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _repository.resetPassword(email: event.email);
      emit(PasswordResetEmailSent(event.email));
    } on AppException catch (e) {
      emit(AuthError(e.message));
    } catch (_) {
      emit(const AuthError('Could not send reset email. Please try again.'));
    }
  }

  Future<void> _onUpdatePasswordRequested(
    UpdatePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    final prevUser = state is Authenticated ? (state as Authenticated).user : null;
    emit(AuthLoading());
    try {
      await _repository.updatePassword(newPassword: event.newPassword);
      emit(PasswordUpdated());
      if (prevUser != null) emit(Authenticated(prevUser));
    } on AppException catch (e) {
      emit(AuthError(e.message));
      if (prevUser != null) emit(Authenticated(prevUser));
    } catch (_) {
      emit(const AuthError('Could not update password. Please try again.'));
      if (prevUser != null) emit(Authenticated(prevUser));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    _rawAuthSubscription?.cancel();
    return super.close();
  }
}
