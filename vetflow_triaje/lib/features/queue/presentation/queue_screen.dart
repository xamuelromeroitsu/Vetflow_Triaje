/// Pantalla de cola de atención y clínicas cercanas.
///
/// Muestra los casos ordenados por prioridad de triaje, con asignación
/// de sala y veterinario, y opción de llamada de emergencia.
/// La cola se observa en tiempo real desde Supabase Realtime.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vetflow_triaje/features/queue/application/use_case/watch_queue.dart';
import 'package:vetflow_triaje/features/queue/domain/model/queue_entry.dart';
import 'package:vetflow_triaje/features/triage/domain/model/triage_level.dart';
import 'package:vetflow_triaje/main.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';
import 'package:vetflow_triaje/shared/presentation/theme/app_theme.dart';
import 'package:vetflow_triaje/shared/presentation/widgets/shared_widgets.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  late final WatchQueue _watchQueue = appDependencies.queueModule.watchQueue;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Result<List<QueueEntry>>>(
      stream: _watchQueue.call(),
      builder: (context, snapshot) {
        final queueResult = snapshot.data;
        final ordered = queueResult?.valueOrNull ?? <QueueEntry>[];

        return Scaffold(
          backgroundColor: kBackgroundColor,
          appBar: AppBar(
            title: const Text('Cola de atención'),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.call, color: kErrorColor),
                onPressed: () => context.go('/emergency'),
              ),
            ],
          ),
          body: Column(
            children: [
              // Estado de red
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.wifi, size: 16, color: kSuccessColor),
                        SizedBox(width: 6),
                        Text(
                          'Red Activa',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: kTextPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${ordered.where((e) => e.status == QueueStatus.pendiente).length} casos pendientes',
                      style: const TextStyle(
                        fontSize: 12,
                        color: kTextSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Clínicas cercanas (resumen)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
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
                        Icon(Icons.local_hospital, color: kPrimaryColor),
                        SizedBox(width: 8),
                        Text(
                          'Clínicas cercanas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: kTextPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ClinicChip(
                            name: 'VetCare Clínica',
                            distance: '1.2 km',
                            isOpen: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ClinicChip(
                            name: 'DOGO Veterinaria 24/7',
                            distance: '2.5 km',
                            isOpen: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Lista de cola
              Expanded(
                child: ordered.isEmpty
                    ? EmptyState(
                        icon: Icons.queue,
                        title: 'Cola vacía',
                        subtitle: 'No hay casos pendientes en este momento.',
                        buttonText: 'Nuevo triaje',
                        onButtonPressed: () => context.go('/pets'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: ordered.length,
                        itemBuilder: (context, index) {
                          final entry = ordered[index];
                          return _QueueEntryCard(
                            entry: entry,
                            position: entry.position ?? index + 1,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ClinicChip extends StatelessWidget {
  const _ClinicChip({
    required this.name,
    required this.distance,
    required this.isOpen,
  });

  final String name;
  final String distance;
  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isOpen ? kSuccessColor : kErrorColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kTextPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$distance • ${isOpen ? 'Abierto 24h' : 'Cerrado'}',
            style: const TextStyle(fontSize: 12, color: kTextSecondaryColor),
          ),
        ],
      ),
    );
  }
}

class _QueueEntryCard extends StatelessWidget {
  const _QueueEntryCard({required this.entry, required this.position});

  final QueueEntry entry;
  final int position;

  Color _statusColor(QueueStatus status) {
    switch (status) {
      case QueueStatus.pendiente:
        return kTextSecondaryColor;
      case QueueStatus.enAtencion:
        return kPrimaryColor;
      case QueueStatus.atendido:
        return kSuccessColor;
      case QueueStatus.cancelado:
        return kErrorColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: triageLevelColor(
            entry.triageLevel.name,
          ).withValues(alpha: 0.1),
          child: Text(
            position.toString(),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: triageLevelColor(entry.triageLevel.name),
              fontSize: 14,
            ),
          ),
        ),
        title: Text(
          'Mascota ${entry.petId.substring(0, 4).toUpperCase()}...',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: kTextPrimaryColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  triageLevelIcon(entry.triageLevel.name),
                  size: 14,
                  color: triageLevelColor(entry.triageLevel.name),
                ),
                const SizedBox(width: 6),
                Text(
                  entry.triageLevel.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: triageLevelColor(entry.triageLevel.name),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(entry.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    entry.status.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: _statusColor(entry.status),
                    ),
                  ),
                ),
              ],
            ),
            if (entry.assignedRoom != null)
              Text(
                'Sala: ${entry.assignedRoom} • Vet: ${entry.assignedVeterinarian ?? 'Asignando'}',
                style: const TextStyle(
                  fontSize: 12,
                  color: kTextSecondaryColor,
                ),
              ),
          ],
        ),
        trailing: entry.status == QueueStatus.pendiente
            ? const Icon(Icons.chevron_right, color: kTextSecondaryColor)
            : null,
        onTap: entry.status == QueueStatus.pendiente ? () {} : null,
      ),
    );
  }
}
