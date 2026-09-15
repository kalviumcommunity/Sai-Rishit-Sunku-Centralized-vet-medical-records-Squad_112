import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/pet_model.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_card.dart';
import '../main_navigation_shell.dart';

/// DAY 5 — Add Pet Form
/// Features:
/// - Back button + "Add Pet" header with small paw icon
/// - Dashed-border "Add Photo" upload placeholder
/// - Pet Name (required)
/// - Species selector shown as three pill buttons (Dog / Cat / Other, not a dropdown)
/// - Breed field
/// - Gender toggle (Male / Female)
/// - Date of Birth (date picker, validated as past date)
/// - Microchip ID (with auto-generation fallback for Firestore rule parity)
/// - Static note: "Automatic Multi-Branch Sync — Medical charts accessible across all VetCare clinics."
/// - Firestore pets document write with ownerId & server timestamp
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

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _microchipController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final initial = _selectedDateOfBirth ?? DateTime(now.year - 2, now.month, now.day);
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

      // Save to Cloud Firestore 'pets' collection if Firebase is active
      if (Firebase.apps.isNotEmpty) {
        final firestore = FirebaseFirestore.instance;
        final docRef = firestore.collection('pets').doc();

        final newPet = PetModel(
          id: docRef.id,
          name: name,
          species: _selectedSpecies,
          breed: breed.isNotEmpty ? breed : 'Mixed',
          gender: _selectedGender,
          dateOfBirth: _selectedDateOfBirth!,
          microchipId: microchipId,
          ownerId: ownerId,
          createdAt: DateTime.now(),
        );

        await docRef.set(newPet.toMap()).timeout(const Duration(seconds: 10));
      }

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
      backgroundColor: AppColors.aestheticBackground,
      appBar: AppBar(
        backgroundColor: AppColors.aestheticBackground,
        elevation: 0,
        automaticallyImplyLeading: !widget.isEmbeddedInNav,
        leading: widget.isEmbeddedInNav ? null : const BackButton(),
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
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 95),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dashed-Border "Add Photo" Upload Placeholder
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Photo upload is optional for this MVP.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryLight.withValues(alpha: 0.4),
                        ),
                        child: CustomPaint(
                          painter: DashedCirclePainter(
                            color: AppColors.primary.withValues(alpha: 0.6),
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
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Milo, Bella',
                            prefixIcon: Icon(Icons.pets, color: AppColors.textSecondary),
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
                            prefixIcon: Icon(Icons.info_outline, color: AppColors.textSecondary),
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
                              child: _buildGenderPill('male', 'Male', Icons.male),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _buildGenderPill('female', 'Female', Icons.female),
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
                              prefixIcon: Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary),
                              suffixIcon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
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
                            prefixIcon: Icon(Icons.qr_code, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Static Note: "Automatic Multi-Branch Sync — Medical charts accessible across all VetCare clinics."
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0x80FCEFEA),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: const Color(0x40D95D39), width: 1),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.hub_outlined, color: AppColors.primary, size: 20),
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
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: 5),
                Text(
                  species,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
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
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
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
        Rect.fromCircle(center: Offset(radius, radius), radius: radius - strokeWidth / 2),
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
