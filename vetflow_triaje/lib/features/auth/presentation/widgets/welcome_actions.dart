import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Botonera principal: Iniciar Sesión / Registrarse / Invitado.
class WelcomeActions extends StatelessWidget {
  const WelcomeActions({
    super.key,
    required this.onLogin,
    required this.onRegister,
    this.onRegisterPet,
    this.onGuest,
  });

  final VoidCallback onLogin;
  final VoidCallback onRegister;

  /// Acceso directo al registro de nueva mascota (enlaza el módulo MVP).
  final VoidCallback? onRegisterPet;

  final VoidCallback? onGuest;

  void _tap(VoidCallback action) {
    HapticFeedback.lightImpact();
    action();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final guestAction = onGuest;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: AppSpacing.touchTarget,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: AppColors.surfaceContainerLowest,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            onPressed: () => _tap(onLogin),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.login, size: 20),
                SizedBox(width: 8),
                Text('Iniciar Sesión'),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          height: AppSpacing.touchTarget,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.surfaceContainerLowest,
              foregroundColor: AppColors.primary,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            onPressed: () => _tap(onRegister),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add, size: 20),
                SizedBox(width: 8),
                Text('Crear Cuenta / Registrarse'),
              ],
            ),
          ),
        ),
        // Módulo de registro de mascota (pantalla de mvp 0000)
        if (onRegisterPet != null) ...[
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            height: AppSpacing.touchTarget,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.surfaceContainerLowest,
                foregroundColor: AppColors.primary,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              onPressed: () => _tap(onRegisterPet!),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, size: 20),
                  SizedBox(width: 8),
                  Text('Registrar Nueva Mascota'),
                ],
              ),
            ),
          ),
        ],
        if (guestAction != null) ...[
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
            onPressed: () => _tap(guestAction),
            icon: const Icon(
              Icons.map,
              size: 20,
              color: AppColors.primaryContainer,
            ),
            label: Text(
              'Continuar como invitado / Ver clínicas cercanas',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
