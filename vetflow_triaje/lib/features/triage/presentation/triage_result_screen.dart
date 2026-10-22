/// Pantalla de resultado de triaje.
///
/// Muestra el nivel sugerido con color + ícono + texto (nunca solo color),
/// los motivos, y opciones para confirmar con veterinario o ver clínicas.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vetflow_triaje/features/triage/domain/model/triage_level.dart';
import 'package:vetflow_triaje/features/triage/domain/model/triage_result.dart';
import 'package:vetflow_triaje/shared/presentation/theme/app_theme.dart';
import 'package:vetflow_triaje/shared/presentation/widgets/shared_widgets.dart';

class TriageResultScreen extends StatelessWidget {
  const TriageResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulación de resultado del motor de triaje
    final suggestedLevel = TriageLevel.urgencia;
    final reasons = [
      'Vómito repetido: Urgencia',
      'Fiebre: Urgencia',
      'Respuesta "no sé" en descarte: mínimo Urgencia',
    ];

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Resultado del triaje'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Tarjeta del nivel sugerido
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: triageLevelColor(suggestedLevel.value.toString())
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: triageLevelColor(suggestedLevel.value.toString()),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                TriageLevelIndicator(
                  level: suggestedLevel.value.toString(),
                  size: 80,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nivel sugerido: ${suggestedLevel.label}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: triageLevelColor(suggestedLevel.value.toString()),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  suggestedLevel.message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: kTextSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Motivos
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Motivos de la evaluación',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                ...reasons.map(
                  (reason) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: kPrimaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            reason,
                            style: const TextStyle(
                              fontSize: 14,
                              color: kTextPrimaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 12),
                const Text(
                  'Aviso importante: este resultado es una sugerencia '
                  'automatizada y no sustituye la evaluación de un '
                  'veterinario colegiado.',
                  style: TextStyle(
                    fontSize: 12,
                    color: kTextSecondaryColor,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Botones de acción
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                PrimaryButton(
                  text: 'Confirmar con veterinario',
                  onPressed: () => context.go('/triage/vet-confirmation'),
                  icon: Icons.medical_information,
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  text: 'Ver clínicas cercanas y cola',
                  onPressed: () => context.go('/queue'),
                  icon: Icons.local_hospital,
                ),
                const SizedBox(height: 12),
                if (suggestedLevel == TriageLevel.emergencia)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      foregroundColor: kErrorColor,
                      side: const BorderSide(color: kErrorColor),
                    ),
                    onPressed: () => context.go('/emergency'),
                    icon: const Icon(Icons.phone),
                    label: const Text('Llamada de emergencia directa'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
