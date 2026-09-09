import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_card.dart';

class AddPetScreen extends StatelessWidget {
  const AddPetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Pet')),
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
                    Text('Pet Information', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'This profile will follow your pet to any branch clinic.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'Pet Name',
                        prefixIcon: Icon(Icons.pets, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'Species (Dog, Cat, etc.)',
                        prefixIcon: Icon(Icons.category, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'Breed',
                        prefixIcon: Icon(Icons.info_outline, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'Microchip ID / Tag Number',
                        prefixIcon: Icon(Icons.qr_code, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pet saved successfully!')),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Save Pet Profile'),
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
