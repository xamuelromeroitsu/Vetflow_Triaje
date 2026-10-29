import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vetflow_triaje/app/supabase_initializer.dart';
import 'package:vetflow_triaje/app/di/app_dependencies.dart';
import 'package:vetflow_triaje/main.dart' as app_entry;
import 'package:vetflow_triaje/shared/presentation/theme/app_theme_clinical_mint.dart';
import 'package:vetflow_triaje/features/auth/presentation/screens/onboarding_welcome_clinical_mint.dart';
import 'package:vetflow_triaje/features/auth/presentation/screens/login_screen_clinical_mint.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeSupabase();
  app_entry.appDependencies = AppDependencies.create(demoMode: false);
  runApp(const AuthTestApp());
}

class AuthTestApp extends StatelessWidget {
  const AuthTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const OnboardingWelcomeClinicalMintScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreenClinicalMint(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'VetFlow Triaje - Auth Test',
      theme: clinicalMintTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
