/// Pantalla de confirmación del veterinario.
///
/// El veterinario confirma o corrige el nivel sugerido.
/// Se guardan `suggested` y `confirmed` por separado.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vetflow_triaje/features/triage/domain/model/triage_level.dart';
import 'package:vetflow_triaje/features/triage/domain/model/triage_result.dart';
import 'package:vetflow_triaje/shared/presentation/theme/app_theme.dart';
import 'package:vetflow_triaje/shared/presentation/widgets/shared_widgets.dart';

class VetConfirmationScreen extends StatefulWidget {
  const VetConfirmationScreen({super.key});

  @override
  State<VetConfirmationScreen> createState() => _VetConfirmationScreenState();
}

class _VetConfirmationScreenState extends State<VetConfirmationScreen> {
  // Nivel sugerido por el motor (simulado)
  final TriageLevel _suggested = TriageLevel.urgencia;

  // Nivel confirmado por el veterinario
  TriageLevel? _confirmed;

  final List<String> _reasons = [
    'Vómito repetido: Urgencia',
    'Fiebre: Urgencia',
  ];

  bool _isLoading = false;

  Future<void> _confirm() async {
    if (_confirmed == null) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      // Aquí se guardará suggested y confirmed por separado en Firestore
      // a través del caso de uso ConfirmTriage.
      context.go('/queue');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Confirmación veterinaria'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Confirmar nivel de triaje',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: kTextPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'El veterinario revisa y confirma o corrige el nivel sugerido.',
              style: TextStyle(
                fontSize: 14,
                color: kTextSecondaryColor,
              ),
            ),
            const SizedBox(height: 24),

            // Nivel sugerido (sistema)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kSurfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: kTextSecondaryColor),
                      SizedBox(width: 8),
                      Text(
                        'Nivel sugerido (sistema)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: kTextSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      TriageLevelIndicator(
                        level: _suggested.value.toString(),
                        size: 56,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_suggested.label}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: triageLevelColor(
                                  _suggested.value.toString(),
                                ),
                              ),
                            ),
                            Text(
                              _suggested.message,
                              style: const TextStyle(
                                fontSize: 12,
                                color: kTextSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Motivos del sistema:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: kTextSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._reasons.map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• $r',
                        style: const TextStyle(
                          fontSize: 12,
                          color: kTextSecondaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Nivel confirmado (veterinario)
            const Text(
              'Nivel confirmado (veterinario)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: kTextPrimaryColor,
              ),
            ),
            const SizedBox(height: 12),
            ...TriageLevel.values.map((level) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => setState(() => _confirmed = level),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _confirmed == level
                          ? triageLevelColor(level.value.toString())
                              .withValues(alpha: 0.15)
                          : kSurfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _confirmed == level
                            ? triageLevelColor(level.value.toString())
                            : const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _confirmed == level
                                ? triageLevelColor(
                                    level.value.toString(),
                                  )
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: triageLevelColor(
                                level.value.toString(),
                              ),
                            ),
                          ),
                          child: _confirmed == level
                              ? const Icon(
                                  Icons.check,
                                  size: 12,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    triageLevelIcon(level.value.toString()),
                                    size: 16,
                                    color: triageLevelColor(
                                      level.value.toString(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    level.label,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: triageLevelColor(
                                        level.value.toString(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                level.message,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: kTextSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Advertencia si el nivel se baja (no debería pasar por reglas)
            if (_confirmed != null && _confirmed!.value < _suggested.value)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kErrorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kErrorColor),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.error, color: kErrorColor, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Advertencia: el nivel confirmado es inferior al '
                        'sugerido. Esto no se recomienda por seguridad.',
                        style: TextStyle(
                          fontSize: 12,
                          color: kErrorColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),

            PrimaryButton(
              text: 'Guardar confirmación',
              onPressed: _confirmed == null || _isLoading ? null : _confirm,
            ),
            const SizedBox(height: 16),
            SecondaryButton(
              text: 'Saltar confirmación',
              onPressed: _isLoading ? null : () => context.go('/queue'),
            ),
          ],
        ),
      ),
    );
  }
}
