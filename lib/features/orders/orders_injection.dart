import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/repositories/order_repository_impl.dart';
import 'data/sources/order_remote_data_source.dart';
import 'domain/repositories/order_repository.dart';
import 'presentation/bloc/order_bloc.dart';

void registerOrderDependencies(GetIt sl) {
  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(client: sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(dataSource: sl<OrderRemoteDataSource>()),
  );

  sl.registerFactory(
    () => OrderBloc(repository: sl<OrderRepository>()),
  );
}
