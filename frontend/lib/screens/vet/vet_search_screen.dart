import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_card.dart';

class VetSearchScreen extends StatelessWidget {
  const VetSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cross-Branch Pet Search')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Veterinary Record Lookup', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'Search any registered pet by microchip ID, phone number, or tag across branches.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Search Bar Card
            CustomCard(
              child: Column(
                children: [
                  const TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter microchip, owner phone, or pet name...',
                      prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.petProfile);
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Search Central Database'),
                  ),
                ],
              ),
            ),

            // Quick Link to Follow-ups
            CustomCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.event_note, color: AppColors.primary),
                ),
                title: const Text('View Scheduled Follow-ups'),
                subtitle: const Text('Patients requiring check-ins at this branch'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, AppRoutes.vetFollowups),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
