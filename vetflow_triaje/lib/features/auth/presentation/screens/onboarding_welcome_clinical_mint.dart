/// Pantalla de bienvenida/onboarding - Clinical Mint design.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vetflow_triaje/shared/presentation/theme/app_theme_clinical_mint.dart';

class OnboardingWelcomeClinicalMintScreen extends StatelessWidget {
  const OnboardingWelcomeClinicalMintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClinicalMintColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: ClinicalMintColors.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.pets,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'DOGO',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color:
                                            ClinicalMintColors.primaryContainer,
                                      ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.emergency,
                                  color: ClinicalMintColors.primary,
                                  size: 18,
                                ),
                              ],
                            ),
                            Text(
                              'VETERINARIA 24/7',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(letterSpacing: 1.6),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: ClinicalMintColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: ClinicalMintColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Red Activa',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Image.network(
                      'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?q=80&w=1200&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: ClinicalMintColors.surfaceContainerLow,
                        child: const Icon(
                          Icons.pets,
                          size: 48,
                          color: ClinicalMintColors.primaryContainer,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Orientación inicial para cuidar a tu mascota',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Registra los síntomas de tu mascota para orientar su nivel de atención y encontrar clínicas veterinarias.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Esta app no diagnostica ni reemplaza la valoración de un veterinario.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: ClinicalMintColors.primaryContainer,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => context.go('/login'),
                    icon: const Icon(Icons.login, size: 20),
                    label: Text(
                      'Iniciar Sesión',
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ClinicalMintColors.primary,
                      side: BorderSide.none,
                      backgroundColor:
                          ClinicalMintColors.surfaceContainerLowest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => context.go('/register'),
                    icon: const Icon(Icons.person_add, size: 20),
                    label: Text(
                      'Crear Cuenta / Registrarse',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: ClinicalMintColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    onPressed: () => context.go('/queue'),
                    icon: const Icon(
                      Icons.map,
                      color: ClinicalMintColors.primaryContainer,
                      size: 20,
                    ),
                    label: Text(
                      'Continuar como invitado / Ver clínicas cercanas',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: ClinicalMintColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: ClinicalMintColors.errorContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.call,
                          color: ClinicalMintColors.onErrorContainer,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¿Emergencia en curso?',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            Text(
                              'Línea directa veterinaria',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Ver clínicas cercanas',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: ClinicalMintColors.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: ClinicalMintColors.error,
                        size: 18,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
