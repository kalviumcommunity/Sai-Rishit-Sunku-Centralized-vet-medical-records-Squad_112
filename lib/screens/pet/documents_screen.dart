import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_card.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medical Documents')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          children: [
            CustomCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.picture_as_pdf, color: AppColors.primary),
                ),
                title: const Text('Blood Work Panel (Complete CBC)'),
                subtitle: const Text('Branch: North Clinic • Uploaded: Feb 20, 2026'),
                trailing: const Icon(Icons.download_outlined),
              ),
            ),
            CustomCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.image_outlined, color: AppColors.primary),
                ),
                title: const Text('Chest & Abdominal Radiograph (X-Ray)'),
                subtitle: const Text('Branch: South Emergency • Uploaded: Jan 04, 2026'),
                trailing: const Icon(Icons.download_outlined),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Firebase Storage upload flow')),
          );
        },
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload Document'),
      ),
    );
  }
}
