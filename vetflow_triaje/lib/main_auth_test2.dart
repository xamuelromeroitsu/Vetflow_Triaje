import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vetflow_triaje/app/di/app_dependencies.dart';
import 'package:vetflow_triaje/features/auth/presentation/screens/onboarding_welcome_clinical_mint.dart';
import 'package:vetflow_triaje/features/auth/presentation/screens/login_screen_clinical_mint.dart';
import 'package:vetflow_triaje/firebase_options.dart';
import 'package:vetflow_triaje/shared/presentation/theme/app_theme_clinical_mint.dart';

late final AppDependencies appDependencies;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}
  appDependencies = AppDependencies.create();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) =>
              const MaterialPage(child: OnboardingWelcomeClinicalMintScreen()),
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) =>
              const MaterialPage(child: LoginScreenClinicalMint()),
        ),
      ],
    );
    return MaterialApp.router(
      title: 'VetFlow',
      theme: clinicalMintTheme,
      routerConfig: router,
    );
  }
}
