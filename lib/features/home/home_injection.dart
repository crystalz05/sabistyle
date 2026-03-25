import 'package:get_it/get_it.dart';
import 'package:sabistyle/features/home/presentation/bloc/product_bloc.dart';
import 'package:sabistyle/features/home/presentation/bloc/search_bloc.dart';
import 'package:sabistyle/features/home/presentation/bloc/review_bloc.dart';

import 'data/repositories/home_repository_impl.dart';
import 'data/repositories/product_repository_impl.dart';
import 'data/repositories/review_repository_impl.dart';
import 'data/sources/home_remote_data_source.dart';
import 'data/sources/product_remote_data_source.dart';
import 'data/sources/review_remote_data_source.dart';
import 'data/sources/search_history_local_data_source.dart';
import 'domain/repositories/home_repository.dart';
import 'domain/repositories/product_repository.dart';
import 'domain/repositories/review_repository.dart';
import 'presentation/bloc/home_bloc.dart';

void registerHomeDependencies(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<ReviewRemoteDataSource>(
    () => ReviewRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<SearchHistoryLocalDataSource>(
    () => SearchHistoryLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repositories
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remoteDataSource: sl(),
      historyLocalDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(remoteDataSource: sl()),
  );

  // Blocs
  sl.registerFactory(() => HomeBloc(repository: sl()));
  sl.registerFactory(() => ProductBloc(repository: sl()));
  sl.registerFactory(() => SearchBloc(repository: sl()));
  sl.registerFactory(() => ReviewBloc(repository: sl()));
}
