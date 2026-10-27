/// Pantalla de bienvenida / onboarding.
///
/// Coincide con el diseño de referencia: logo, estado "Red Activa",
/// hero con mascota, botones de Iniciar Sesión, Crear cuenta,
/// Continuar como invitado y llamada de emergencia.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vetflow_triaje/app/router/app_router.dart';
import 'package:vetflow_triaje/shared/presentation/theme/app_theme.dart';
import 'package:vetflow_triaje/shared/presentation/widgets/shared_widgets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DOGO *',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: kTextPrimaryColor,
                        ),
                      ),
                      const Text(
                        'VETERINARIA 24/7',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: kTextPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  const NetworkStatusBadge(isActive: true),
                ],
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: double.infinity,
                  height: 300,
                  color: const Color(0xFFE8F5E9),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Triaje Clínico IA',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: kTextPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Guardia Médica',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: kTextSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: kSuccessColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Cuidado compasivo con respuesta inmediata',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Atención médica y triaje rápido para tu mascota',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Evaluación de síntomas en tiempo real con IA, '
                'asignación de urgencias y conexión directa '
                'con clínicas veterinarias 24/7.',
                style: TextStyle(
                  fontSize: 14,
                  color: kTextSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 6,
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              PrimaryButton(
                text: 'Iniciar Sesión',
                onPressed: () => context.go('/login'),
                icon: Icons.login,
              ),
              const SizedBox(height: 16),
              SecondaryButton(
                text: 'Crear Cuenta / Registrarse',
                onPressed: () => context.go('/register'),
                icon: Icons.person_add,
              ),
              const SizedBox(height: 16),
              TextButtonLink(
                text: 'Continuar como invitado / Ver clínicas cercanas',
                onPressed: () => context.go('/pets'),
                icon: Icons.map_outlined,
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.phone, color: kErrorColor, size: 24),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            '¿Emergencia en curso?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Línea directa veterinaria',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            text: 'Llamar 911-PET',
                            onPressed: _callEmergency,
                            icon: Icons.phone,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _callEmergency() async {
    const url = 'tel:911-PET';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}
