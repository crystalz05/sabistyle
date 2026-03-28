import 'package:get_it/get_it.dart';

import 'data/repositories/notification_repository_impl.dart';
import 'data/sources/notification_remote_data_source.dart';
import 'domain/repositories/notification_repository.dart';
import 'presentation/bloc/notification_bloc.dart';

void registerNotificationDependencies(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(client: sl()),
  );

  // Repositories
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl()),
  );

  // Blocs
  // Using LazySingleton because the Bloc should persist across the home shell
  // so the badge icon in the app bar can constantly listen to the same instance.
  sl.registerLazySingleton<NotificationBloc>(
    () => NotificationBloc(repository: sl()),
  );
}
