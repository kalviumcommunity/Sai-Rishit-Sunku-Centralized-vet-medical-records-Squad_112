import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_card.dart';

class AddTreatmentScreen extends StatelessWidget {
  const AddTreatmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Clinical Treatment')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomCard(
                margin: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Treatment Record Entry', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Records added here are immediately synced across all clinic branches.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'Clinic Branch',
                        hintText: 'e.g., Central Vet Hospital - Branch 3',
                        prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'Attending Veterinarian',
                        hintText: 'Dr. John Doe, DVM',
                        prefixIcon: Icon(Icons.person_outline, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'Diagnosis / Chief Complaint',
                        prefixIcon: Icon(Icons.medical_information_outlined, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const TextField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Prescription & Clinical Notes',
                        prefixIcon: Icon(Icons.note_alt_outlined, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Treatment record saved and synced!')),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Save Treatment Record'),
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
