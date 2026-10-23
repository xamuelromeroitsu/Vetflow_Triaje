/// Widget raíz de la aplicación.
///
/// Configura MaterialApp con GoRouter para navegación y el tema visual
/// de VetFlow Triaje.
library;

import 'package:flutter/material.dart';
import 'package:vetflow_triaje/app/router/app_router.dart';
import 'package:vetflow_triaje/shared/presentation/theme/app_theme.dart';

class VetFlowApp extends StatelessWidget {
  const VetFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'VetFlow Triaje',
      theme: appTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
