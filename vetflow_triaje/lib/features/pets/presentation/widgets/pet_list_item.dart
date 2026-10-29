import 'package:flutter/material.dart';
import 'package:vetflow_triaje/features/pets/domain/model/pet.dart';
import 'package:vetflow_triaje/shared/presentation/theme/app_theme.dart';

class PetListItem extends StatelessWidget {
  const PetListItem({
    required this.pet,
    required this.onTap,
    this.isBusy = false,
    this.isEnabled = true,
    super.key,
  });

  final Pet pet;
  final VoidCallback onTap;
  final bool isBusy;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: kPrimaryColor.withValues(alpha: 0.1),
          child: const Icon(Icons.pets, color: kPrimaryColor),
        ),
        title: Text(
          pet.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          '${pet.species} • ${pet.breed} • ${pet.ageMonths} meses',
          style: const TextStyle(color: kTextSecondaryColor),
        ),
        trailing: isBusy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.chevron_right, color: kTextSecondaryColor),
        onTap: isEnabled ? onTap : null,
      ),
    );
  }
}
