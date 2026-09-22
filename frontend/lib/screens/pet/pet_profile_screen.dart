import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/medical_records_service.dart';
import '../../utils/constants.dart';
import '../../widgets/pet_avatar_view.dart';
import '../../widgets/pet_mascots.dart';
import '../main_navigation_shell.dart';

/// DAY 7 & DAY 8 — Pet Profile & Dedicated Vaccinations Screen
///
/// Features:
/// - Hero White Card:
///   - Circular avatar with an orange ring border (AppColors.primary)
///   - Bold pet name, breed & microchip ID (e.g. "Golden Retriever \u00B7 Microchip #98514")
///   - Three info chips: Age / Weight / Gender
///   - Cross-branch banner: "Unified Cloud Record \u2014 Synced across [N] metro branches"
///     where N is the computed count of distinct clinic branches with records for this pet.
/// - Segmented Tab Controller:
///   - [ Medical History ] (Day 7)
///   - [ Vaccinations ] (Day 8)
/// - Medical History Tab (Day 7):
///   - Single white card listing medical history records
///   - Bold title (diagnosis or vaccine name)
///   - Subtitle in exact format: "[Branch Name] \u00B7 [Vet Name]"
///   - Record date
///   - Status tags computed via documented rules:
///     * Treatments: "Resolved" once follow-up has passed or marked resolved
///     * Vaccinations: "[X] Year Valid" computed from gap between dateGiven & nextDueDate
///     * Routine Checkups: "Completed"
///   - Full-width "VIEW FULL HISTORY" button
/// - Vaccinations Tab (Day 8):
///   - "Immunization Status" summary line: e.g. "3 of 4 Ready" (up-to-date / total)
///   - "Scheduled Immunizations" list with vaccine name, date given, next due date
///   - Status pill: green "Up to date" or red "Overdue" computed from real dates
///   - "Book Now" link on overdue rows
///   - "+ Add Vaccination" button with complete bottom-sheet form writing to Firestore
class PetProfileScreen extends StatefulWidget {
  final int initialTabIndex;
  final bool showBackButton;
  final PetModel? initialPet;

  const PetProfileScreen({
    super.key,
    this.initialTabIndex = 0,
    this.showBackButton = false,
    this.initialPet,
  });

  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  final MedicalRecordsService _recordsService = MedicalRecordsService();
  final ScrollController _scrollController = ScrollController();

  late int _activeTabIndex;
  bool _isLoading = true;
  bool _showAllHistory = false;

  late PetModel _pet;
  List<UnifiedMedicalRecord> _records = [];
  List<VaccinationModel> _vaccinations = [];

  bool _didCheckRouteArgs = false;

  @override
  void initState() {
    super.initState();
    _activeTabIndex = widget.initialTabIndex;
    _recordsService.selectedPetNotifier.addListener(_onSelectedPetChanged);
    _initPetData();
  }

