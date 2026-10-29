/// Pantalla de lista/selección de mascotas.
///
/// Muestra las mascotas registradas del dueño y permite agregar una nueva.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vetflow_triaje/features/pets/application/use_case/get_pets_by_owner.dart';
import 'package:vetflow_triaje/features/pets/domain/model/pet.dart';
import 'package:vetflow_triaje/features/pets/presentation/widgets/pet_list_item.dart';
import 'package:vetflow_triaje/features/triage/application/use_case/create_visit.dart';
import 'package:vetflow_triaje/main.dart';
import 'package:vetflow_triaje/shared/domain/result.dart';
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
  String? _startingVisitForPetId;

  late final GetPetsByOwner _getPetsByOwner =
      appDependencies.petModule.getPetsByOwner;
  late final CreateVisit _createVisit = appDependencies.visitModule.createVisit;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    final account = appDependencies.authModule.authRepository.currentAccount;
    final ownerId = account?.uid;
    if (ownerId == null || ownerId.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Inicia sesión para consultar tus mascotas.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _getPetsByOwner(ownerId: ownerId);
    final pets = result.valueOrNull;
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (pets != null) {
        _pets.clear();
        _pets.addAll(pets);
      } else {
        _errorMessage =
            result.errorOrNull?.message ?? 'No se pudieron cargar las mascotas';
      }
    });
  }

  Future<void> _startTriage(Pet pet) async {
    final account = appDependencies.authModule.authRepository.currentAccount;
    if (account == null || account.uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para iniciar el triaje.')),
      );
      return;
    }

    setState(() => _startingVisitForPetId = pet.id);
    try {
      final result = await _createVisit(petId: pet.id);
      if (!mounted) return;

      final visit = result.valueOrNull;
      if (visit == null || visit.id.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.errorOrNull?.message ??
                  'No se pudo iniciar el triaje. Intenta de nuevo.',
            ),
          ),
        );
        return;
      }

      final uri = Uri(
        path: '/triage/symptoms',
        queryParameters: {'visitId': visit.id},
      );
      context.go(uri.toString());
    } finally {
      if (mounted) setState(() => _startingVisitForPetId = null);
    }
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
                  'Mis mascotas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Selecciona una mascota para comenzar el triaje',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Lista de mascotas
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 40),
                          const SizedBox(height: 12),
                          Text(_errorMessage!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _loadPets,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  )
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
                      return PetListItem(
                        pet: pet,
                        isBusy: _startingVisitForPetId == pet.id,
                        isEnabled: _startingVisitForPetId == null,
                        onTap: () => _startTriage(pet),
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
