import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/pet_model.dart';
import '../../services/auth_service.dart';
import '../../services/medical_records_service.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_card.dart';
import '../main_navigation_shell.dart';

/// DAY 5 — Add Pet Form
/// Features:
/// - Back button + "Add Pet" header with small paw icon
/// - Interactive "Add Photo" upload & mascot avatar picker
/// - Pet Name (required)
/// - Species selector shown as three pill buttons (Dog / Cat / Other, not a dropdown)
/// - Breed field
/// - Gender toggle (Male / Female)
/// - Date of Birth (date picker, validated as past date)
/// - Microchip ID (with auto-generation fallback for Firestore rule parity)
/// - Static note: "Automatic Multi-Branch Sync — Medical charts accessible across all VetCare clinics."
/// - Instant reactive registration in MedicalRecordsService + background Firestore persistence
/// - Loading state and success confirmation SnackBar
class AddPetScreen extends StatefulWidget {
  final bool isEmbeddedInNav;

  const AddPetScreen({
    super.key,
    this.isEmbeddedInNav = false,
  });

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _microchipController = TextEditingController();

  String _selectedSpecies = 'Dog'; // 'Dog', 'Cat', 'Other'
  String _selectedGender = 'male'; // 'male', 'female'
  DateTime? _selectedDateOfBirth;
  bool _isSaving = false;

