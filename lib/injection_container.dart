import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/auth/auth_injection.dart';

final sl = GetIt.instance;

/// Entry point for all dependency injection.
///
/// Pattern: register shared/external dependencies first, then call each
/// feature module so they can resolve their own dependencies from [sl].
///
///  init()
///  ├── External (SupabaseClient, etc.)
///  ├── registerAuthDependencies(sl)
///  └── … future features (registerProductDependencies, etc.)
Future<void> init(SharedPreferences sharedPreferences) async {
  // ── External ─────────────────────────────────────────────────────────────
  // SupabaseClient must be registered before any feature that uses Supabase.
  // Supabase.initialize() is called in main.dart before this runs.
  sl.registerLazySingleton(() => Supabase.instance.client);
  sl.registerLazySingleton(() => sharedPreferences);

  // ── Features ─────────────────────────────────────────────────────────────
  registerAuthDependencies(sl);
  // registerProductDependencies(sl);   ← add future features here
  // registerOrderDependencies(sl);
}
