import 'package:flutter/material.dart';

import '../models/pet_model.dart';
import '../services/medical_records_service.dart';
import '../utils/constants.dart';
import 'pet_mascots.dart';

/// Hero Pet Card upgraded with Taste Skill (High-End Visual Design):
/// - Double-Bezel (Doppelrand) nested container architecture
/// - Fluid animated activity capsule switcher
/// - Button-in-button trailing circular icon pattern
/// - Verified care note with avatar
/// - High-contrast scheduling pill + tactile primary action
/// - Clean bottom pet switcher carousel with count badges & "+" add pet button
class AestheticCareCard extends StatefulWidget {
  final VoidCallback? onAddPet;
  final VoidCallback? onOpenRecords;
  final VoidCallback? onOpenVaccines;

  const AestheticCareCard({
    super.key,
    this.onAddPet,
    this.onOpenRecords,
    this.onOpenVaccines,
  });

  @override
  State<AestheticCareCard> createState() => _AestheticCareCardState();
}

class _AestheticCareCardState extends State<AestheticCareCard> {
  // Selected pet index: 0 = Milo (Dog), 1 = Lucky (Cat), 2 = Sunny (Bird)
  int _selectedPetIndex = 0;

  // Selected action tab index: 0 = Food, 1 = Play, 2 = Care, 3 = Health
  int _selectedActivityIndex = 3; // Defaults to Health/Vet record

  final List<Map<String, dynamic>> _pets = [
    {
      'name': 'Milo',
      'breed': 'Dachshund',
      'age': '3 Years Old',
      'tag': '#VT-1092',
      'note': 'Vaccines Up to Date \u2022 Central Vet Clinic Branch',
      'time': 'Sept 20, 10:30 AM',
      'action': 'Health Chart',
      'avatarColor': const Color(0xFFFED7AA),
      'species': 'dog',
    },
    {
      'name': 'Lucky',
      'breed': 'Ginger Tabby',
      'age': '2 Years Old',
      'tag': '#VT-2041',
      'note': "Lucky's diet chart is recorded on the cloud profile.",
      'time': 'Today, 12:00 PM',
      'action': 'Nutrition',
      'avatarColor': const Color(0xFFFDE68A),
      'species': 'cat',
    },
    {
      'name': 'Sunny',
      'breed': 'Yellow Canary',
      'age': '1 Year Old',
      'tag': '#VT-3302',
      'note': 'Annual wing & beak health checkup scheduled.',
      'time': 'Oct 04, 02:00 PM',
      'action': 'Check-in',
      'avatarColor': const Color(0xFFFEF08A),
      'species': 'bird',
    },
  ];

  final List<Map<String, dynamic>> _activities = [
    {'id': 'food', 'label': 'Food', 'icon': Icons.lunch_dining_outlined},
    {'id': 'play', 'label': 'Play', 'icon': Icons.sports_baseball_outlined},
    {'id': 'care', 'label': 'Care', 'icon': Icons.spa_outlined},
    {'id': 'health', 'label': 'Health', 'icon': Icons.medical_services_outlined},
  ];

  List<Map<String, dynamic>> _getCombinedPets(List<PetModel> registeredPets) {
    final List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(_pets);

    for (final pet in registeredPets) {
      final exists = list.any((item) => (item['name'] as String).toLowerCase() == pet.name.toLowerCase());
      if (!exists) {
        final ageYears = DateTime.now().year - pet.dateOfBirth.year;
        final ageText = ageYears <= 0 ? '< 1 Year Old' : '$ageYears Years Old';
        final sp = pet.species.toLowerCase();
        final Color col = sp.contains('cat')
            ? const Color(0xFFFDE68A)
            : sp.contains('bird')
                ? const Color(0xFFFEF08A)
                : const Color(0xFFFED7AA);

        list.add({
          'name': pet.name,
          'breed': pet.breed,
          'age': ageText,
          'tag': '#${pet.microchipId.replaceAll("CHIP-", "VT-")}',
          'note': 'Unified Cloud Record \u2022 Central VetCare Network',
          'time': 'Today, 03:00 PM',
          'action': 'Health Chart',
          'avatarColor': col,
          'species': sp.contains('cat') ? 'cat' : sp.contains('bird') ? 'bird' : 'dog',
        });
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<PetModel>>(
      valueListenable: MedicalRecordsService().petsNotifier,
      builder: (context, registeredPets, _) {
        final combinedPets = _getCombinedPets(registeredPets);
        if (_selectedPetIndex >= combinedPets.length) {
          _selectedPetIndex = 0;
        }
        final pet = combinedPets[_selectedPetIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      // DOUBLE-BEZEL OUTER SHELL
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(34),
          border: Border.all(color: AppColors.border, width: 1.2),
          boxShadow: AppShadows.aestheticCard,
        ),
        padding: const EdgeInsets.all(5),
        // INNER CORE
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(29),
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            children: [
              // 1. Pet Name Header & Eyebrow
              Text(
                pet['name'] as String,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.7,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${pet['breed']} \u2022 ${pet['age']}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: AppColors.lightPill,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border.withValues(alpha: 0.6), width: 1),
                    ),
                    child: Text(
                      pet['tag'] as String,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 2. Animated Mascot
              SizedBox(
                height: 175,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: KeyedSubtree(
                      key: ValueKey(pet['species']),
                      child: _buildMascot(pet['species'] as String),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 3. Activity Capsule Switcher
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.lightPill.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 1),
                ),
                child: Row(
                  children: List.generate(_activities.length, (index) {
                    final act = _activities[index];
                    final isSelected = _selectedActivityIndex == index;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedActivityIndex = index);
                          if (index == 3) {
                            widget.onOpenVaccines?.call();
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.surface : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                act['icon'] as IconData,
                                size: 20,
                                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                act['label'] as String,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 18),

              // 4. Care Note Micro-Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.lightPill.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.verified_user_outlined, size: 18, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        pet['note'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 5. Schedule Time Pill + Button-in-Button Primary Action
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.lightPill,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: AppColors.border.withValues(alpha: 0.6), width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule, size: 18, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              pet['time'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Button-in-Button Action
                  GestureDetector(
                    onTap: () {
                      widget.onOpenRecords?.call();
                    },
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.only(left: 20, right: 6),
                      decoration: BoxDecoration(
                        color: AppColors.darkPill,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            pet['action'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.1,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 6. Bottom Pet Switcher Bar & Add Pet Button
              Wrap(
                spacing: 12,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ...List.generate(combinedPets.length, (index) {
                    final item = combinedPets[index];
                    final isCurrent = _selectedPetIndex == index;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedPetIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCurrent ? AppColors.primary : Colors.transparent,
                            width: 2.2,
                          ),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: item['avatarColor'] as Color,
                              ),
                              child: Center(
                                child: Icon(
                                  item['species'] == 'dog'
                                      ? Icons.pets
                                      : item['species'] == 'cat'
                                          ? Icons.pets
                                          : Icons.cruelty_free,
                                  size: 20,
                                  color: AppColors.darkPill,
                                ),
                              ),
                            ),
                            if (index == 0)
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Text(
                                    '2',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),

                  // "+" Add Pet Button
                  GestureDetector(
                    onTap: widget.onAddPet,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.lightPill,
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                      child: const Center(
                        child: Icon(Icons.add, size: 20, color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildMascot(String species) {
    switch (species) {
      case 'cat':
        return const MascotCatWidget(size: 175);
      case 'bird':
        return const MascotBirdWidget(size: 175);
      case 'dog':
      default:
        return const MascotDogWidget(size: 175);
    }
  }
}