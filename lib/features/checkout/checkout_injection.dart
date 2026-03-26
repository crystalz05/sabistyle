import 'package:get_it/get_it.dart';

import 'data/repositories/address_repository_impl.dart';
import 'data/repositories/checkout_repository_impl.dart';
import 'data/sources/address_remote_data_source.dart';
import 'data/sources/checkout_remote_data_source.dart';
import 'domain/repositories/address_repository.dart';
import 'domain/repositories/checkout_repository.dart';
import 'presentation/bloc/address_bloc.dart';
import 'presentation/bloc/checkout_bloc.dart';

void registerCheckoutDependencies(GetIt sl) {
  // Remote Data Sources
  sl.registerLazySingleton<AddressRemoteDataSource>(
    () => AddressRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<CheckoutRemoteDataSource>(
    () => CheckoutRemoteDataSourceImpl(client: sl()),
  );

  // Repositories
  sl.registerLazySingleton<AddressRepository>(
    () => AddressRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<CheckoutRepository>(
    () => CheckoutRepositoryImpl(remoteDataSource: sl()),
  );

  // Blocs
  sl.registerFactory(() => AddressBloc(repository: sl()));
  sl.registerFactory(() => CheckoutBloc(repository: sl()));
}
