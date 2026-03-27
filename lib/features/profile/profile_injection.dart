import 'package:get_it/get_it.dart';

import 'data/repositories/profile_repository_impl.dart';
import 'data/sources/profile_remote_data_source.dart';
import 'domain/repositories/profile_repository.dart';
import 'presentation/bloc/profile_bloc.dart';

void registerProfileDependencies(GetIt sl) {
  // Bloc
  sl.registerFactory(
    () => ProfileBloc(repository: sl()),
  );

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(dataSource: sl()),
  );

  // Data Source
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(client: sl()),
  );
}
