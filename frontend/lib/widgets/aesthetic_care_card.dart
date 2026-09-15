import 'package:flutter/material.dart';

import '../utils/constants.dart';
import 'pet_mascots.dart';

/// Hero Pet Card matching the reference mockup:
/// - 32px rounded white card with soft ambient drop-shadow
/// - Whimsical animated vector mascot (Dog, Cat, Bird)
/// - 4-item Activity Category Bar (Food, Play, Care, Health)
/// - Contextual owner note with circular avatar
/// - Date/time scheduling pill + black action button
/// - Bottom pet switcher carousel with count badges & "+" add pet button
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
      'breed': 'Golden Retriever',
      'age': '3 Years Old',
      'tag': '#VT-1092',
      'note': 'Vaccines Up to Date • Central Vet Clinic Branch',
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
      'action': 'Feed',
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
    {'id': 'care', 'label': 'Care', 'icon': Icons.soup_kitchen_outlined},
    {'id': 'health', 'label': 'Health', 'icon': Icons.medical_services_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final pet = _pets[_selectedPetIndex];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.heroCardRadius,
        border: Border.all(color: AppColors.aestheticBorder, width: 1.2),
        boxShadow: AppShadows.aestheticCard,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          children: [
            // 1. Pet Name Header
            Text(
              pet['name'] as String,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${pet['breed']} • ${pet['age']}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.lightPill,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    pet['tag'] as String,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2. Animated Whimsical Pet Mascot
            SizedBox(
              height: 170,
              child: Center(
                child: _buildMascot(pet['species'] as String),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Segmented Activity Category Bar (Food, Play, Care, Health)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_activities.length, (index) {
                final act = _activities[index];
                final isSelected = _selectedActivityIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedActivityIndex = index);
                    if (index == 3) {
                      widget.onOpenRecords?.call();
                    }
                  },
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.darkPill : AppColors.lightPill,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.darkPill.withValues(alpha: 0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          act['icon'] as IconData,
                          size: 24,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        act['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // 4. Contextual Care Note Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.lightPill.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(Icons.person, size: 18, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      pet['note'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 5. Schedule Time Pill + Black Action Button
            Row(
              children: [
                // Date & Time Pill
                Expanded(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.lightPill,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule, size: 17, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          pet['time'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Primary Action Button (e.g. Health Chart / Check-in)
                ElevatedButton(
                  onPressed: () {
                    widget.onOpenRecords?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkPill,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(100, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: Text(
                    pet['action'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 6. Bottom Pet Switcher Bar & Add Pet Button
            Row(
              children: [
                Row(
                  children: List.generate(_pets.length, (index) {
                    final item = _pets[index];
                    final isCurrent = _selectedPetIndex == index;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedPetIndex = index),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: item['avatarColor'] as Color,
                                border: Border.all(
                                  color: isCurrent ? AppColors.darkPill : Colors.transparent,
                                  width: 2.2,
                                ),
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
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: AppColors.darkPill,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Text(
                                    '2',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),

                // "+" Add Pet Button
                GestureDetector(
                  onTap: widget.onAddPet,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.aestheticBorder, width: 1.5),
                    ),
                    child: const Icon(Icons.add, size: 20, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMascot(String species) {
    switch (species) {
      case 'cat':
        return const MascotCatWidget(size: 170);
      case 'bird':
        return const MascotBirdWidget(size: 170);
      case 'dog':
      default:
        return const MascotDogWidget(size: 170);
    }
  }
}
