import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../widgets/limelight_nav.dart';
import 'admin/admin_screen.dart';
import 'owner/add_pet_screen.dart';
import 'owner/owner_home_screen.dart';
import 'owner/profile_screen.dart';
import 'pet/pet_profile_screen.dart';
import 'vet/add_treatment_screen.dart';
import 'vet/vet_followups_screen.dart';
import 'vet/vet_search_screen.dart';

/// Unified Application Shell with Persistent Limelight Bottom Navigation
/// Present on all authenticated screens. Adapts dynamically based on active user role:
/// - Pet Owner: Home, Records, Add Pet, Clinics, Profile
/// - Veterinarian: Patients (Registry), Follow-ups (Worklist), Record Care (Treatment), Admin Hub, Profile
/// - Administrator: Admin Hub (Overview), Patients, Worklist, Pet Portal, Profile
class MainNavigationShell extends StatefulWidget {
  final int initialIndex;

  const MainNavigationShell({
    super.key,
    this.initialIndex = 0,
  });

  /// Allows child widgets in any tab to access the shell and switch active tabs
  static MainNavigationShellState? of(BuildContext context) {
    return context.findAncestorStateOfType<MainNavigationShellState>();
  }

  @override
  State<MainNavigationShell> createState() => MainNavigationShellState();
}

class MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant MainNavigationShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      setState(() {
        _currentIndex = widget.initialIndex;
      });
    }
  }

  /// Switch the active tab programmatically
  void setTab(int index) {
    if (index >= 0) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  static const List<LimelightItem> _ownerNavItems = [
    LimelightItem(id: 'home', icon: Icons.home_outlined, label: 'Home'),
    LimelightItem(id: 'records', icon: Icons.description_outlined, label: 'Records'),
    LimelightItem(id: 'add', icon: Icons.add_circle_outline, label: 'Add Pet'),
    LimelightItem(id: 'clinics', icon: Icons.local_hospital_outlined, label: 'Clinics'),
    LimelightItem(id: 'profile', icon: Icons.person_outline, label: 'Profile'),
  ];

  static const List<LimelightItem> _vetNavItems = [
    LimelightItem(id: 'patients', icon: Icons.search, label: 'Patients'),
    LimelightItem(id: 'followups', icon: Icons.assignment_outlined, label: 'Follow-ups'),
    LimelightItem(id: 'record', icon: Icons.add_circle_outline, label: 'Record Care'),
    LimelightItem(id: 'admin', icon: Icons.admin_panel_settings_outlined, label: 'Admin Hub'),
    LimelightItem(id: 'profile', icon: Icons.person_outline, label: 'Profile'),
  ];

  static const List<LimelightItem> _adminNavItems = [
    LimelightItem(id: 'admin', icon: Icons.admin_panel_settings_outlined, label: 'Admin Hub'),
    LimelightItem(id: 'patients', icon: Icons.search, label: 'Patients'),
    LimelightItem(id: 'worklist', icon: Icons.assignment_outlined, label: 'Worklist'),
    LimelightItem(id: 'owner', icon: Icons.pets_outlined, label: 'Pet Portal'),
    LimelightItem(id: 'profile', icon: Icons.person_outline, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final role = authService.userRole.toLowerCase();

    final List<LimelightItem> navItems;
    final List<Widget> tabScreens;

    if (role == 'vet' || role == 'admin') {
      navItems = _vetNavItems;
      tabScreens = const [
        VetSearchScreen(),
        VetFollowupsScreen(),
        AddTreatmentScreen(isEmbeddedInNav: true),
        AdminScreen(),
        ProfileScreen(),
      ];
    } else {
      navItems = _ownerNavItems;
      tabScreens = const [
        OwnerHomeScreen(),
        PetProfileScreen(),
        AddPetScreen(isEmbeddedInNav: true),
        VetSearchScreen(),
        ProfileScreen(),
      ];
    }

    if (_currentIndex >= tabScreens.length) {
      _currentIndex = 0;
    }

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
        }
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _currentIndex,
              children: tabScreens,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: SafeArea(
              child: LimelightNavBar(
                activeIndex: _currentIndex,
                onTabChange: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                items: navItems,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
