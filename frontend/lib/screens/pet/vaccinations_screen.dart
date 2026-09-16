import 'package:flutter/material.dart';
import 'pet_profile_screen.dart';

/// DAY 8 — Vaccinations Screen
///
/// Route wrapper pointing to the dedicated Vaccinations tab on the Pet Profile screen,
/// providing consistent cross-branch record display, status pills, and "+ Add Vaccination" flow.
class VaccinationsScreen extends StatelessWidget {
  const VaccinationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PetProfileScreen(
      initialTabIndex: 1,
      showBackButton: true,
    );
  }
}
