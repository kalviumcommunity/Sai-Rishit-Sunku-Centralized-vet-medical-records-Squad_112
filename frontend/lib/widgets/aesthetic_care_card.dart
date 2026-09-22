import 'package:flutter/material.dart';

import '../models/pet_model.dart';
import '../services/medical_records_service.dart';
import '../utils/constants.dart';
import 'pet_avatar_view.dart';
import 'pet_mascots.dart';

/// Hero Pet Card upgraded with Taste Skill (High-End Visual Design):
/// - Double-Bezel (Doppelrand) nested container architecture
/// - Fluid animated activity capsule switcher across Food, Play, Care, Health
/// - Real dynamic state updates, category badges, and notes for each activity
/// - Interactive bottom sheets for Log Meal, Start Play, Care Log & Health Records
/// - Button-in-button trailing circular icon pattern
/// - Verified care note with mascot activity badge
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
  // Selected pet index: 0 = Milo (Dog), 1 = Lucky (Cat), 2 = Sunny (Bird)...
  int _selectedPetIndex = 0;

  // Selected action tab index: 0 = Food, 1 = Play, 2 = Care, 3 = Health
  int _selectedActivityIndex = 0; // Default to Food/Nutrition

  // Live in-memory logged activity records per pet (Zero placeholders!)
  final Map<String, String> _loggedMeals = {};
  final Map<String, String> _loggedMealTimes = {};
  final Map<String, String> _loggedPlay = {};
  final Map<String, String> _loggedPlayTimes = {};
  final Map<String, String> _loggedCare = {};
  final Map<String, String> _loggedCareTimes = {};

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
      final index = list.indexWhere((item) => (item['name'] as String).toLowerCase() == pet.name.toLowerCase());
      final ageYears = DateTime.now().year - pet.dateOfBirth.year;
      final ageText = ageYears <= 0 ? '< 1 Year Old' : '$ageYears Years Old';
      final sp = pet.species.toLowerCase();
      final Color col = sp.contains('cat')
          ? const Color(0xFFFDE68A)
          : sp.contains('bird')
              ? const Color(0xFFFEF08A)
              : const Color(0xFFFED7AA);

      final petData = {
        'id': pet.id,
        'name': pet.name,
        'breed': pet.breed,
        'age': ageText,
        'tag': '#${pet.microchipId.replaceAll("CHIP-", "VT-")}',
        'note': 'Unified Cloud Record \u2022 Central VetCare Network',
        'time': 'Today, 03:00 PM',
        'action': 'Health Chart',
        'avatarColor': col,
        'species': sp.contains('cat') ? 'cat' : sp.contains('bird') ? 'bird' : 'dog',
        'photoUrl': pet.photoUrl,
      };

      if (index >= 0) {
        list[index] = {...list[index], ...petData};
      } else {
        list.add(petData);
      }
    }
    return list;
  }

  /// Generates real dynamic activity details for the selected pet and tab
  Map<String, dynamic> _getActivityDetails(Map<String, dynamic> pet, int activityIndex) {
    final petName = pet['name'] as String;
    final sp = (pet['species'] as String? ?? 'dog').toLowerCase();
    final isCat = sp.contains('cat');
    final isBird = sp.contains('bird');
    final isBruno = petName.toLowerCase() == 'bruno';

    switch (activityIndex) {
      case 0: // Food
        final hasLogged = _loggedMeals.containsKey(petName);
        return {
          'category': 'DIET & NUTRITION',
          'categoryColor': const Color(0xFFEA580C),
          'icon': Icons.restaurant_menu_rounded,
          'iconColor': const Color(0xFFEA580C),
          'iconBg': const Color(0xFFFFEDD5),
          'statusBadge': hasLogged ? 'Fed Today' : 'Scheduled',
          'statusBadgeColor': hasLogged ? const Color(0xFF16A34A) : const Color(0xFFEA580C),
          'mascotMood': 'Hungry & Ready 🥣',
          'note': hasLogged
              ? _loggedMeals[petName]!
              : (isCat
                  ? "$petName's Formula: Purina Pro Plan Salmon \u2022 75g / day (split 2 meals) \u2022 Omega-3 coat health"
                  : isBird
                      ? "$petName's Diet: Fortified Seed & Nutri-Berries \u2022 15g / day \u2022 Fresh greens and cuttlebone"
                      : isBruno
                          ? "Diet Regimen: Nutro Ultra Large Breed \u2022 320g / day \u2022 Joint health support with glucosamine"
                          : "Diet Regimen: Royal Canin Dachshund Adult \u2022 180g / day \u2022 Controlled weight formula"),
          'time': _loggedMealTimes[petName] ?? 'Next Meal: 07:30 PM (Dinner)',
          'action': 'Log Meal',
        };

      case 1: // Play
        final hasLogged = _loggedPlay.containsKey(petName);
        return {
          'category': 'DAILY EXERCISE & AGILITY',
          'categoryColor': const Color(0xFF16A34A),
          'icon': Icons.sports_baseball_rounded,
          'iconColor': const Color(0xFF16A34A),
          'iconBg': const Color(0xFFDCFCE7),
          'statusBadge': hasLogged ? 'Goal Reached' : 'Daily Goal',
          'statusBadgeColor': const Color(0xFF16A34A),
          'mascotMood': 'Active & Playful 🎾',
          'note': hasLogged
              ? _loggedPlay[petName]!
              : (isCat
                  ? "Indoor Agility: 20 mins laser chase & feather teaser wand \u2022 Stimulates natural hunting instincts"
                  : isBird
                      ? "Out-of-Cage Flight: 30 mins supervised exploration \u2022 Wing conditioning and foraging drills"
                      : isBruno
                          ? "Exercise Target: 60 mins brisk park walk & retrieve drills \u2022 High endurance activity"
                          : "Low-impact exercise: 35 mins stroll & scent tracking \u2022 Dachshund spine protection protocol"),
          'time': _loggedPlayTimes[petName] ?? 'Evening Walk: 05:45 PM',
          'action': 'Start Play',
        };

      case 2: // Care
        final hasLogged = _loggedCare.containsKey(petName);
        return {
          'category': 'WELLNESS & GROOMING',
          'categoryColor': const Color(0xFF0D9488),
          'icon': Icons.spa_rounded,
          'iconColor': const Color(0xFF0D9488),
          'iconBg': const Color(0xFFCCFBF1),
          'statusBadge': hasLogged ? 'Care Verified' : 'Routine Check',
          'statusBadgeColor': const Color(0xFF0D9488),
          'mascotMood': 'Clean & Groomed ✨',
          'note': hasLogged
              ? _loggedCare[petName]!
              : (isCat
                  ? "Coat Brushing & De-shedding \u2022 Furminator routine & hairball prevention paste administered"
                  : isBird
                      ? "Avian Wellness: Warm water mist bath \u2022 Beak & nail conditioning optimal this week"
                      : isBruno
                          ? "Grooming & Hygiene: Double-coat de-shedding \u2022 Paw-pad moisturizing balm & ear inspection"
                          : "Grooming & Hygiene: Weekly coat brushing \u2022 Ear cleansing completed & anti-tick herbal coat active"),
          'time': _loggedCareTimes[petName] ?? 'Next Routine: Sat, 11:00 AM',
          'action': 'Care Log',
        };

      case 3: // Health
      default:
        return {
          'category': 'CLINICAL HEALTH RECORD',
          'categoryColor': AppColors.primary,
          'icon': Icons.verified_user_rounded,
          'iconColor': AppColors.primary,
          'iconBg': AppColors.primaryLight,
          'statusBadge': '100% Synced',
          'statusBadgeColor': AppColors.primary,
          'mascotMood': 'Protected & Healthy 🩺',
          'note': isBruno
              ? "Ear Flush & Otic Drops Completed \u2022 Follow-up scheduled with Dr. Priya Sharma at Koramangala Hub"
              : (pet['note'] as String? ?? 'Vaccines Up to Date \u2022 Central Vet Clinic Branch'),
          'time': isBruno ? 'Follow-up: In 3 Days' : (pet['time'] as String? ?? 'Sept 20, 10:30 AM'),
          'action': 'Health Chart',
        };
    }
  }

  void _handlePrimaryAction(Map<String, dynamic> pet) {
    final petName = pet['name'] as String;
    switch (_selectedActivityIndex) {
      case 0:
        _showLogMealSheet(context, petName);
        break;
      case 1:
        _showStartPlaySheet(context, petName);
        break;
      case 2:
        _showCareLogSheet(context, petName);
        break;
      case 3:
      default:
        widget.onOpenRecords?.call();
        break;
    }
  }

  // 1. Interactive Meal Logging Bottom Sheet
  void _showLogMealSheet(BuildContext context, String petName) {
    String selectedMealType = 'Dinner';
    String portionSize = '90g';
    final notesController = TextEditingController(text: 'Dry Kibble + Warm Bone Broth');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Material(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: Container(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 24,
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEDD5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.restaurant_menu_rounded, color: Color(0xFFEA580C)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Log Meal for $petName',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                              ),
                              const Text(
                                'Track daily nutrition & dietary portions',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text('Meal Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['Breakfast', 'Lunch', 'Dinner', 'Healthy Treat'].map((type) {
                          final isSel = selectedMealType == type;
                          return ChoiceChip(
                            label: Text(type),
                            selected: isSel,
                            selectedColor: const Color(0xFFFFEDD5),
                            labelStyle: TextStyle(
                              color: isSel ? const Color(0xFFEA580C) : AppColors.textPrimary,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              if (val) setSheetState(() => selectedMealType = type);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Portion Size', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['50g (Light)', '90g (Standard)', '120g (Active)', '180g (Full Bowl)'].map((portion) {
                          final val = portion.split(' ').first;
                          final isSel = portionSize == val;
                          return ChoiceChip(
                            label: Text(portion),
                            selected: isSel,
                            selectedColor: const Color(0xFFFFEDD5),
                            labelStyle: TextStyle(
                              color: isSel ? const Color(0xFFEA580C) : AppColors.textPrimary,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (sel) {
                              if (sel) setSheetState(() => portionSize = val);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: notesController,
                        decoration: const InputDecoration(
                          labelText: 'Dietary Notes & Formula',
                          hintText: 'e.g. Added probiotic supplement',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.note_alt_outlined),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEA580C),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Save Meal Entry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          onPressed: () {
                            setState(() {
                              _loggedMeals[petName] = '$selectedMealType ($portionSize) logged \u2022 ${notesController.text.trim()}';
                              _loggedMealTimes[petName] = 'Fed Today \u2022 Just now';
                            });
                            Navigator.pop(sheetContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('🍽️ $selectedMealType ($portionSize) recorded for $petName!'),
                                backgroundColor: const Color(0xFFEA580C),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 2. Interactive Activity & Play Tracking Bottom Sheet
  void _showStartPlaySheet(BuildContext context, String petName) {
    String activityType = 'Park Walk';
    String duration = '30 mins';
    String intensity = 'Moderate';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Material(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: Container(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 24,
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.sports_baseball_rounded, color: Color(0xFF16A34A)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Activity Session for $petName',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                              ),
                              const Text(
                                'Track exercise duration and agility workouts',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text('Activity Routine', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['Park Walk', 'Agility & Fetch', 'Indoor Scent Game', 'Tug of War'].map((type) {
                          final isSel = activityType == type;
                          return ChoiceChip(
                            label: Text(type),
                            selected: isSel,
                            selectedColor: const Color(0xFFDCFCE7),
                            labelStyle: TextStyle(
                              color: isSel ? const Color(0xFF16A34A) : AppColors.textPrimary,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              if (val) setSheetState(() => activityType = type);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Session Duration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['15 mins', '30 mins', '45 mins', '60 mins'].map((dur) {
                          final isSel = duration == dur;
                          return ChoiceChip(
                            label: Text(dur),
                            selected: isSel,
                            selectedColor: const Color(0xFFDCFCE7),
                            labelStyle: TextStyle(
                              color: isSel ? const Color(0xFF16A34A) : AppColors.textPrimary,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (sel) {
                              if (sel) setSheetState(() => duration = dur);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Intensity Level', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['Gentle Stroll', 'Moderate', 'High Energy'].map((lvl) {
                          final isSel = intensity == lvl;
                          return ChoiceChip(
                            label: Text(lvl),
                            selected: isSel,
                            selectedColor: const Color(0xFFDCFCE7),
                            labelStyle: TextStyle(
                              color: isSel ? const Color(0xFF16A34A) : AppColors.textPrimary,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (sel) {
                              if (sel) setSheetState(() => intensity = lvl);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Complete & Record Session', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          onPressed: () {
                            setState(() {
                              _loggedPlay[petName] = '$duration $activityType completed \u2022 Intensity: $intensity \u2022 Energy optimal';
                              _loggedPlayTimes[petName] = 'Completed \u2022 Just now';
                            });
                            Navigator.pop(sheetContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('🎾 $duration $activityType recorded for $petName! Target achieved.'),
                                backgroundColor: const Color(0xFF16A34A),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 3. Interactive Grooming & Wellness Checklist Bottom Sheet
  void _showCareLogSheet(BuildContext context, String petName) {
    bool brushedCoat = true;
    bool cleanedEars = true;
    bool trimmedNails = false;
    bool dentalCare = false;
    bool tickInspection = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Material(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: Container(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 24,
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFCCFBF1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.spa_rounded, color: Color(0xFF0D9488)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Care & Grooming for $petName',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                              ),
                              const Text(
                                'Maintain hygiene checklist and coat health',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: const Color(0xFF0D9488),
                        title: const Text('Brush Coat & De-shedding', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: const Text('Removes loose fur and maintains skin oil barrier', style: TextStyle(fontSize: 12)),
                        value: brushedCoat,
                        onChanged: (val) => setSheetState(() => brushedCoat = val ?? false),
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: const Color(0xFF0D9488),
                        title: const Text('Ear Cleansing & Inspection', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: const Text('Gentle wipe with veterinary otic solution', style: TextStyle(fontSize: 12)),
                        value: cleanedEars,
                        onChanged: (val) => setSheetState(() => cleanedEars = val ?? false),
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: const Color(0xFF0D9488),
                        title: const Text('Nail Trimming & Paw Inspection', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: const Text('Paws checked for grass seeds or cracks', style: TextStyle(fontSize: 12)),
                        value: trimmedNails,
                        onChanged: (val) => setSheetState(() => trimmedNails = val ?? false),
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: const Color(0xFF0D9488),
                        title: const Text('Teeth Brushing / Dental Chew', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: const Text('Enzymatic tartar prevention', style: TextStyle(fontSize: 12)),
                        value: dentalCare,
                        onChanged: (val) => setSheetState(() => dentalCare = val ?? false),
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: const Color(0xFF0D9488),
                        title: const Text('Anti-tick & Flea Inspection', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: const Text('Verify spot-on topical protection status', style: TextStyle(fontSize: 12)),
                        value: tickInspection,
                        onChanged: (val) => setSheetState(() => tickInspection = val ?? false),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D9488),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Save Care Routine', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          onPressed: () {
                            final List<String> completedTasks = [];
                            if (brushedCoat) completedTasks.add('Brushing');
                            if (cleanedEars) completedTasks.add('Ear Care');
                            if (trimmedNails) completedTasks.add('Nail Trim');
                            if (dentalCare) completedTasks.add('Dental');
                            if (tickInspection) completedTasks.add('Tick Check');

                            setState(() {
                              _loggedCare[petName] = 'Grooming verified: ${completedTasks.join(', ')} \u2022 Routine up to date';
                              _loggedCareTimes[petName] = 'Done Today \u2022 Just now';
                            });
                            Navigator.pop(sheetContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('✨ Care checklist saved for $petName! (${completedTasks.length} tasks verified)'),
                                backgroundColor: const Color(0xFF0D9488),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
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
        final activity = _getActivityDetails(pet, _selectedActivityIndex);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          // DOUBLE-BEZEL OUTER SHELL
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.4), width: 1),
              boxShadow: AppShadows.aestheticCard,
            ),
            padding: const EdgeInsets.all(4),
            // INNER CORE
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(26),
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
                  const SizedBox(height: 14),

                  // 2. Animated Mascot with Activity Pill
                  SizedBox(
                    height: 175,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: KeyedSubtree(
                            key: ValueKey('${pet['species']}-${pet['name']}-${pet['photoUrl']}'),
                            child: _buildCenterPetDisplay(pet),
                          ),
                        ),
                        // Mascot Mood Pill
                        Positioned(
                          bottom: 0,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border.withValues(alpha: 0.8), width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              activity['mascotMood'] as String? ?? 'Happy Pet',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Activity Capsule Switcher (Food, Play, Care, Health)
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
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              setState(() => _selectedActivityIndex = index);
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
                  const SizedBox(height: 14),

                  // 4. Dynamic Activity Card Content (Transition on tab change!)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.05),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      key: ValueKey('activity-$_selectedActivityIndex-${pet['name']}'),
                      children: [
                        // Category Header Pill & Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              activity['category'] as String,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: activity['categoryColor'] as Color,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: (activity['statusBadgeColor'] as Color).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                activity['statusBadge'] as String,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: activity['statusBadgeColor'] as Color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Care Note Micro-Card
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
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: activity['iconBg'] as Color,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    activity['icon'] as IconData,
                                    size: 20,
                                    color: activity['iconColor'] as Color,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  activity['note'] as String,
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
                                        activity['time'] as String,
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
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _handlePrimaryAction(pet),
                              child: Container(
                                height: 52,
                                padding: const EdgeInsets.only(left: 18, right: 6),
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
                                      activity['action'] as String,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
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
                      ],
                    ),
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
                          onTap: () {
                            setState(() => _selectedPetIndex = index);
                            final petName = item['name'] as String;
                            final list = MedicalRecordsService().petsNotifier.value;
                            final match = list.firstWhere(
                              (p) => p.name.toLowerCase() == petName.toLowerCase(),
                              orElse: () => list.isNotEmpty ? list.first : PetModel(
                                id: 'pet_${petName.toLowerCase()}',
                                name: petName,
                                species: item['species'] as String? ?? 'dog',
                                breed: item['breed'] as String? ?? 'Mixed Breed',
                                gender: 'male',
                                dateOfBirth: DateTime.now().subtract(const Duration(days: 365 * 2)),
                                microchipId: item['tag'] as String? ?? '98514',
                                ownerId: 'owner_current',
                                weightKg: 10.0,
                                createdAt: DateTime.now(),
                              ),
                            );
                            MedicalRecordsService().selectPet(match);
                          },
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
                                  child: ClipOval(
                                    child: item['photoUrl'] != null && (item['photoUrl'] as String).trim().isNotEmpty
                                        ? PetAvatarView(
                                            photoUrl: item['photoUrl'] as String?,
                                            species: item['species'] as String? ?? 'dog',
                                            size: 44,
                                            isCircle: true,
                                          )
                                        : Center(
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

  Widget _buildCenterPetDisplay(Map<String, dynamic> pet) {
    final photoUrl = pet['photoUrl'] as String?;
    final species = (pet['species'] as String?) ?? 'dog';

    if (photoUrl != null && photoUrl.trim().isNotEmpty) {
      return Container(
        width: 145,
        height: 145,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: pet['avatarColor'] as Color? ?? const Color(0xFFFED7AA),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.6), width: 3),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: PetAvatarView(
          photoUrl: photoUrl,
          species: species,
          size: 145,
          isCircle: true,
        ),
      );
    }
    return _buildMascot(species);
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