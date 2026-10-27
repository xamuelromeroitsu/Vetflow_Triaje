import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vetflow_triaje/features/auth/presentation/screens/login_screen_clinical_mint.dart';
import 'package:vetflow_triaje/features/auth/presentation/screens/onboarding_welcome_clinical_mint.dart';
import 'package:vetflow_triaje/firebase_options.dart';
import 'package:vetflow_triaje/shared/presentation/theme/app_theme_clinical_mint.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MinApp());
}

class MinApp extends StatelessWidget {
  const MinApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const OnboardingWelcomeClinicalMintScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreenClinicalMint(),
        ),
        GoRoute(
          path: '/pets',
          builder: (context, state) => const Scaffold(
            body: Center(
              child: Text('Autenticado - Pets (min)'),
            ),
          ),
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
