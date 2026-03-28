import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/network/network_bloc.dart';
import 'core/network/network_info.dart';
import 'features/auth/auth_injection.dart';
import 'features/cart/cart_injection.dart';
import 'features/checkout/checkout_injection.dart';
import 'features/home/home_injection.dart';
import 'features/orders/orders_injection.dart';
import 'features/wishlist/wishlist_injection.dart';
import 'features/profile/profile_injection.dart';
import 'features/notifications/notification_injection.dart';

final sl = GetIt.instance;

/// Entry point for all dependency injection.
Future<void> init(SharedPreferences sharedPreferences) async {
  sl.registerLazySingleton(() => Supabase.instance.client);
  sl.registerLazySingleton(() => sharedPreferences);

  sl.registerLazySingleton(() => NetworkInfo.instance);
  sl.registerFactory(() => NetworkBloc(sl()));

  registerAuthDependencies(sl);
  registerHomeDependencies(sl);

  // Shopping features
  registerWishlistDependencies(sl);
  registerCartDependencies(sl);
  registerCheckoutDependencies(sl);
  registerOrderDependencies(sl);
  registerProfileDependencies(sl);
  registerNotificationDependencies(sl);
}
