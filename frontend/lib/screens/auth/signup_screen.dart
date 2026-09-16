import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';

/// DAY 4 — Signup Screen & Persistent Login
/// Features:
/// - Small "Step 1 of 2" label at the top
/// - "Create your account" header
/// - Role selector with two chips ("Pet Owner" / "Veterinarian")
/// - Full Name field
/// - Email field
/// - Password field (with visibility toggle)
/// - Static info card titled "Multi-Clinic Unified Sync" with supporting copy
/// - Full-width "SIGN UP" button
/// - Automatic Firestore document creation: { name, email, role, branchId, createdAt } (branchId null for owners)
/// - Error handling surfaced to UI via SnackBar
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();

  String _selectedRole = 'owner'; // 'owner' or 'vet'
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final branchId = _branchController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out all required fields.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authService = context.read<AuthService>();
      await authService.registerWithEmailPassword(
        name: name,
        email: email,
        password: password,
        role: _selectedRole,
        branchId: _selectedRole == 'vet' && branchId.isNotEmpty ? branchId : null,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('Registration timed out. Please check your connection.'),
      );

      if (!mounted) return;

      final nextRoute = await authService.determineInitialRoute(waitDuration: Duration.zero);
      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        nextRoute,
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message = e.message ?? 'An authentication error occurred.';
      if (e.code == 'email-already-in-use') {
        message = 'This email is already in use. Please sign in instead.';
      } else if (e.code == 'weak-password') {
        message = 'The password is too weak. Please use at least 6 characters.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is invalid.';
      } else if (e.code == 'operation-not-allowed') {
        message = 'Email/Password sign-up is disabled in Firebase Console.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration notice: $e'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.aestheticBackground,
      appBar: AppBar(
        title: const Text(
          'Sign Up',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Step Label at Top: "Step 1 of 2"
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.darkPill,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: const Text(
                        'Step 1 of 2',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Header: "Create your account"
                  Text(
                    'Create your account',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Join VetCare to centralize medical records across clinics',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Form Container Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.heroCard),
                      boxShadow: AppShadows.aestheticCard,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Role Selector Header
                        Text(
                          'Account Type',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // Role Selector with Two Chips ("Pet Owner" / "Veterinarian")
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                showCheckmark: false,
                                avatar: Icon(
                                  Icons.pets,
                                  size: 16,
                                  color: _selectedRole == 'owner'
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                                label: const Center(
                                  child: Text('Pet Owner'),
                                ),
                                selected: _selectedRole == 'owner',
                                selectedColor: AppColors.darkPill,
                                backgroundColor: AppColors.lightPill,
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _selectedRole == 'owner'
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => _selectedRole = 'owner');
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: ChoiceChip(
                                showCheckmark: false,
                                avatar: Icon(
                                  Icons.medical_services_outlined,
                                  size: 16,
                                  color: _selectedRole == 'vet'
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                                label: const Center(
                                  child: Text('Veterinarian'),
                                ),
                                selected: _selectedRole == 'vet',
                                selectedColor: AppColors.darkPill,
                                backgroundColor: AppColors.lightPill,
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _selectedRole == 'vet'
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => _selectedRole = 'vet');
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Full Name Field
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            hintText: 'e.g. Sarah Jenkins',
                            prefixIcon: const Icon(Icons.person_outline, color: AppColors.textSecondary),
                            filled: true,
                            fillColor: AppColors.lightPill,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Email Field
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            hintText: 'name@example.com',
                            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondary),
                            filled: true,
                            fillColor: AppColors.lightPill,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        // Optional Clinic Branch ID for Veterinarians
                        if (_selectedRole == 'vet') ...[
                          const SizedBox(height: AppSpacing.md),
                          TextField(
                            controller: _branchController,
                            decoration: InputDecoration(
                              labelText: 'Clinic Branch ID (Optional)',
                              hintText: 'e.g. branch_central_01',
                              prefixIcon: const Icon(Icons.apartment, color: AppColors.textSecondary),
                              filled: true,
                              fillColor: AppColors.lightPill,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.md),

                        // Password Field with Visibility Toggle
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password (min 6 chars)',
                            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                            filled: true,
                            fillColor: AppColors.lightPill,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Static Info Card: "Multi-Clinic Unified Sync"
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFBBF7D0), width: 1),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.sync,
                                  color: Color(0xFF16A34A),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Multi-Clinic Unified Sync',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      'Your pet\'s health history, treatments, and vaccinations are securely unified across all participating clinic branches.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        if (_isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ),
                          )
                        else
                          // Full-Width "SIGN UP" Button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _handleRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkPill,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.only(left: 24, right: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'SIGN UP',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.2,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.18),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.arrow_forward, size: 17, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Bottom Redirect Link to Sign In
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
