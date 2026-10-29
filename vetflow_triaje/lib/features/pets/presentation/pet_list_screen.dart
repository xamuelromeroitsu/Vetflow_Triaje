/// Pantalla de lista/selección de mascotas.
///
/// Muestra las mascotas registradas del dueño y permite agregar una nueva.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vetflow_triaje/features/owners/application/use_case/get_owner_by_id.dart';
import 'package:vetflow_triaje/features/pets/application/use_case/get_pets_by_owner.dart';
import 'package:vetflow_triaje/features/pets/domain/model/pet.dart';
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
  String _greetingName = 'Usuario';
  String? _startingPetId;

  late final GetOwnerById _getOwnerById =
      appDependencies.ownerModule.getOwnerById;
  late final GetPetsByOwner _getPetsByOwner =
      appDependencies.petModule.getPetsByOwner;
  late final CreateVisit _createVisit =
      appDependencies.visitModule.createVisit;

  @override
  void initState() {
    super.initState();
    _loadGreetingName();
    _loadPets();
  }

  Future<void> _loadGreetingName() async {
    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata;
    final metadataName = _firstNonEmpty([
      metadata?['full_name'],
      metadata?['name'],
    ]);

    if (metadataName != null) {
      if (mounted) setState(() => _greetingName = metadataName);
      return;
    }

    if (user == null) return;

    final result = await _getOwnerById(id: user.id);
    if (!mounted) return;

    final ownerName = result.valueOrNull?.name.trim();
    if (ownerName != null && ownerName.isNotEmpty) {
      setState(() => _greetingName = ownerName);
    }
  }

  String? _firstNonEmpty(List<Object?> values) {
    for (final value in values) {
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  Future<void> _loadPets() async {
    final account = appDependencies.authModule.authRepository.currentAccount;
    final ownerId = account?.uid;
    if (ownerId == null || ownerId.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _getPetsByOwner(ownerId: ownerId);
    if (!mounted) return;

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

  Future<void> _startTriage(Pet pet) async {
    setState(() {
      _errorMessage = null;
      _startingPetId = pet.id;
    });

    try {
      final result = await _createVisit(petId: pet.id);
      if (!mounted) return;

      final visit = result.valueOrNull;
      if (visit == null || visit.id.isEmpty) {
        final error = result.errorOrNull;
        final detail = error != null && error.fields.isNotEmpty
            ? error.fields.first.message
            : null;
        final message = error?.message ??
            'No se pudo crear la visita para ${pet.name}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(detail == null ? message : '$message: $detail'),
          ),
        );
        return;
      }

      context.go(
        Uri(
          path: '/triage/symptoms',
          queryParameters: {'visitId': visit.id},
        ).toString(),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo iniciar el triaje: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _startingPetId = null);
      }
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
                Text(
                  'Hola, $_greetingName',
                  style: const TextStyle(
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
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: kErrorColor),
              ),
            ),

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
                              trailing: _startingPetId == pet.id
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.chevron_right,
                                      color: kTextSecondaryColor,
                                    ),
                              onTap: _startingPetId == null
                                  ? () => _startTriage(pet)
                                  : null,
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
