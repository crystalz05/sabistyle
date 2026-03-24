import 'package:get_it/get_it.dart';

import 'data/repositories/home_repository_impl.dart';
import 'data/sources/home_remote_data_source.dart';
import 'domain/repositories/home_repository.dart';
import 'presentation/bloc/home_bloc.dart';

void registerHomeDependencies(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(client: sl()),
  );

  // Repositories
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl()),
  );

  // Blocs
  sl.registerFactory(() => HomeBloc(repository: sl()));
}
