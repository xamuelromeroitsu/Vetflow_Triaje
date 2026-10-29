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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vetflow_triaje/features/auth/presentation/register_screen.dart';
import 'package:vetflow_triaje/features/auth/presentation/screens/login_screen_clinical_mint.dart';
import 'package:vetflow_triaje/features/auth/presentation/screens/dogo_welcome_screen.dart';
import 'package:vetflow_triaje/features/pets/presentation/pet_list_screen.dart';
import 'package:vetflow_triaje/pantalla%20de%20mvp%200000/registro_mascota_screen.dart';
import 'package:vetflow_triaje/pantalla%20de%20mvp%200000/ficha_signos_vitales_screen.dart';
import 'package:vetflow_triaje/pantalla%20de%20mvp%200000/cola_en_tiempo_real_screen.dart';
import 'package:vetflow_triaje/features/triage/presentation/red_flags_screen.dart';
import 'package:vetflow_triaje/features/triage/presentation/symptoms_screen.dart';
import 'package:vetflow_triaje/features/triage/presentation/triage_result_screen.dart';
import 'package:vetflow_triaje/features/triage/presentation/vet_confirmation_screen.dart';

/// Redirige según el estado de autenticación.
///
/// La sesión se conserva en Supabase Auth entre reinicios de la app.
String? _authRedirect(
  BuildContext context,
  GoRouterState state, {
  required bool isLoggedIn,
}) {
  final location = state.matchedLocation;
  final loggingIn = location == '/login';
  final registering = location == '/register';

  if (!isLoggedIn) {
    const publicLocations = {'/', '/login', '/register', '/emergency'};
    if (!publicLocations.contains(location)) return '/login';
    return null;
  }

  if (loggingIn || registering) return '/pets';
  return null;
}

/// Configuración principal del router de la aplicación.
GoRouter createAppRouter({required bool Function() hasSession}) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) =>
        _authRedirect(context, state, isLoggedIn: hasSession()),
    routes: [
      // Pantalla de bienvenida / onboarding
      GoRoute(
        path: '/',
        builder: (context, state) => const DogoWelcomeScreen(),
      ),

      // Autenticación
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreenClinicalMint(),
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
        builder: (context, state) => const RegistroMascotaScreen(),
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
        builder: (context, state) {
          final datos = state.extra;
          if (datos is MascotaRegistro) {
            return FichaSignosVitalesScreen(
              nombreMascota: datos.nombre,
              raza: datos.raza,
              sexoTexto: datos.sexo == Sexo.macho ? 'Macho' : 'Hembra',
              etiquetaEdad:
                  '${datos.edad?.toStringAsFixed(0) ?? '0'} ${datos.unidadEdad.toLowerCase()}',
              especie: switch (datos.especie) {
                Especie.perro => 'Perro',
                Especie.gato => 'Gato',
                Especie.exotico => 'Exótico',
              },
              fotoPath: datos.fotoPath,
            );
          }
          return const FichaSignosVitalesScreen(
            nombreMascota: 'Luna',
            raza: 'Común Europeo',
            sexoTexto: 'Hembra Esterilizada',
            etiquetaEdad: '3 años',
            especie: 'felino',
          );
        },
      ),
      GoRoute(
        path: '/triage/result',
        builder: (context, state) =>
            TriageResultScreen(visitId: state.uri.queryParameters['visitId']),
      ),
      GoRoute(
        path: '/triage/vet-confirmation',
        builder: (context, state) => const VetConfirmationScreen(),
      ),

      // Cola / clínicas
      GoRoute(
        path: '/queue',
        builder: (context, state) => const ColaEnTiempoRealScreen(),
      ),

      // Emergencia
      GoRoute(
        path: '/emergency',
        builder: (context, state) => const EmergencyScreen(),
      ),
    ],
  );
}

final GoRouter appRouter = createAppRouter(
  hasSession: () => Supabase.instance.client.auth.currentSession != null,
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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
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
              style: TextStyle(fontSize: 14, color: Colors.black54),
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
                onPressed: () => _placeEmergencyCall(context),
                icon: const Icon(Icons.phone),
                label: const Text('Llamar 911-PET'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeEmergencyCall(BuildContext context) async {
    final launched = await launchUrl(
      Uri(scheme: 'tel', path: '911'),
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir la línea de emergencias.'),
        ),
      );
    }
  }
}
