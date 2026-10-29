import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/di/app_dependencies.dart';
import 'app/supabase_initializer.dart';

late AppDependencies appDependencies;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeSupabase();

  appDependencies = AppDependencies.create(demoMode: false);
  runApp(const VetFlowApp());
}
