/// Widget raíz de la aplicación.
///
/// Configura MaterialApp con GoRouter para navegación y el tema visual
/// de VetFlow Triaje.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vetflow_triaje/app/router/app_router.dart';
import 'package:vetflow_triaje/shared/presentation/theme/app_theme_clinical_mint.dart';

class VetFlowApp extends StatelessWidget {
  const VetFlowApp({super.key, this.router});

  static const double _maxAppWidth = 600;

  final GoRouter? router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'VetFlow Triaje',
      theme: clinicalMintTheme,
      routerConfig: router ?? appRouter,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final appWidth = mediaQuery.size.width
            .clamp(0.0, _maxAppWidth)
            .toDouble();

        return ColoredBox(
          color: ClinicalMintColors.surfaceContainerLow,
          child: Center(
            child: SizedBox(
              width: appWidth,
              height: mediaQuery.size.height,
              child: MediaQuery(
                data: mediaQuery.copyWith(
                  size: Size(appWidth, mediaQuery.size.height),
                ),
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
    );
  }
}
