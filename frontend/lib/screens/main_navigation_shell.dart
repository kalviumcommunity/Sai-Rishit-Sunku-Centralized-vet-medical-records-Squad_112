import 'package:flutter/material.dart';

import '../widgets/limelight_nav.dart';
import 'owner/add_pet_screen.dart';
import 'owner/owner_home_screen.dart';
import 'owner/profile_screen.dart';
import 'pet/pet_profile_screen.dart';
import 'vet/vet_search_screen.dart';

/// Unified Application Shell with Persistent Limelight Bottom Navigation
/// Present on all authenticated screens (Home, Records, Add Pet, Clinics, Profile).
/// Excluded entirely on Login, Signup, and Splash screens.
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
    if (index >= 0 && index < _navItems.length) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  final List<LimelightItem> _navItems = const [
    LimelightItem(id: 'home', icon: Icons.home_outlined, label: 'Home'),
    LimelightItem(id: 'records', icon: Icons.description_outlined, label: 'Records'),
    LimelightItem(id: 'add', icon: Icons.add_circle_outline, label: 'Add Pet'),
    LimelightItem(id: 'clinics', icon: Icons.local_hospital_outlined, label: 'Clinics'),
    LimelightItem(id: 'profile', icon: Icons.person_outline, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    // List of tab views matching the navigation bar
    final tabScreens = [
      const OwnerHomeScreen(),
      const PetProfileScreen(),
      const AddPetScreen(isEmbeddedInNav: true),
      const VetSearchScreen(),
      const ProfileScreen(),
    ];

    return Stack(
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
              items: _navItems,
            ),
          ),
        ),
      ],
    );
  }
}
