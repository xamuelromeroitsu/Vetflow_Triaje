import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/brand_header.dart';
import '../widgets/carousel_dots.dart';
import '../widgets/emergency_call_card.dart';
import '../widgets/hero_banner.dart';
import '../widgets/welcome_actions.dart';

class DogoWelcomeScreen extends StatefulWidget {
  const DogoWelcomeScreen({super.key});

  @override
  State<DogoWelcomeScreen> createState() => _DogoWelcomeScreenState();
}

class _DogoWelcomeScreenState extends State<DogoWelcomeScreen> {
  static const _headlines = [
    'Atención médica y triaje rápido para tu mascota',
    'Orientación clara para cuidar mejor',
    'Conecta con clínicas veterinarias',
  ];

  static const _descriptions = [
    'Evaluación de síntomas en tiempo real con IA, asignación de urgencias '
        'y conexión directa con clínicas veterinarias 24/7.',
    'Registra los síntomas de tu mascota y recibe una orientación inicial '
        'para decidir los siguientes pasos.',
    'Consulta clínicas cercanas y organiza la información necesaria para '
        'facilitar la atención de tu mascota.',
  ];

  int _dotIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            0,
            AppSpacing.gutter,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const BrandHeader(),
              const HeroBanner(),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _headlines[_dotIndex],
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _descriptions[_dotIndex],
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              CarouselDots(
                count: _headlines.length,
                activeIndex: _dotIndex,
                onDotTapped: (index) => setState(() => _dotIndex = index),
              ),
              const SizedBox(height: AppSpacing.lg),
              WelcomeActions(
                onLogin: () => context.go('/login'),
                onRegister: () => context.go('/register'),
                onRegisterPet: () => context.go('/pets/register'),
              ),
              const SizedBox(height: AppSpacing.md),
              _AccesoRapidoMvp(onNavigate: (ruta) => context.go(ruta)),
              const SizedBox(height: AppSpacing.md),
              EmergencyCallCard(onCall: () => context.go('/emergency')),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta de acceso rápido a los módulos del MVP (pantalla de mvp 0000).
///
/// Enlaza desde el inicio: triaje de emergencia, evaluación, cola en vivo
/// y registro de mascota, junto a los botones de login y registro de cuenta.
class _AccesoRapidoMvp extends StatelessWidget {
  const _AccesoRapidoMvp({required this.onNavigate});

  final void Function(String ruta) onNavigate;

  static const _accesos = <(IconData, String, String)>[
    (Icons.monitor_heart, 'Emergencia / Triaje', '/emergency'),
    (Icons.favorite_border, 'Ficha de Signos Vitales', '/triage/vitals'),
    (Icons.format_list_bulleted, 'Cola en Tiempo Real', '/queue'),
    (Icons.pets, 'Registro de Mascota', '/pets/register'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acceso rápido DOGO',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 3.2,
            children: [
              for (final (icono, texto, ruta) in _accesos)
                OutlinedButton.icon(
                  onPressed: () => onNavigate(ruta),
                  icon: Icon(icono, size: 18),
                  label: Text(
                    texto,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
