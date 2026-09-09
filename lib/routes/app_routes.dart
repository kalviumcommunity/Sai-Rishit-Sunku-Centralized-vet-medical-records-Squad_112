import 'package:flutter/material.dart';

import '../screens/admin/admin_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/owner/add_pet_screen.dart';
import '../screens/owner/owner_home_screen.dart';
import '../screens/pet/documents_screen.dart';
import '../screens/pet/pet_profile_screen.dart';
import '../screens/pet/vaccinations_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/vet/add_treatment_screen.dart';
import '../screens/vet/vet_followups_screen.dart';
import '../screens/vet/vet_search_screen.dart';

/// Centralized Named Routes for the 12 screens in VetCare.
class AppRoutes {
  // 12 Named Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String ownerHome = '/owner_home';
  static const String petProfile = '/pet_profile';
  static const String vetSearch = '/vet_search';
  static const String vetFollowups = '/vet_followups';
  static const String addTreatment = '/add_treatment';
  static const String vaccinations = '/vaccinations';
  static const String addPet = '/add_pet';
  static const String documents = '/documents';
  static const String admin = '/admin';

  /// Named route mapping for MaterialApp.routes
  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        login: (context) => const LoginScreen(),
        signup: (context) => const SignupScreen(),
        ownerHome: (context) => const OwnerHomeScreen(),
        petProfile: (context) => const PetProfileScreen(),
        vetSearch: (context) => const VetSearchScreen(),
        vetFollowups: (context) => const VetFollowupsScreen(),
        addTreatment: (context) => const AddTreatmentScreen(),
        vaccinations: (context) => const VaccinationsScreen(),
        addPet: (context) => const AddPetScreen(),
        documents: (context) => const DocumentsScreen(),
        admin: (context) => const AdminScreen(),
      };

  /// Optional onGenerateRoute for custom transitions or argument handling
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name];
    if (builder != null) {
      return MaterialPageRoute(
        builder: builder,
        settings: settings,
      );
    }
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Route Not Found')),
        body: Center(
          child: Text('No route defined for ${settings.name}'),
        ),
      ),
    );
  }
}
