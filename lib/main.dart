import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase before anything else so that
  // Supabase.instance.client is available when DI wires up the datasource.
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  // Wire up dependency injection.
  final prefs = await SharedPreferences.getInstance();
  await di.init(prefs);

  runApp(const MyApp());
}
