import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../utils/constants.dart';
import '../../widgets/pet_mascots.dart';

class PetProfileScreen extends StatelessWidget {
  const PetProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.aestheticBackground,
      appBar: AppBar(
        backgroundColor: AppColors.aestheticBackground,
        elevation: 0,
        title: const Text(
          'Pet Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textPrimary),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 95),
          children: [
            // Aesthetic Hero Profile Card
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.aestheticBorder, width: 1.2),
                boxShadow: AppShadows.aestheticCard,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  const SizedBox(
                    height: 120,
                    child: Center(
                      child: MascotDogWidget(size: 130),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Milo',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Golden Retriever • 3 Years Old',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.lightPill,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Microchip: #985141002345',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Navigation Sections for Pet Records
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.aestheticBorder, width: 1.2),
                boxShadow: AppShadows.aestheticCard,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Medical Records',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const Icon(Icons.verified, size: 18, color: AppColors.success),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildRecordTile(
                    icon: Icons.vaccines,
                    title: 'Vaccinations',
                    subtitle: 'Rabies, DHPP, Bordetella history',
                    bgColor: const Color(0xFFFEF3C7),
                    iconColor: const Color(0xFFD97706),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.vaccinations),
                  ),
                  const Divider(color: AppColors.aestheticBorder, height: 20),
                  _buildRecordTile(
                    icon: Icons.description_outlined,
                    title: 'Medical Documents & Lab Reports',
                    subtitle: 'Prescriptions, X-rays, and discharge summaries',
                    bgColor: const Color(0xFFEFF6FF),
                    iconColor: const Color(0xFF2563EB),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.documents),
                  ),
                  const Divider(color: AppColors.aestheticBorder, height: 20),
                  _buildRecordTile(
                    icon: Icons.medical_services_outlined,
                    title: 'Add Clinical Treatment',
                    subtitle: 'Veterinarian entry for visit history',
                    bgColor: const Color(0xFFF3E8FF),
                    iconColor: const Color(0xFF9333EA),
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

  Widget _buildRecordTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
