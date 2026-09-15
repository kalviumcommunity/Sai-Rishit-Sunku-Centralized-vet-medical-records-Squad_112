import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../widgets/aesthetic_care_card.dart';
import '../main_navigation_shell.dart';

class OwnerHomeScreen extends StatelessWidget {
  const OwnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.currentUserModel;
    final ownerName = user?.name.isNotEmpty == true ? user!.name : 'Pet Owner';

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.aestheticBackground,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.aestheticBackground,
          elevation: 0,
          title: const Text(
            'My Pets',
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
                child: const Icon(Icons.person_outline, size: 20, color: AppColors.textPrimary),
              ),
              tooltip: 'My Profile',
              onPressed: () {
                final shell = MainNavigationShell.of(context);
                if (shell != null) {
                  shell.setTab(4);
                } else {
                  Navigator.pushNamed(context, AppRoutes.profile);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.logout_outlined, color: AppColors.textSecondary),
              tooltip: 'Sign Out',
              onPressed: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (dialogCtx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out of VetCare?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogCtx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogCtx, true),
                        child: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );

                if (shouldLogout == true && context.mounted) {
                  await context.read<AuthService>().signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (route) => false,
                    );
                  }
                }
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: 95),
            children: [
              // Header Greeting & Subtitle Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pet Dashboard',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.6,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Hello, $ownerName 👋',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.sync, size: 13, color: AppColors.primary),
                              SizedBox(width: 4),
                              Text(
                                'Synced',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Centralized records across all participating vet clinics',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Hero Aesthetic Care Card (Mockup Inspired with Mascot, Actions & Switcher)
              AestheticCareCard(
                onAddPet: () {
                  final shell = MainNavigationShell.of(context);
                  if (shell != null) {
                    shell.setTab(2);
                  } else {
                    Navigator.pushNamed(context, AppRoutes.addPet);
                  }
                },
                onOpenRecords: () {
                  final shell = MainNavigationShell.of(context);
                  if (shell != null) {
                    shell.setTab(1);
                  } else {
                    Navigator.pushNamed(context, AppRoutes.petProfile);
                  }
                },
                onOpenVaccines: () {
                  Navigator.pushNamed(context, AppRoutes.vaccinations);
                },
              ),
              const SizedBox(height: 16),

              // Quick Actions Card with aesthetic layout
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
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
                          'Quick Navigation',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const Icon(Icons.bolt, size: 18, color: AppColors.warning),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildActionTile(
                      icon: Icons.add,
                      title: 'Add New Pet',
                      subtitle: 'Register pet details and medical history',
                      color: const Color(0xFFEFF6FF),
                      iconColor: const Color(0xFF3B82F6),
                      onTap: () {
                        final shell = MainNavigationShell.of(context);
                        if (shell != null) {
                          shell.setTab(2);
                        } else {
                          Navigator.pushNamed(context, AppRoutes.addPet);
                        }
                      },
                    ),
                    const Divider(color: AppColors.aestheticBorder, height: 20),
                    _buildActionTile(
                      icon: Icons.search,
                      title: 'Vet Portal / Search',
                      subtitle: 'Search records across clinic branches',
                      color: AppColors.primaryLight,
                      iconColor: AppColors.primary,
                      onTap: () {
                        final shell = MainNavigationShell.of(context);
                        if (shell != null) {
                          shell.setTab(3);
                        } else {
                          Navigator.pushNamed(context, AppRoutes.vetSearch);
                        }
                      },
                    ),
                    const Divider(color: AppColors.aestheticBorder, height: 20),
                    _buildActionTile(
                      icon: Icons.admin_panel_settings_outlined,
                      title: 'Admin Console',
                      subtitle: 'Manage clinics, staff, and access',
                      color: const Color(0xFFF3E8FF),
                      iconColor: const Color(0xFF9333EA),
                      onTap: () => Navigator.pushNamed(context, AppRoutes.admin),
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

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
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
                color: color,
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
