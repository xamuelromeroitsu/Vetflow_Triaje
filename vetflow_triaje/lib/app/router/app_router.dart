/// Configuración de navegación de la app usando GoRouter.
///
/// Define todas las rutas del flujo de usuario:
///  - /             : Pantalla de bienvenida/onboarding
///  - /login        : Inicio de sesión
///  - /register     : Crear cuenta
///  - /pets         : Lista/selección de mascotas
///  - /pets/register: Registro de nueva mascota
///  - /triage/symptoms : Captura de síntomas
///  - /triage/red-flags: Preguntas de descarte
///  - /triage/vitals   : Signos vitales
///  - /triage/result   : Resultado de triaje (sugerido)
///  - /triage/vet-confirmation : Confirmación del veterinario
///  - /queue         : Cola de atención / clínicas cercanas
///  - /emergency     : Llamada de emergencia directa
library;

import 'package:go_router/go_router.dart';
import 'package:vetflow_triaje/features/auth/presentation/login_screen.dart';
import 'package:vetflow_triaje/features/auth/presentation/register_screen.dart';
import 'package:vetflow_triaje/features/onboarding/presentation/welcome_screen.dart';
import 'package:vetflow_triaje/features/pets/presentation/pet_list_screen.dart';
import 'package:vetflow_triaje/features/pets/presentation/pet_register_screen.dart';
import 'package:vetflow_triaje/features/queue/presentation/queue_screen.dart';
import 'package:vetflow_triaje/features/triage/presentation/red_flags_screen.dart';
import 'package:vetflow_triaje/features/triage/presentation/symptoms_screen.dart';
import 'package:vetflow_triaje/features/triage/presentation/triage_result_screen.dart';
import 'package:vetflow_triaje/features/triage/presentation/vet_confirmation_screen.dart';
import 'package:vetflow_triaje/features/triage/presentation/vital_signs_screen.dart';

/// Configuración principal del router de la aplicación.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Pantalla de bienvenida / onboarding
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomeScreen(),
    ),

    // Autenticación
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // Mascotas
    GoRoute(
      path: '/pets',
      builder: (context, state) => const PetListScreen(),
    ),
    GoRoute(
      path: '/pets/register',
      builder: (context, state) => const PetRegisterScreen(),
    ),

    // Triaje
    GoRoute(
      path: '/triage/symptoms',
      builder: (context, state) => const SymptomsScreen(),
    ),
    GoRoute(
      path: '/triage/red-flags',
      builder: (context, state) => const RedFlagsScreen(),
    ),
    GoRoute(
      path: '/triage/vitals',
      builder: (context, state) => const VitalSignsScreen(),
    ),
    GoRoute(
      path: '/triage/result',
      builder: (context, state) => const TriageResultScreen(),
    ),
    GoRoute(
      path: '/triage/vet-confirmation',
      builder: (context, state) => const VetConfirmationScreen(),
    ),

    // Cola / clínicas
    GoRoute(
      path: '/queue',
      builder: (context, state) => const QueueScreen(),
    ),

    // Emergencia
    GoRoute(
      path: '/emergency',
      builder: (context, state) => const EmergencyScreen(),
    ),
  ],
);

/// Pantalla de llamada de emergencia directa.
class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Emergencia en curso'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.phone, size: 80, color: Colors.red),
            const SizedBox(height: 24),
            const Text(
              '¿Emergencia en curso?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Línea directa veterinaria',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  // Llamada directa al número de emergencia
                },
                icon: const Icon(Icons.phone),
                label: const Text('Llamar 911-PET'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
