import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../services/auth_service.dart';
import '../../services/medical_records_service.dart';
import '../../utils/constants.dart';
import '../main_navigation_shell.dart';

/// Quick Protocol Preset definition for clinical shortcuts
class TreatmentProtocolPreset {
  final String label;
  final String diagnosis;
  final String medication;
  final String defaultNotes;

  const TreatmentProtocolPreset({
    required this.label,
    required this.diagnosis,
    required this.medication,
    this.defaultNotes = '',
  });
}

/// DAY 11 — Add Treatment Form with Quick Protocol Presets
class AddTreatmentScreen extends StatefulWidget {
  final PetModel? pet;
  final String? petId;
  final bool isEmbeddedInNav;

  const AddTreatmentScreen({
    super.key,
    this.pet,
    this.petId,
    this.isEmbeddedInNav = false,
  });

  @override
  State<AddTreatmentScreen> createState() => _AddTreatmentScreenState();
}

class _AddTreatmentScreenState extends State<AddTreatmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicalService = MedicalRecordsService();

  late final TextEditingController _diagnosisController;
  late final TextEditingController _medicationController;
  late final TextEditingController _notesController;

  DateTime? _selectedFollowUpDate;
  bool _isSaving = false;
  String? _selectedPresetLabel;

  // Active pet model resolution
  late PetModel _activePet;

  // =========================================================================
  // QUICK PROTOCOL PRESETS LOOKUP TABLE (Day 11 Shortcut Feature)
  // =========================================================================
  static const List<TreatmentProtocolPreset> _protocolPresets = [
    TreatmentProtocolPreset(
      label: 'Ear Flush & Drops',
      diagnosis: 'Otitis Externa (Bilateral Ear Canal Erythema & Exudate)',
      medication:
          'Otomax Otic Ointment 4 drops BID x 10d, Medicated Cleanser flush Q3D',
      defaultNotes:
          'Bilateral canal erythema and dark ceruminous discharge. Gentle flush performed.',
    ),
    TreatmentProtocolPreset(
      label: 'Annual Booster',
      diagnosis: 'Preventive Healthcare Examination & Core Immunization',
      medication:
          'DHPP + Rabies Booster (1ml SC), Broad-Spectrum Deworming (1 tab PO)',
      defaultNotes:
          'Physical exam normal. Vitals stable. Vaccines administered right hind limb.',
    ),
    TreatmentProtocolPreset(
      label: 'Allergy Care',
      diagnosis: 'Canine Atopic Allergic Dermatitis & Secondary Pruritus',
      medication:
          'Apoquel (Oclacitinib) 16mg SID x 14d, Medicated Chlorhexidine Shampoo 2x/wk',
      defaultNotes:
          'Patient exhibits pedal pruritus and ventral erythema. Allergy management initiated.',
    ),
    TreatmentProtocolPreset(
      label: 'Dental Prophy',
      diagnosis: 'Stage II Periodontal Disease & Subgingival Calculus',
      medication:
          'Amoxicillin-Clavulanate 250mg BID x 7d, Chlorhexidine Oral Barrier Gel SID',
      defaultNotes:
          'Ultrasonic scaling, subgingival curettage, and fluoride polish completed under sedation.',
    ),
    TreatmentProtocolPreset(
      label: 'Gastroenteritis',
      diagnosis: 'Acute Dietary Indiscretion Gastroenteritis',
      medication:
          'Metronidazole 250mg BID x 5d, Proviable Forte Probiotics 1 capsule SID x 10d',
      defaultNotes:
          'Mild abdominal discomfort on palpation. Hydration adequate. Bland boiled diet advised.',
    ),
    TreatmentProtocolPreset(
      label: 'Post-Surgery Check',
      diagnosis: 'Post-Operative Incision Evaluation & Suture Inspection',
      medication:
          'Carprofen (Rimadyl) 75mg SID x 5d, Cephalexin 500mg BID x 7d',
      defaultNotes:
          'Surgical site dry, intact, and healing well with no signs of infection or seroma.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _diagnosisController = TextEditingController();
    _medicationController = TextEditingController();
    _notesController = TextEditingController();

    // Default follow-up date to 2 weeks from today
    _selectedFollowUpDate = DateTime.now().add(const Duration(days: 14));

    // Resolve initial pet model
    _activePet = widget.pet ?? _getDefaultPet(widget.petId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is PetModel) {
      setState(() => _activePet = args);
    }
  }

  PetModel _getDefaultPet(String? id) {
    final now = DateTime.now();
    return PetModel(
      id: id ?? 'pet_milo_default',
      name: 'Milo',
      species: 'Dog',
      breed: 'Golden Retriever',
      gender: 'male',
      dateOfBirth: DateTime(now.year - 3, now.month, now.day),
      microchipId: '98514',
      ownerId: 'owner_sarah',
      weightKg: 28.0,
      createdAt: now.subtract(const Duration(days: 365 * 3)),
    );
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _medicationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Applies preset values to form fields from the lookup table
  void _applyPreset(TreatmentProtocolPreset preset) {
    setState(() {
      _selectedPresetLabel = preset.label;
      _diagnosisController.text = preset.diagnosis;
      _medicationController.text = preset.medication;
      if (_notesController.text.trim().isEmpty) {
        _notesController.text = preset.defaultNotes;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Preset "${preset.label}" applied to diagnosis & dosage.'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pickFollowUpDate() async {
    final initialDate =
        _selectedFollowUpDate ?? DateTime.now().add(const Duration(days: 14));
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF97316),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1F2937),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedFollowUpDate = picked);
    }
  }

  Future<void> _handleSaveTreatment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userModel = authService.currentUserModel;

      // Auto-attach vet's credentials and branch. Never editable directly by the vet.
      final vetId =
          userModel?.id ?? authService.currentUser?.uid ?? 'user_dr_sharma';
      final vetName =
          userModel?.name.isNotEmpty == true ? userModel!.name : 'Dr. Sharma';
      final branchId = userModel?.branchId?.isNotEmpty == true
          ? userModel!.branchId!
          : 'branch_koramangala';
      final branchName = MedicalRecordsService.branchNameMap[branchId] ??
          'VetCare Central - Koramangala';

      await _medicalService.addTreatment(
        petId: _activePet.id,
        diagnosis: _diagnosisController.text.trim(),
        medication: _medicationController.text.trim(),
        notes: _notesController.text.trim(),
        treatmentDate: DateTime.now(),
        followUpDate: _selectedFollowUpDate,
        branchId: branchId,
        vetId: vetId,
        branchName: branchName,
        vetName: vetName,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Treatment recorded for ${_activePet.name}! Synced across clinics.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );

      if (widget.isEmbeddedInNav) {
        _diagnosisController.clear();
        _medicationController.clear();
        _notesController.clear();
        setState(() {
          _isSaving = false;
          _selectedPresetLabel = null;
        });
      } else {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFEF4444),
          content: Text('Failed to save treatment: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1F2937), size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            } else {
              final shell = MainNavigationShell.of(context);
              if (shell != null) {
                shell.setTab(0);
              }
            }
          },
        ),
        title: const Text(
          'Log Clinical Treatment',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E7EB), height: 1),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                  16, 20, 16, widget.isEmbeddedInNav ? 110 : 20),
              child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Pet Quick-Info Card with "Checked In" status pill
                _buildPetQuickInfoCard(),
                const SizedBox(height: 20),

                // 2. Quick Protocol Presets Header & Horizontal Chips Row
                Row(
                  children: [
                    const Icon(Icons.bolt_rounded,
                        size: 18, color: Color(0xFFF97316)),
                    const SizedBox(width: 6),
                    const Text(
                      'Quick Protocol Presets',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Tap to autofill',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildProtocolPresetChips(),
                const SizedBox(height: 24),

                // 3. Clinical Treatment Form Fields
                _buildSectionHeader('Diagnosis', isRequired: true),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _diagnosisController,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a clinical diagnosis or chief complaint.';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _buildInputDecoration(
                    hintText: 'e.g. Otitis Externa or Canine Atopic Dermatitis',
                    prefixIcon: Icons.healing_rounded,
                  ),
                ),
                const SizedBox(height: 18),

                _buildSectionHeader('Medication & Dosage', isRequired: true),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _medicationController,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please specify prescribed medications and dosages.';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _buildInputDecoration(
                    hintText: 'e.g. Apoquel 16mg SID x 14d, Otomax Drops BID',
                    prefixIcon: Icons.medication_liquid_rounded,
                  ),
                ),
                const SizedBox(height: 18),

                _buildSectionHeader('Treatment Notes & Clinical Observations'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _buildInputDecoration(
                    hintText:
                        'Add clinical notes, patient vitals, cytology findings, or care instructions...',
                    prefixIcon: Icons.notes_rounded,
                  ),
                ),
                const SizedBox(height: 18),

                _buildSectionHeader('Follow-up Date'),
                const SizedBox(height: 8),
                _buildFollowUpPicker(),
                const SizedBox(height: 24),

                // 4. Static Network Sync Banner
                _buildNetworkSyncBanner(),
                const SizedBox(height: 24),

                // 5. Submit Action Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _handleSaveTreatment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF97316),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      disabledBackgroundColor: const Color(0xFFFDBA74),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Save Treatment Record',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
);
}

  /// 1. Pet Quick-Info Card
  Widget _buildPetQuickInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Pet avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFF7ED),
              border: Border.all(color: const Color(0xFFF97316), width: 2),
            ),
            child: Center(
              child: Text(
                _activePet.species.toLowerCase() == 'cat' ? '🐱' : '🐶',
                style: const TextStyle(fontSize: 26),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Pet Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _activePet.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // "Checked In" status pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Checked In',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF065F46),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${_activePet.breed} \u2022 ${_activePet.ageYears} yrs \u2022 ${_activePet.weightKg ?? 25.0} kg',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Quick Protocol Presets Horizontal Chips Row
  Widget _buildProtocolPresetChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: _protocolPresets.map((preset) {
          final isSelected = _selectedPresetLabel == preset.label;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(preset.label),
              selected: isSelected,
              onSelected: (_) => _applyPreset(preset),
              labelStyle: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? const Color(0xFFC2410C)
                    : const Color(0xFF374151),
              ),
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFFFFEDD5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFFF97316)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 3. Form input styling
  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(fontSize: 13.5, color: Colors.grey.shade400),
      prefixIcon: Icon(prefixIcon, size: 20, color: const Color(0xFF9CA3AF)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF97316), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF374151),
          ),
        ),
        if (isRequired)
          const Text(
            ' *',
            style: TextStyle(
                color: Color(0xFFEF4444), fontWeight: FontWeight.bold),
          ),
      ],
    );
  }

  /// 4. Follow-Up Date Selector
  Widget _buildFollowUpPicker() {
    final date = _selectedFollowUpDate;
    final dateStr = date != null
        ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
        : 'Select follow-up appointment date';

    return InkWell(
      onTap: _pickFollowUpDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                size: 18, color: Color(0xFF9CA3AF)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                dateStr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: date != null
                      ? const Color(0xFF111827)
                      : Colors.grey.shade400,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }

  /// 5. Static Network Sync Note Banner
  Widget _buildNetworkSyncBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Row(
        children: [
          Icon(Icons.cloud_sync_rounded, color: Color(0xFF0284C7), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Changes sync automatically to all VetCare clinics.',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
