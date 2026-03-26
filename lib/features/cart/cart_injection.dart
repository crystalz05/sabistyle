import 'package:get_it/get_it.dart';

import 'data/repositories/cart_repository_impl.dart';
import 'data/sources/cart_remote_data_source.dart';
import 'domain/repositories/cart_repository.dart';
import 'presentation/bloc/cart_bloc.dart';

void registerCartDependencies(GetIt sl) {
  sl.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(remoteDataSource: sl()),
  );

  // Singleton so the cart count badge stays in sync across pages
  sl.registerLazySingleton(() => CartBloc(repository: sl()));
}
