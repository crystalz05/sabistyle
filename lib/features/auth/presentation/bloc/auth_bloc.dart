import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

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
    if (initialUser != null) {
      emit(Authenticated(initialUser));
    } else {
      emit(Unauthenticated());
    }

    // ── 4. Keep listening for subsequent auth changes (token refresh, etc.)
    await emit.onEach<AppUser?>(
      _repository.authStateChanges,
      onData: (user) {
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(Unauthenticated());
        }
      },
      onError: (error, stack) => emit(Unauthenticated()),
    );
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _loginUseCase(
        LoginParams(email: event.email, password: event.password),
      );
      emit(Authenticated(user));
    } on AppException catch (e) {
      emit(AuthError(e.message));
    } catch (_) {
      emit(const AuthError('Sign in failed. Please try again.'));
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
      emit(AuthError(e.message));
    } catch (_) {
      emit(const AuthError('Sign up failed. Please try again.'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _repository.signOut();
      emit(Unauthenticated());
    } on AppException catch (e) {
      emit(AuthError(e.message));
    } catch (_) {
      emit(const AuthError('Sign out failed. Please try again.'));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
