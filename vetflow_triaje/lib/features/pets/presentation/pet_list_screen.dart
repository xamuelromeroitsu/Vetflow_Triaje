/// Pantalla de lista/selección de mascotas.
///
/// Muestra las mascotas registradas del dueño y permite agregar una nueva.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vetflow_triaje/app/di/app_dependencies.dart';
import 'package:vetflow_triaje/features/pets/domain/model/pet.dart';
import 'package:vetflow_triaje/features/triage/application/use_case/create_visit.dart';
import 'package:vetflow_triaje/main.dart';
import 'package:vetflow_triaje/shared/presentation/theme/app_theme.dart';
import 'package:vetflow_triaje/shared/presentation/widgets/shared_widgets.dart';

class PetListScreen extends StatefulWidget {
  const PetListScreen({super.key});

  @override
  State<PetListScreen> createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  final List<Pet> _pets = [];
  bool _isLoading = false;
  String? _errorMessage;

  late final GetPetsByOwner _getPetsByOwner =
      main.appDependencies.petModule.getPetsByOwner;
  late final CreateVisit _createVisit =
      main.appDependencies.visitModule.createVisit;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    final account = main.appDependencies.authModule.authRepository.currentAccount;
    final ownerId = account?.uid;
    if (ownerId == null || ownerId.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _getPetsByOwner(ownerId: ownerId);
    final pets = result.valueOrNull;
    if (pets != null) {
      setState(() {
        _pets.clear();
        _pets.addAll(pets);
      });
    } else {
      setState(() {
        _errorMessage = result.errorOrNull?.message ??
            'No se pudieron cargar las mascotas';
      });
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Mis mascotas'),
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Banner de bienvenida
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hola, Juan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Selecciona una mascota para comenzar el triaje',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Lista de mascotas
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _pets.isEmpty
                    ? EmptyState(
                        icon: Icons.pets_outlined,
                        title: 'No tienes mascotas registradas',
                        subtitle:
                            'Registra a tu mascota para comenzar el triaje clínico.',
                        buttonText: 'Registrar mascota',
                        onButtonPressed: () => context.go('/pets/register'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _pets.length,
                        itemBuilder: (context, index) {
                          final pet = _pets[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 28,
                                backgroundColor:
                                    kPrimaryColor.withValues(alpha: 0.1),
                                child: Icon(
                                  pet.species == 'perro'
                                      ? Icons.pets
                                      : Icons.pets,
                                  color: kPrimaryColor,
                                ),
                              ),
                              title: Text(
                                pet.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                '${pet.species} • ${pet.breed} • ${pet.ageMonths} meses',
                                style: const TextStyle(color: kTextSecondaryColor),
                              ),
                              trailing: const Icon(
                                Icons.chevron_right,
                                color: kTextSecondaryColor,
                              ),
                          onTap: () async {
                            final result = await _createVisit(
                              petId: pet.id,
                            );
                            final visit = result.valueOrNull;
                            if (visit != null && mounted) {
                              context.go(
                                '/triage/symptoms?visitId=${visit.id}',
                              );
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'No se pudo iniciar el triaje',
                                  ),
                                ),
                              );
                            }
                          },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        onPressed: () => context.go('/pets/register'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
