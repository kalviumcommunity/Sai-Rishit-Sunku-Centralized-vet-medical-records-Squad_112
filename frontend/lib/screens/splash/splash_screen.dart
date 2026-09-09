import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_card.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.lg),

              // Brand Icon Badge
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppShadows.buttonShadow,
                ),
                child: const Icon(
                  Icons.pets,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Brand Title
              Text(
                'VetCare',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),

              // Subtitle
              Text(
                'Centralized Veterinary Medical Records',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),

              Text(
                'A pet\'s medical history that follows them across branches',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Primary CTA
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.login);
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Get Started (Login)'),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Day 1 Navigation Skeleton Test Suite
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.route, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Day 1 Route Verification',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Tap any route below to verify the 12-screen navigation skeleton:',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _RouteChip(label: 'Login', route: AppRoutes.login),
                        _RouteChip(label: 'Signup', route: AppRoutes.signup),
                        _RouteChip(label: 'Owner Home', route: AppRoutes.ownerHome),
                        _RouteChip(label: 'Add Pet', route: AppRoutes.addPet),
                        _RouteChip(label: 'Pet Profile', route: AppRoutes.petProfile),
                        _RouteChip(label: 'Vaccinations', route: AppRoutes.vaccinations),
                        _RouteChip(label: 'Documents', route: AppRoutes.documents),
                        _RouteChip(label: 'Vet Search', route: AppRoutes.vetSearch),
                        _RouteChip(label: 'Vet Follow-ups', route: AppRoutes.vetFollowups),
                        _RouteChip(label: 'Add Treatment', route: AppRoutes.addTreatment),
                        _RouteChip(label: 'Admin Panel', route: AppRoutes.admin),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteChip extends StatelessWidget {
  final String label;
  final String route;

  const _RouteChip({required this.label, required this.route});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
      ),
      onPressed: () {
        Navigator.pushNamed(context, route);
      },
    );
  }
}
