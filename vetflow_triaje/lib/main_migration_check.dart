import 'package:flutter/material.dart';
import 'package:vetflow_triaje/app/app.dart';
import 'package:vetflow_triaje/app/di/app_dependencies.dart';
import 'package:vetflow_triaje/app/router/app_router.dart';
import 'package:vetflow_triaje/main.dart' as app_entry;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  app_entry.appDependencies = AppDependencies.create(demoMode: true);
  runApp(VetFlowApp(router: createAppRouter(hasSession: () => false)));
}