  Uint8List? _photoBytes;
  String? _selectedAvatarUrl;
  String? _selectedAvatarLabel;

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _microchipController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final initial =
        _selectedDateOfBirth ?? DateTime(now.year - 2, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: DateTime(1990),
      lastDate: now,
      helpText: 'Select Pet Date of Birth',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  Future<void> _pickPhoto() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: const BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                ),
                const Text(
                  'Choose Pet Photo or Mascot Avatar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_library_outlined,
                        color: AppColors.primary),
                  ),
                  title: const Text(
                    'Upload from Device / Gallery',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('Select a JPG, PNG, or WEBP file'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      final file = await FilePicker.pickFile(
                        type: FileType.custom,
                        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
                      );
                      if (file != null) {
                        final bytes = await file.readAsBytes();
                        final base64String = base64Encode(bytes);
                        final dataUri = 'data:image/jpeg;base64,$base64String';
                        setState(() {
                          _photoBytes = bytes;
                          _selectedAvatarUrl = dataUri;
                          _selectedAvatarLabel = file.name;
                        });
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Notice: $e')),
                        );
                      }
                    }
                  },
                ),
                const Divider(height: 24),
                const Text(
                  'Or Pick a Mascot Avatar',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAvatarPreset(
                      icon: Icons.pets,
                      label: 'Golden',
                      color: const Color(0xFFFED7AA),
                      url:
                          'https://images.unsplash.com/photo-1552053831-71594a27632d?w=400&auto=format&fit=crop&q=80',
                      onSelect: (url, label) {
                        Navigator.pop(ctx);
                        setState(() {
                          _selectedAvatarUrl = url;
                          _selectedAvatarLabel = label;
                          _photoBytes = null;
                        });
                      },
                    ),
                    _buildAvatarPreset(
                      icon: Icons.pets,
                      label: 'Tabby Cat',
                      color: const Color(0xFFFDE68A),
                      url:
                          'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400&auto=format&fit=crop&q=80',
                      onSelect: (url, label) {
                        Navigator.pop(ctx);
                        setState(() {
                          _selectedAvatarUrl = url;
                          _selectedAvatarLabel = label;
                          _photoBytes = null;
                        });
                      },
                    ),
                    _buildAvatarPreset(
                      icon: Icons.cruelty_free,
                      label: 'Canary',
                      color: const Color(0xFFFEF08A),
                      url:
                          'https://images.unsplash.com/photo-1522858547550-340574cd2f33?w=400&auto=format&fit=crop&q=80',
                      onSelect: (url, label) {
                        Navigator.pop(ctx);
                        setState(() {
                          _selectedAvatarUrl = url;
                          _selectedAvatarLabel = label;
                          _photoBytes = null;
                        });
                      },
                    ),
                    _buildAvatarPreset(
                      icon: Icons.cruelty_free_outlined,
                      label: 'Bunny',
                      color: const Color(0xFFE9D5FF),
                      url:
                          'https://images.unsplash.com/photo-1585110396000-c9ffd4e4b308?w=400&auto=format&fit=crop&q=80',
                      onSelect: (url, label) {
                        Navigator.pop(ctx);
                        setState(() {
                          _selectedAvatarUrl = url;
                          _selectedAvatarLabel = label;
                          _photoBytes = null;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarPreset({
    required IconData icon,
    required String label,
    required Color color,
    required String url,
    required void Function(String url, String label) onSelect,
  }) {
    return GestureDetector(
      onTap: () => onSelect(url, label),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: Center(
              child: Icon(icon, color: AppColors.darkPill, size: 24),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSavePet() async {
    final name = _nameController.text.trim();
    final breed = _breedController.text.trim();
    String microchipId = _microchipController.text.trim();

    // Validation: Pet Name required
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter pet name.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validation: Species required
    if (_selectedSpecies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a species.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validation: Date of Birth must be a valid past date
    final now = DateTime.now();
    if (_selectedDateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a valid date of birth.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedDateOfBirth!.isAfter(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Date of birth must be a past date.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Microchip ID fallback for write-once Firestore rule constraint
    if (microchipId.isEmpty) {
      microchipId = 'CHIP-${now.millisecondsSinceEpoch}';
    }

    setState(() => _isSaving = true);

    try {
      final authService = context.read<AuthService>();
      final ownerId = authService.currentUser?.uid ?? 'guest_owner';
      final docId = 'pet_${now.millisecondsSinceEpoch}';

      final newPet = PetModel(
        id: docId,
        name: name,
        species: _selectedSpecies,
        breed: breed.isNotEmpty ? breed : 'Mixed',
        gender: _selectedGender,
        dateOfBirth: _selectedDateOfBirth!,
        microchipId: microchipId,
        ownerId: ownerId,
        photoUrl: _selectedAvatarUrl,
        createdAt: now,
      );

      // Register immediately into reactive app store & sync to Firestore in background
      await MedicalRecordsService().registerPet(newPet);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text('Pet "$name" registered successfully!'),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );

      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      } else {
        MainNavigationShell.of(context)?.setTab(0);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notice while saving pet: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dobFormatted = _selectedDateOfBirth != null
        ? '${_selectedDateOfBirth!.year}-${_selectedDateOfBirth!.month.toString().padLeft(2, '0')}-${_selectedDateOfBirth!.day.toString().padLeft(2, '0')}'
        : 'Select date of birth';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: widget.isEmbeddedInNav
            ? IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.4),
                        width: 1),
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
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
              )
            : BackButton(
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
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pets, size: 20, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'Add Pet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 95),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dashed-Border "Add Photo" Upload Placeholder with Interactive Picker
                  Center(
                    child: GestureDetector(
                      onTap: _pickPhoto,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  AppColors.primaryLight.withValues(alpha: 0.4),
                            ),
                            child: _photoBytes != null
                                ? ClipOval(
                                    child: Image.memory(
                                      _photoBytes!,
                                      width: 110,
                                      height: 110,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : _selectedAvatarUrl != null
                                    ? ClipOval(
                                        child: Image.network(
                                          _selectedAvatarUrl!,
                                          width: 110,
                                          height: 110,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, st) =>
                                              const Icon(
                                            Icons.pets,
                                            size: 40,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      )
                                    : CustomPaint(
                                        painter: DashedCirclePainter(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.6),
                                          strokeWidth: 1.8,
                                          dashWidth: 6,
                                          dashSpace: 4,
                                        ),
                                        child: const Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.add_a_photo_outlined,
                                                size: 28,
                                                color: AppColors.primary,
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Add Photo',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt,
                                  color: Colors.white, size: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Main Form Card
                  CustomCard(
                    margin: EdgeInsets.zero,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pet Name (Required)
                        const Text(
                          'Pet Name *',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        TextFormField(
                          controller: _nameController,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter a name for your pet';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: 'e.g. Milo, Bella',
                            prefixIcon: Icon(Icons.pets,
                                color: AppColors.textSecondary),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Species Selector: Three Pill Buttons (Dog / Cat / Other)
                        const Text(
                          'Species *',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            _buildSpeciesPill('Dog', Icons.pets),
                            const SizedBox(width: AppSpacing.sm),
                            _buildSpeciesPill('Cat', Icons.cruelty_free),
                            const SizedBox(width: AppSpacing.sm),
                            _buildSpeciesPill('Other', Icons.category_outlined),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Breed Field
                        const Text(
                          'Breed',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        TextField(
                          controller: _breedController,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Golden Retriever, Persian, Mixed',
                            prefixIcon: Icon(Icons.info_outline,
                                color: AppColors.textSecondary),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Gender Toggle (Male / Female)
                        const Text(
                          'Gender',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Expanded(
                              child:
                                  _buildGenderPill('male', 'Male', Icons.male),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _buildGenderPill(
                                  'female', 'Female', Icons.female),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Date of Birth (Date Picker)
                        const Text(
                          'Date of Birth *',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        InkWell(
                          onTap: _pickDateOfBirth,
                          borderRadius: BorderRadius.circular(AppRadius.input),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.calendar_today_outlined,
                                  color: AppColors.textSecondary),
                              suffixIcon: Icon(Icons.arrow_drop_down,
                                  color: AppColors.textSecondary),
                            ),
                            child: Text(
                              dobFormatted,
                              style: TextStyle(
                                fontSize: 14,
                                color: _selectedDateOfBirth != null
                                    ? AppColors.textPrimary
                                    : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Microchip ID Field (Optional / Auto-Generated)
                        const Text(
                          'Microchip ID (Optional)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        TextField(
                          controller: _microchipController,
                          decoration: const InputDecoration(
                            hintText: 'Auto-assigned if left blank',
                            prefixIcon: Icon(Icons.qr_code,
                                color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Static Note: "Automatic Multi-Branch Sync — Medical charts accessible across all VetCare clinics."
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0x80FCEFEA),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border:
                          Border.all(color: const Color(0x40D95D39), width: 1),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.hub_outlined,
                            color: AppColors.primary, size: 20),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Automatic Multi-Branch Sync — Medical charts accessible across all VetCare clinics.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Save Button with Loading State
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _handleSavePet,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Save Pet Profile',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpeciesPill(String species, IconData icon) {
    final isSelected = _selectedSpecies == species;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedSpecies = species),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryLight : Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 1.6 : 1.0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: 5),
                Text(
                  species,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderPill(String genderKey, String label, IconData icon) {
    final isSelected = _selectedGender == genderKey;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedGender = genderKey),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.6 : 1.0,
            ),
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
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for dashed circular border
class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedCirclePainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.dashWidth = 5.0,
    this.dashSpace = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final radius = size.width / 2;
    final circumference = 2 * math.pi * radius;
    final dashCount = (circumference / (dashWidth + dashSpace)).floor();
    final adjustedDashAngle = (dashWidth / circumference) * 2 * math.pi;
    final adjustedSpaceAngle = (dashSpace / circumference) * 2 * math.pi;

    double currentAngle = 0.0;
    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(
            center: Offset(radius, radius), radius: radius - strokeWidth / 2),
        currentAngle,
        adjustedDashAngle,
        false,
        paint,
      );
      currentAngle += adjustedDashAngle + adjustedSpaceAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
