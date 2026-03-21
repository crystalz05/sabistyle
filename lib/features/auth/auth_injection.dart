import 'package:get_it/get_it.dart';

import 'package:sabistyle/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sabistyle/features/auth/data/sources/auth_remote_data_source.dart';
import 'package:sabistyle/features/auth/domain/repositories/auth_repository.dart';
import 'package:sabistyle/features/auth/domain/usecases/login_usecase.dart';
import 'package:sabistyle/features/auth/presentation/bloc/auth_bloc.dart';

/// Registers all auth-feature dependencies into [sl].
///
/// Call order (bottom-up, as GetIt resolves lazily):
///   External (SupabaseClient) → DataSource → Repository → UseCase → Bloc
///
/// Assumes [SupabaseClient] is already registered by the time this runs.
void registerAuthDependencies(GetIt sl) {
  // ── Bloc ────────────────────────────────────────────────────────────────
  // registerFactory so each BlocProvider gets a fresh instance.
  sl.registerFactory(
    () => AuthBloc(
      repository: sl(),
      loginUseCase: sl(),
    ),
  );

  // ── Use Cases ────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => LoginUseCase(sl()));

  // ── Repository ───────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );

  // ── Data Sources ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasource(sl()),
  );
}