  void _onSelectedPetChanged() {
    final pet = _recordsService.selectedPetNotifier.value;
    if (pet != null && pet.id != _pet.id && mounted) {
      setState(() {
        _pet = pet;
        _records = _recordsService.getFallbackRecords(_pet.id);
        _vaccinations = _recordsService.getFallbackVaccinations(_pet.id);
        _isLoading = true;
      });
      _loadData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didCheckRouteArgs) {
      _didCheckRouteArgs = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is PetModel) {
        _pet = args;
        _recordsService.selectPet(args);
        _loadData();
      }
    }
  }

  void _initPetData() {
    final now = DateTime.now();
    final activePet =
        widget.initialPet ?? _recordsService.selectedPetNotifier.value;

    // Default fallback pet if none is passed or registered
    _pet = activePet ??
        PetModel(
          id: 'pet_milo_default',
          name: 'Milo',
          species: 'Dog',
          breed: 'Golden Retriever',
          gender: 'male',
          dateOfBirth: DateTime(now.year - 3, now.month, now.day),
          microchipId: '98514',
          ownerId: 'owner_demo',
          weightKg: 28.0,
          createdAt: DateTime(now.year - 3, now.month, now.day),
        );

    // Populate immediately for 0ms initial render
    _records = _recordsService.getFallbackRecords(_pet.id);
    _vaccinations = _recordsService.getFallbackVaccinations(_pet.id);
    _isLoading = false;

    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _recordsService.fetchMedicalHistory(_pet.id),
        _recordsService.fetchVaccinations(_pet.id),
      ]).timeout(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _records = results[0] as List<UnifiedMedicalRecord>;
          _vaccinations = results[1] as List<VaccinationModel>;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted && _records.isEmpty) {
        setState(() {
          _records = _recordsService.getFallbackRecords(_pet.id);
          _vaccinations = _recordsService.getFallbackVaccinations(_pet.id);
          _isLoading = false;
        });
      }
    }
  }

  /// Formats DateTime cleanly as "Jan 15, 2026"
  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  void dispose() {
    _recordsService.selectedPetNotifier.removeListener(_onSelectedPetChanged);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate distinct branches dynamically from actual records
    final int distinctBranches =
        _recordsService.calculateDistinctBranches(_records);
    final immunizationSummary =
        _recordsService.calculateImmunizationSummary(_vaccinations);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.4), width: 1),
            ),
            child: const Icon(Icons.arrow_back,
                size: 18, color: AppColors.textPrimary),
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              final shell = MainNavigationShell.of(context);
              if (shell != null) {
                shell.setTab(0);
              }
            }
          },
        ),
        title: const Text(
          'Pet Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border.withValues(alpha: 0.4), width: 1),
              ),
              child: const Icon(Icons.refresh_rounded,
                  size: 18, color: AppColors.textPrimary),
            ),
            tooltip: 'Refresh Records',
            onPressed: _loadData,
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border.withValues(alpha: 0.4), width: 1),
              ),
              child: const Icon(Icons.edit_outlined,
                  size: 18, color: AppColors.textPrimary),
            ),
            tooltip: 'Edit Pet',
            onPressed: _showEditPetSheet,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: ListView(
                    controller: _scrollController,
                    cacheExtent: 4000,
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, AppSpacing.sm, AppSpacing.md, 110),
                    children: [
                      // =========================================================
                      // PET RECORDS SWITCHER (View & Switch across all user pets)
                      // =========================================================
                      _buildPetSwitcherHeader(),
                      const SizedBox(height: 14),

                      // =========================================================
                      // DAY 7 — HERO PET PROFILE CARD (Double-Bezel & Vitals Bento)
                      // =========================================================
                      _buildHeroPetCard(distinctBranches),
                      const SizedBox(height: 18),

                      // =========================================================
                      // SEGMENTED TAB SWITCHER (Medical History vs. Vaccinations)
                      // =========================================================
                      _buildTabSwitcher(),
                      const SizedBox(height: 18),

                      // Active Tab Content
                      if (_activeTabIndex == 0)
                        _buildMedicalHistorySection()
                      else
                        _buildVaccinationsSection(immunizationSummary),
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: _activeTabIndex == 1
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                'Add Vaccination',
                style:
                    TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
              ),
              onPressed: _openAddVaccinationModal,
            )
          : null,
    );
  }

  // =========================================================================
  // WIDGET: Pet Records Switcher Header (Switch between all user pets)
  // =========================================================================
  Widget _buildPetSwitcherHeader() {
    return ValueListenableBuilder<List<PetModel>>(
      valueListenable: _recordsService.petsNotifier,
      builder: (context, petList, _) {
        if (petList.isEmpty) return const SizedBox.shrink();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
                children: [
                  ...petList.map((petItem) {
                    final isSelected = petItem.id == _pet.id ||
                        petItem.name.toLowerCase() == _pet.name.toLowerCase();

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          if (_pet.id != petItem.id) {
                            setState(() {
                              _pet = petItem;
                              _records = _recordsService
                                  .getFallbackRecords(petItem.id);
                              _vaccinations = _recordsService
                                  .getFallbackVaccinations(petItem.id);
                              _isLoading = true;
                            });
                            _recordsService.selectPet(petItem);
                            _loadData();
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? AppColors.darkPill : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.darkPill
                                  : const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.darkPill
                                          .withValues(alpha: 0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : AppShadows.aestheticCard,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PetAvatarView(
                                photoUrl: petItem.photoUrl,
                                species: petItem.species,
                                size: 24,
                                isCircle: true,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '🐾 ${petItem.name}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 6),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  // Add Pet Chip
                  InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      final shell = MainNavigationShell.of(context);
                      if (shell != null) {
                        shell.setTab(2);
                      } else {
                        Navigator.pushNamed(context, AppRoutes.addPet);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.lightPill,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border, width: 1.2),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 16, color: AppColors.primary),
                          SizedBox(width: 4),
                          Text(
                            'Add Pet',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
      },
    );
  }

  // =========================================================================
  // WIDGET: Hero White Card with Orange Ring Avatar & Branch Count Banner
  // =========================================================================
  Widget _buildHeroPetCard(int distinctBranches) {
    final chipNumber = _pet.microchipId.isNotEmpty
        ? _pet.microchipId.replaceAll('CHIP-', '')
        : '98514';
    final ageText = '${_pet.ageYears} yrs';
    final weightText = '${_pet.weightKg?.toStringAsFixed(0) ?? '28'} kg';
    final genderText =
        _pet.gender.toLowerCase() == 'female' ? 'Female' : 'Male';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: AppColors.border.withValues(alpha: 0.6), width: 1.2),
        boxShadow: AppShadows.aestheticCard,
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        children: [
          // Circular pet avatar with halo & primary ring
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: PetAvatarView(
              photoUrl: _pet.photoUrl,
              species: _pet.species,
              size: 80,
              isCircle: true,
            ),
          ),
          const SizedBox(height: 8),

          // Pet Name
          Text(
            _pet.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),

          // Breed and microchip ID (e.g. "Golden Retriever · Microchip #98514")
          Text(
            '${_pet.breed} \u00B7 Microchip #$chipNumber',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 10),

          // 3-Column Vitals Bento Bar (Age / Weight / Gender)
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(
                  label: 'Age',
                  value: ageText,
                  icon: Icons.cake_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoChip(
                  label: 'Weight',
                  value: weightText,
                  icon: Icons.scale_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoChip(
                  label: 'Gender',
                  value: genderText,
                  icon: Icons.pets_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Banner reading "Unified Cloud Record — Synced across [N] metro branches"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: const Color(0xFFBBF7D0), width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF16A34A),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Unified Cloud Record \u2014 Synced across $distinctBranches metro branches',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF15803D),
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.border.withValues(alpha: 0.5), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12, color: AppColors.textSecondary),
              const SizedBox(width: 3),
              Text(
                '$label: ',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 1),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // WIDGET: Segmented Tab Bar (Medical History vs. Vaccinations)
  // =========================================================================
  Widget _buildTabSwitcher() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildSegmentButton(
                index: 0,
                title: 'Medical History',
                icon: Icons.history_edu_outlined,
              ),
            ),
            Expanded(
              child: _buildSegmentButton(
                index: 1,
                title: 'Vaccinations',
                icon: Icons.vaccines_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentButton({
    required int index,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _activeTabIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _activeTabIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // DAY 7 — SECTION: Medical History Card
  // =========================================================================
  Widget _buildMedicalHistorySection() {
    final displayedRecords =
        _showAllHistory ? _records : _records.take(4).toList();

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: AppColors.border.withValues(alpha: 0.6), width: 1.2),
            boxShadow: AppShadows.aestheticCard,
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.history_edu_rounded,
                              size: 20, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Medical History',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Medical Records',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_records.length} records',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Quick Actions: Add Treatment & Documents (Day 11 & Day 12 Integration)
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () async {
                          final result = await Navigator.of(context).pushNamed(
                            AppRoutes.addTreatment,
                            arguments: _pet,
                          );
                          if (result == true) {
                            _loadData();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              width: 1.2,
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_circle_outline_rounded,
                                  size: 16, color: AppColors.primary),
                              SizedBox(width: 6),
                              Text(
                                'Add Treatment',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AppRoutes.documents,
                            arguments: _pet,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.border,
                              width: 1.2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x06000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.folder_shared_outlined,
                                  size: 16, color: Color(0xFF4B5563)),
                              SizedBox(width: 6),
                              Text(
                                'Documents',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF374151),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

              if (displayedRecords.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No medical records logged yet.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              else
                ...List.generate(displayedRecords.length, (index) {
                  final record = displayedRecords[index];
                  return Column(
                    children: [
                      _buildMedicalHistoryRow(record),
                      if (index < displayedRecords.length - 1)
                        const Divider(
                            color: AppColors.aestheticBorder, height: 22),
                    ],
                  );
                }),

              const SizedBox(height: 16),

              // Full-width "VIEW FULL HISTORY" button at bottom
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showAllHistory = !_showAllHistory;
                    });
                    if (_showAllHistory) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkPill,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                  child: Text(
                    _showAllHistory ? 'COLLAPSE HISTORY' : 'VIEW FULL HISTORY',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Quick Link for Medical Documents & Lab Reports
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
                color: AppColors.border.withValues(alpha: 0.4), width: 1),
            boxShadow: AppShadows.subtleCard,
          ),
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22)),
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.description_outlined,
                    color: Color(0xFF2563EB), size: 20),
              ),
              title: const Text(
                'Medical Documents & Lab Reports',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: const Text(
                'Prescriptions, X-rays, and discharge summaries',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              trailing: const Icon(Icons.arrow_forward_ios,
                  size: 12, color: AppColors.textSecondary),
              onTap: () => Navigator.pushNamed(context, AppRoutes.documents),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicalHistoryRow(UnifiedMedicalRecord record) {
    IconData icon;
    Color iconColor;
    Color bgColor;

    switch (record.type) {
      case MedicalRecordType.treatment:
        icon = Icons.healing_outlined;
        iconColor = const Color(0xFF2563EB);
        bgColor = const Color(0xFFEFF6FF);
        break;
      case MedicalRecordType.vaccination:
        icon = Icons.vaccines_outlined;
        iconColor = const Color(0xFFD97706);
        bgColor = const Color(0xFFFEF3C7);
        break;
      case MedicalRecordType.checkup:
        icon = Icons.verified_outlined;
        iconColor = const Color(0xFF16A34A);
        bgColor = const Color(0xFFF0FDF4);
        break;
    }

    final tagText = record.statusTag;
    final isResolvedOrValid = tagText == 'Resolved' ||
        tagText.contains('Valid') ||
        tagText == 'Completed';

    final tagBg =
        isResolvedOrValid ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7);
    final tagTextColor =
        isResolvedOrValid ? const Color(0xFF15803D) : const Color(0xFFB45309);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon Container
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 14),

        // Record Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bold title (diagnosis or vaccine name)
              Text(
                record.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 3),

              // Subtitle in the exact format "[Branch Name] · [Vet Name]"
              Text(
                record.formattedSubtitle,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 3),

              // Record Date
              Text(
                _formatDate(record.date),
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Status Tag ("Resolved", "[X] Year Valid", or "Completed")
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: tagBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            tagText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: tagTextColor,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // DAY 8 — SECTION: Dedicated Vaccinations Tab
  // =========================================================================
  Widget _buildVaccinationsSection(ImmunizationSummary summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Immunization Status summary card: "3 of 4 Ready"
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: AppColors.border.withValues(alpha: 0.4), width: 1),
            boxShadow: AppShadows.aestheticCard,
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_user_outlined,
                    color: Color(0xFF16A34A), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Immunization Status',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Summary line: e.g. "3 of 4 Ready"
                    Text(
                      summary.summaryText,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: summary.upToDateCount == summary.totalCount &&
                          summary.totalCount > 0
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  summary.upToDateCount == summary.totalCount &&
                          summary.totalCount > 0
                      ? 'Fully Protected'
                      : 'Action Needed',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: summary.upToDateCount == summary.totalCount &&
                            summary.totalCount > 0
                        ? const Color(0xFF15803D)
                        : const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Scheduled Immunizations List Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
                color: AppColors.border.withValues(alpha: 0.4), width: 1),
            boxShadow: AppShadows.aestheticCard,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Scheduled Immunizations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              if (_vaccinations.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No vaccinations recorded yet.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              else
                ...List.generate(_vaccinations.length, (index) {
                  final vac = _vaccinations[index];
                  return Column(
                    children: [
                      _buildVaccinationRow(vac),
                      if (index < _vaccinations.length - 1)
                        const Divider(
                            color: AppColors.aestheticBorder, height: 22),
                    ],
                  );
                }),

              const SizedBox(height: 18),

              // Full width "+ Add Vaccination" button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _openAddVaccinationModal,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text(
                    '+ Add Vaccination',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                      fontSize: 13.5,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side:
                        const BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVaccinationRow(VaccinationModel vac) {
    final now = DateTime.now();
    // Rule: if nextDueDate is in future -> Up to date, else -> Overdue
    final bool isUpToDate = vac.nextDueDate.isAfter(now);

    final pillBg =
        isUpToDate ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2);
    final pillTextColor =
        isUpToDate ? const Color(0xFF15803D) : const Color(0xFFDC2626);
    final pillText = isUpToDate ? 'Up to date' : 'Overdue';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color:
                isUpToDate ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.vaccines,
            color:
                isUpToDate ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vaccine Name (bold)
              Text(
                vac.vaccineName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 3),

              // Given Date & Next Due Date
              Text(
                'Given: ${_formatDate(vac.dateGiven)}',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Next Due: ${_formatDate(vac.nextDueDate)}',
                style: TextStyle(
                  fontSize: 12.5,
                  color: isUpToDate
                      ? AppColors.textPrimary
                      : const Color(0xFFDC2626),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Status Pill (green "Up to date" or red "Overdue")
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: pillBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                pillText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: pillTextColor,
                  letterSpacing: 0.1,
                ),
              ),
            ),

            // Overdue rows get a small "Book Now" link
            if (!isUpToDate) ...[
              const SizedBox(height: 6),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.vetSearch);
                },
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Book Now',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.arrow_forward_ios,
                          size: 9, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // =========================================================================
  // DAY 8 — MODAL FORM: "+ Add Vaccination"
  // =========================================================================
  void _openAddVaccinationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => _AddVaccinationForm(
        petId: _pet.id,
        onVaccineAdded: (newVaccine) {
          setState(() {
            _vaccinations.insert(0, newVaccine);
            // Also append to medical history for unified cross-branch record
            _records.insert(
              0,
              UnifiedMedicalRecord(
                id: newVaccine.id,
                type: MedicalRecordType.vaccination,
                title: newVaccine.vaccineName,
                branchId: newVaccine.branchId,
                branchName: newVaccine.branchName ?? 'Downtown Branch',
                vetId: newVaccine.vetId,
                vetName: newVaccine.vetName ?? 'Dr. Sarah Jenkins, DVM',
                date: newVaccine.dateGiven,
                nextDueDate: newVaccine.nextDueDate,
                rawStatus: newVaccine.isUpToDate ? 'up_to_date' : 'overdue',
                notes: newVaccine.notes,
              ),
            );
          });
        },
      ),
    );
  }

  void _showEditPetSheet() {
    final weightController = TextEditingController(
      text: _pet.weightKg != null ? _pet.weightKg.toString() : '',
    );
    final breedController = TextEditingController(text: _pet.breed);
    final formKey = GlobalKey<FormState>();
    String? currentPhotoUrl = _pet.photoUrl;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.edit_note,
                          color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit ${_pet.name}\'s Details',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textPrimary),
                          ),
                          const Text(
                            'Update photo, weight and breed on centralized record',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const Divider(color: AppColors.border),
                const SizedBox(height: AppSpacing.sm),

                // Photo Preview & Change Button
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: AppColors.primary, width: 2.5),
                        ),
                        child: PetAvatarView(
                          photoUrl: currentPhotoUrl,
                          species: _pet.species,
                          size: 72,
                          isCircle: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.photo_camera, size: 16),
                        label: Text(
                          currentPhotoUrl != null
                              ? 'Change Photo'
                              : 'Upload Photo',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                        ),
                        onPressed: () async {
                          try {
                            final file = await FilePicker.pickFile(
                              type: FileType.custom,
                              allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
                            );
                            if (file != null) {
                              final bytes = await file.readAsBytes();
                              final base64String = base64Encode(bytes);
                              final dataUri =
                                  'data:image/jpeg;base64,$base64String';
                              setModalState(() {
                                currentPhotoUrl = dataUri;
                              });
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Notice: $e')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                TextFormField(
                  controller: weightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    hintText: 'e.g. 28.5',
                    prefixIcon: Icon(Icons.monitor_weight_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val != null && val.trim().isNotEmpty) {
                      final num? parsed = num.tryParse(val.trim());
                      if (parsed == null || parsed <= 0) {
                        return 'Enter a valid weight in kg';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: breedController,
                  decoration: const InputDecoration(
                    labelText: 'Breed',
                    hintText: 'e.g. Golden Retriever',
                    prefixIcon: Icon(Icons.pets_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (formKey.currentState?.validate() != true) return;
                    final newWeight =
                        double.tryParse(weightController.text.trim()) ??
                            _pet.weightKg;
                    final newBreed = breedController.text.trim().isNotEmpty
                        ? breedController.text.trim()
                        : _pet.breed;

                    final updatedPet = _pet.copyWith(
                      weightKg: newWeight,
                      breed: newBreed,
                      photoUrl: currentPhotoUrl,
                    );

                    await _recordsService.registerPet(updatedPet);
                    if (mounted) {
                      setState(() {
                        _pet = updatedPet;
                      });
                      Navigator.pop(sheetCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.success,
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text('Updated ${_pet.name}\'s profile details!'),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: const Text('Save Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// MODAL BOTTOM SHEET: Add Vaccination Form
// ===========================================================================
class _AddVaccinationForm extends StatefulWidget {
  final String petId;
  final Function(VaccinationModel) onVaccineAdded;

  const _AddVaccinationForm({
    required this.petId,
    required this.onVaccineAdded,
  });

  @override
  State<_AddVaccinationForm> createState() => _AddVaccinationFormState();
}

class _AddVaccinationFormState extends State<_AddVaccinationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _vaccineNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _dateGiven = DateTime.now();
  DateTime _nextDueDate = DateTime.now().add(const Duration(days: 365));
  String _selectedBranch = 'branch_downtown';
  bool _isSubmitting = false;

  final List<String> _quickVaccines = [
    'Rabies 3-Year',
    'DHPP Booster',
    'Bordetella Oral',
    'Leptospirosis 4-Way',
  ];

  @override
  void dispose() {
    _vaccineNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  Future<void> _pickDateGiven() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateGiven,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _dateGiven = picked;
        // Auto-update next due date to 1 year ahead
        _nextDueDate = picked.add(const Duration(days: 365));
      });
    }
  }

  Future<void> _pickNextDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextDueDate,
      firstDate: _dateGiven,
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _nextDueDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    final vaccineName = _vaccineNameController.text.trim();
    if (vaccineName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter or select a vaccine name.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authService = context.read<AuthService>();
      final vetId = authService.currentUser?.uid ?? 'vet_sarah';

      final service = MedicalRecordsService();
      final addedVaccine = await service.addVaccination(
        petId: widget.petId,
        vaccineName: vaccineName,
        dateGiven: _dateGiven,
        nextDueDate: _nextDueDate,
        branchId: _selectedBranch,
        vetId: vetId,
        branchName: MedicalRecordsService.branchNameMap[_selectedBranch],
        vetName:
            MedicalRecordsService.vetNameMap[vetId] ?? 'Dr. Sarah Jenkins, DVM',
        notes: _notesController.text.trim(),
      );

      widget.onVaccineAdded(addedVaccine);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vaccination recorded and synced across branches!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save vaccination: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                '+ Add Vaccination Record',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Auto-attaches pet ID, branch ID, vet ID, and server timestamp.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 18),

              // Vaccine Name TextField
              TextField(
                controller: _vaccineNameController,
                decoration: InputDecoration(
                  labelText: 'Vaccine Name *',
                  hintText: 'e.g. Rabies 3-Year, DHPP Booster',
                  filled: true,
                  fillColor: AppColors.lightPill,
                  prefixIcon: const Icon(Icons.vaccines_outlined,
                      color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Quick vaccine selection chips
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _quickVaccines.map((v) {
                  return ActionChip(
                    label: Text(v,
                        style: const TextStyle(
                            fontSize: 11.5, fontWeight: FontWeight.w600)),
                    backgroundColor: AppColors.lightPill,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    onPressed: () {
                      _vaccineNameController.text = v;
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Date Given and Next Due Date pickers
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDateGiven,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.lightPill,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Date Given',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 14, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  _formatDate(_dateGiven),
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: _pickNextDueDate,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.lightPill,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Next Due Date',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.event_repeat,
                                    size: 14, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  _formatDate(_nextDueDate),
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Clinic Branch Selector
              DropdownButtonFormField<String>(
                initialValue: _selectedBranch,
                decoration: InputDecoration(
                  labelText: 'Clinic Branch',
                  filled: true,
                  fillColor: AppColors.lightPill,
                  prefixIcon: const Icon(Icons.apartment,
                      color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'branch_downtown', child: Text('Downtown Branch')),
                  DropdownMenuItem(
                      value: 'branch_westside', child: Text('Westside Branch')),
                  DropdownMenuItem(
                      value: 'branch_metro_hub',
                      child: Text('Central Metro Hub')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedBranch = val);
                },
              ),
              const SizedBox(height: 16),

              // Notes TextField
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Batch / Lot Notes (Optional)',
                  hintText: 'e.g. Lot #RB-8921, right shoulder subcutaneous',
                  filled: true,
                  fillColor: AppColors.lightPill,
                  prefixIcon: const Icon(Icons.notes_outlined,
                      color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text(
                          'Save Vaccination Record',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
