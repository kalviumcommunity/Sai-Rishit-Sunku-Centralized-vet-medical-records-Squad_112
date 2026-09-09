import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_card.dart';

class PetProfileScreen extends StatelessWidget {
  const PetProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          children: [
            // Profile Card
            CustomCard(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(Icons.pets, size: 44, color: AppColors.primary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Milo', style: Theme.of(context).textTheme.headlineMedium),
                  const Text('Golden Retriever • 3 Years Old', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: AppSpacing.sm),
                  const Chip(
                    backgroundColor: AppColors.surfaceVariant,
                    label: Text('Microchip: #985141002345'),
                  ),
                ],
              ),
            ),

            // Navigation Sections for Pet Records
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Medical Records', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      child: Icon(Icons.vaccines, color: AppColors.primary),
                    ),
                    title: const Text('Vaccinations'),
                    subtitle: const Text('Rabies, DHPP, Bordetella history'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.vaccinations),
                  ),
                  const Divider(color: AppColors.border),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      child: Icon(Icons.description_outlined, color: AppColors.primary),
                    ),
                    title: const Text('Medical Documents & Lab Reports'),
                    subtitle: const Text('Prescriptions, X-rays, and discharge summaries'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.documents),
                  ),
                  const Divider(color: AppColors.border),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      child: Icon(Icons.medical_services_outlined, color: AppColors.primary),
                    ),
                    title: const Text('Add Clinical Treatment'),
                    subtitle: const Text('Veterinarian entry for visit history'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.addTreatment),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
