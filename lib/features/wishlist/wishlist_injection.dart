import 'package:get_it/get_it.dart';

import 'data/repositories/wishlist_repository_impl.dart';
import 'data/sources/wishlist_remote_data_source.dart';
import 'domain/repositories/wishlist_repository.dart';
import 'presentation/bloc/wishlist_bloc.dart';

void registerWishlistDependencies(GetIt sl) {
  // Data source
  sl.registerLazySingleton<WishlistRemoteDataSource>(
    () => WishlistRemoteDataSourceImpl(client: sl()),
  );

  // Repository
  sl.registerLazySingleton<WishlistRepository>(
    () => WishlistRepositoryImpl(remoteDataSource: sl()),
  );

  // Singleton so favorites and lists stay in sync across all pages
  sl.registerLazySingleton(() => WishlistBloc(repository: sl()));
}
