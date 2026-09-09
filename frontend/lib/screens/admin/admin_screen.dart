import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_card.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Management Console')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Network Administration', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'Manage multi-branch clinic authorization and system audit logs.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            CustomCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.apartment, color: AppColors.primary),
                ),
                title: const Text('Clinic Branches (5 Active)'),
                subtitle: const Text('Configure branch IDs, locations, and access tokens'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ),
            CustomCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.badge_outlined, color: AppColors.primary),
                ),
                title: const Text('Veterinarian & Staff Credentials'),
                subtitle: const Text('Verify veterinary licenses and role assignments'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ),
            CustomCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.security, color: AppColors.primary),
                ),
                title: const Text('Central Security & Audit Logs'),
                subtitle: const Text('Review cross-branch medical record read/write requests'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
