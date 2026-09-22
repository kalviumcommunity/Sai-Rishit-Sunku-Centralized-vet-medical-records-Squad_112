import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';

/// DAY 3 — Login Screen with Email + Google Sign-In
/// Features:
/// - "Welcome back" header
/// - "Log in to view your pet's health records" subtitle
/// - Email field
/// - Password field with visibility toggle and "Forgot password?" UI link
/// - Full-width primary "LOG IN" button
/// - Divider reading "or continue with"
/// - Full-width white outline button with Google "G" icon and "Continue with Google"
/// - Touchless lobby check-in static card (visual placeholder only)
/// - Robust error handling surfaced via SnackBar
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _selectedRole = 'owner'; // 'owner' or 'vet'
  bool _userExplicitlySelectedRole = false;
  String _selectedBranch = 'branch_koramangala';

  static const Map<String, String> _availableBranches = {
    'branch_koramangala': 'VetCare Central - Koramangala',
    'branch_whitefield': 'VetCare Satellite - Whitefield',
    'branch_downtown': 'Downtown Branch',
    'branch_westside': 'Westside Branch',
    'branch_metro_hub': 'Central Metro Hub',
  };

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<Map<String, String>?> _showRoleSelectionBottomSheet(
      BuildContext context) async {
    String tempRole = 'owner';
    String tempBranch = 'branch_koramangala';

    return showModalBottomSheet<Map<String, String>>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: AppShadows.aestheticCard,
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Select Your Account Type',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose how you will be using VetCare so we can personalize your workspace.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Option 1: Pet Owner
                    InkWell(
                      onTap: () => setModalState(() => tempRole = 'owner'),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: tempRole == 'owner'
                              ? AppColors.lightPill
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: tempRole == 'owner'
                                ? AppColors.primary
                                : AppColors.border.withValues(alpha: 0.5),
                            width: tempRole == 'owner' ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: tempRole == 'owner'
                                    ? AppColors.primary
                                    : AppColors.surfaceVariant,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.pets,
                                size: 22,
                                color: tempRole == 'owner'
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pet Owner',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Access your pets\' records, appointments, and care history.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (tempRole == 'owner')
                              const Icon(Icons.check_circle_rounded,
                                  color: AppColors.primary, size: 22),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Option 2: Veterinarian
                    InkWell(
                      onTap: () => setModalState(() => tempRole = 'vet'),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: tempRole == 'vet'
                              ? AppColors.lightPill
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: tempRole == 'vet'
                                ? AppColors.primary
                                : AppColors.border.withValues(alpha: 0.5),
                            width: tempRole == 'vet' ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: tempRole == 'vet'
                                        ? AppColors.primary
                                        : AppColors.surfaceVariant,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.medical_services_outlined,
                                    size: 22,
                                    color: tempRole == 'vet'
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Veterinarian',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Clinical practitioner with access to multi-clinic records and unified EHR.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (tempRole == 'vet')
                                  const Icon(Icons.check_circle_rounded,
                                      color: AppColors.primary, size: 22),
                              ],
                            ),
                            if (tempRole == 'vet') ...[
                              const SizedBox(height: 14),
                              const Text(
                                'Select Clinic Branch:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: tempBranch,
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down,
                                        color: AppColors.textSecondary),
                                    items: _availableBranches.entries.map((e) {
                                      return DropdownMenuItem<String>(
                                        value: e.key,
                                        child: Text(
                                          e.value,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setModalState(() => tempBranch = val);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx, {
                            'role': tempRole,
                            'branchId': tempBranch,
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkPill,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                          ),
                        ),
                        child: const Text(
                          'Confirm & Continue',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final authService = context.read<AuthService>();
      final isNewUser = await authService
          .signInWithGoogle(
            role: _userExplicitlySelectedRole ? _selectedRole : null,
            branchId: _userExplicitlySelectedRole && _selectedRole == 'vet'
                ? _selectedBranch
                : null,
          )
          .timeout(
            const Duration(seconds: 45),
            onTimeout: () => throw TimeoutException(
                'Google Sign-In timed out. Please try again.'),
          );

      if (!mounted) return;

      if (!authService.isAuthenticated) {
        // User closed or cancelled sign-in prompt without completing
        return;
      }

      // If newly registered user and didn't preselect role on login screen, offer confirmation
      if (isNewUser && !_userExplicitlySelectedRole) {
        final chosen = await _showRoleSelectionBottomSheet(context);
        if (chosen != null && mounted) {
          await authService.switchRole(
            chosen['role']!,
            branchId: chosen['branchId'],
          );
        }
      }

      final nextRoute =
          await authService.determineInitialRoute(waitDuration: Duration.zero);
      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        nextRoute,
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message = e.message ?? 'Google Sign-In failed.';
      if (e.code == 'popup-closed-by-user') {
        message = 'Google sign-in was cancelled.';
      } else if (e.code == 'network-request-failed') {
        message = 'Network error. Please check your internet connection.';
      } else if (e.code == 'account-exists-with-different-credential') {
        message =
            'An account already exists with the same email using a different sign-in method.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-In notice: $e'),
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

  Future<void> _handleEmailSignIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);
    try {
      final authService = context.read<AuthService>();
      await authService
          .signInWithEmail(
            email: email,
            password: password,
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw TimeoutException(
                'Sign-in timed out. Please check your connection.'),
          );

      if (!mounted) return;

      if (_userExplicitlySelectedRole) {
        if (_selectedRole == 'vet') {
          await authService.switchRole('vet', branchId: _selectedBranch);
        } else if (_selectedRole == 'owner') {
          await authService.switchRole('owner');
        }
      }

      final nextRoute =
          await authService.determineInitialRoute(waitDuration: Duration.zero);
      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        nextRoute,
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message = e.message ?? 'Sign-in failed.';
      if (e.code == 'user-not-found') {
        message =
            'No account found with this email. Please check your email or sign up.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Incorrect password or credentials. Please try again.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is badly formatted.';
      } else if (e.code == 'user-disabled') {
        message = 'This user account has been disabled.';
      } else if (e.code == 'too-many-requests') {
        message = 'Too many attempts. Please wait a moment and try again.';
      } else if (e.code == 'operation-not-allowed') {
        message = 'Email/Password sign-in is disabled in Firebase Console.';
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
          content: Text('Sign-in notice: $e'),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Sign In',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Brand Icon Badge
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.subtleCard,
                        border: Border.all(
                            color: AppColors.border.withValues(alpha: 0.3),
                            width: 1.5),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.pets,
                          size: 36,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Header Titles
                  Text(
                    'Welcome back',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    "Log in to view your pet's health records",
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
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.3),
                          width: 1),
                      boxShadow: AppShadows.aestheticCard,
                    ),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Role Selector with Two Chips ("Pet Owner" / "Veterinarian")
                          Text(
                            'Account Type',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
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
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.pill),
                                  ),
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedRole = 'owner';
                                        _userExplicitlySelectedRole = true;
                                      });
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
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.pill),
                                  ),
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedRole = 'vet';
                                        _userExplicitlySelectedRole = true;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (_selectedRole == 'vet') ...[
                            const SizedBox(height: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.lightPill,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedBranch,
                                  isExpanded: true,
                                  icon: const Icon(Icons.keyboard_arrow_down,
                                      color: AppColors.textSecondary),
                                  items: _availableBranches.entries.map((e) {
                                    return DropdownMenuItem<String>(
                                      value: e.key,
                                      child: Text(
                                        e.value,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedBranch = val);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.md),

                          // Email Field with inline validation
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (val) {
                              final lower = val.toLowerCase();
                              if (lower.contains('vet') ||
                                  lower.contains('doctor') ||
                                  lower.contains('dr.') ||
                                  lower.contains('admin')) {
                                if (_selectedRole != 'vet') {
                                  setState(() => _selectedRole = 'vet');
                                }
                              }
                            },
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your email address';
                              }
                              final emailRegex =
                                  RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                              if (!emailRegex.hasMatch(val.trim())) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              hintText: 'name@example.com',
                              prefixIcon: const Icon(Icons.email_outlined,
                                  color: AppColors.textSecondary),
                              filled: true,
                              fillColor: AppColors.lightPill,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Password Field with Visibility Toggle and inline validation
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your password';
                              }
                              if (val.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline,
                                  color: AppColors.textSecondary),
                              filled: true,
                              fillColor: AppColors.lightPill,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
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
                          const SizedBox(height: AppSpacing.xs),

                          // "Forgot password?" Link (UI only for now, no reset flow needed yet)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // UI ONLY: Password reset flow will be connected in future milestone
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Password reset flow is coming soon.'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 2),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          if (_isLoading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: CircularProgressIndicator(
                                    color: AppColors.primary),
                              ),
                            )
                          else ...[
                            // Full-Width Primary "LOG IN" Button
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _handleEmailSignIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.darkPill,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding:
                                      const EdgeInsets.only(left: 24, right: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.pill),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'LOG IN',
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
                                        color: Colors.white
                                            .withValues(alpha: 0.18),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.arrow_forward,
                                            size: 17, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Divider reading "or continue with"
                            const Row(
                              children: [
                                Expanded(
                                    child: Divider(color: Color(0xFFE5E7EB))),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md),
                                  child: Text(
                                    'or continue with',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child: Divider(color: Color(0xFFE5E7EB))),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Full-width white outline button with Google "G" icon and "Continue with Google"
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: OutlinedButton(
                                onPressed: _handleGoogleSignIn,
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                      color: Color(0xFFE5E7EB), width: 1.2),
                                  foregroundColor: AppColors.textPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.pill),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      alignment: Alignment.center,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.surfaceVariant,
                                      ),
                                      child: const Text(
                                        'G',
                                        style: TextStyle(
                                          color: Color(0xFF4285F4),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                          fontFamily: 'sans-serif',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    const Text(
                                      'Continue with Google',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // VISUAL PLACEHOLDER: Fast touchless lobby check-in card
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppShadows.subtleCard,
                      border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.3),
                          width: 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFF7ED),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.meeting_room_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Arrived at the Clinic?',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Tap for fast touchless lobby check-in',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        ElevatedButton(
                          onPressed: () => _showLobbyCheckInSheet(context),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 9),
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.pill),
                            ),
                          ),
                          child: const Text(
                            'Check In',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Bottom Redirect Link
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'Don\'t have an account? ',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 14),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.signup),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Create Account',
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

  void _showLobbyCheckInSheet(BuildContext context) {
    String selectedBranch = 'VetCare Central - Koramangala (Hub)';
    String petName = 'Milo';
    bool checkedIn = false;
    String queueToken =
        'VC-${(DateTime.now().millisecondsSinceEpoch % 900) + 100}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
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
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF7ED),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.qr_code_scanner_rounded,
                        color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Touchless Lobby Check-In',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: AppColors.textPrimary),
                        ),
                        Text(
                          'Direct queue entry synced to the front desk',
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
              if (!checkedIn) ...[
                const Text('Select Clinic Branch',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: selectedBranch,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.apartment_rounded,
                        color: AppColors.textSecondary),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'VetCare Central - Koramangala (Hub)',
                      child: Text('VetCare Central - Koramangala (Hub)'),
                    ),
                    DropdownMenuItem(
                      value: 'VetCare Satellite - Whitefield',
                      child: Text('VetCare Satellite - Whitefield'),
                    ),
                    DropdownMenuItem(
                      value: 'Downtown Medical Branch',
                      child: Text('Downtown Medical Branch'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedBranch = val);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                const Text('Pet Name',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                TextFormField(
                  initialValue: petName,
                  decoration: const InputDecoration(
                    prefixIcon:
                        Icon(Icons.pets, color: AppColors.textSecondary),
                    hintText: 'Enter your pet\'s name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => petName = val,
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: () {
                    setModalState(() => checkedIn = true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Confirm Arrival & Get Queue Pass',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.success, size: 48),
                      const SizedBox(height: AppSpacing.xs),
                      const Text(
                        'Check-In Confirmed!',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Queue Pass: $queueToken',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                            color: AppColors.primary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$petName has been added to the waiting queue at $selectedBranch. Please proceed to the waiting lounge.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: () => Navigator.pop(sheetCtx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Done'),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}
